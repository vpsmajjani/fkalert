const puppeteer = require('puppeteer');
const fs = require('fs');
const { execSync } = require('child_process');

const userLink = process.argv[2];
const recordingDuration = 60; // seconds
const fps = 10; // frames per second

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

// Create frames directory
if (!fs.existsSync('frames')) {
  fs.mkdirSync('frames');
} else {
  // Clear existing frames
  fs.readdirSync('frames').forEach(file => {
    fs.unlinkSync(`frames/${file}`);
  });
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  let captureInterval;
  let timeoutId;

  try {
    await page.goto(userLink, { waitUntil: 'networkidle0' });
    
    // Handle age verification if needed
    try {
      await page.waitForSelector('.btn-visitors-agreement-accept', { timeout: 5000 });
      await page.click('.btn-visitors-agreement-accept');
      console.log('Clicked age verification button');
    } catch (error) {
      console.log('No age verification needed');
    }

    // Calculate interval between frames
    const interval = 1000 / fps;
    const totalFrames = recordingDuration * fps;
    let frameCount = 0;

    console.log(`Recording ${recordingDuration} seconds at ${fps} FPS...`);

    // Capture frames with proper error handling
    captureInterval = setInterval(async () => {
      if (frameCount >= totalFrames) {
        clearInterval(captureInterval);
        return;
      }

      try {
        await page.screenshot({
          path: `frames/frame_${frameCount.toString().padStart(5, '0')}.png`,
        });
        frameCount++;
      } catch (error) {
        console.error('Error capturing frame:', error.message);
        clearInterval(captureInterval);
      }
    }, interval);

    // Set timeout to stop recording
    timeoutId = setTimeout(async () => {
      clearInterval(captureInterval);
      await convertFramesToVideo();
      await browser.close();
    }, recordingDuration * 1000);

    // Wait for manual stop if needed
    await new Promise(resolve => {
      timeoutId.unref(); // Prevent from keeping Node.js process running
    });

  } catch (error) {
    console.error('Error:', error);
    if (captureInterval) clearInterval(captureInterval);
    if (timeoutId) clearTimeout(timeoutId);
    await browser.close();
  }

  async function convertFramesToVideo() {
    console.log('Converting frames to video...');
    try {
      execSync(
        `ffmpeg -framerate ${fps} -i frames/frame_%05d.png -c:v libx264 -pix_fmt yuv420p -y recording.mp4`,
        { stdio: 'inherit' }
      );
      console.log('Video saved as recording.mp4');
    } catch (error) {
      console.error('Error converting frames:', error);
    }
  }
})();
