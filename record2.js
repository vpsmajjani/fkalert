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
  let browser;
  let page;
  let captureInterval;
  let timeoutId;

  try {
    browser = await puppeteer.launch({
      executablePath: '/usr/bin/google-chrome',
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
      headless: "new" // Use new headless mode for better stability
    });
    page = await browser.newPage();
    await page.setDefaultNavigationTimeout(60000); // 60 seconds timeout

    // Set viewport to a reasonable size
    await page.setViewport({ width: 1280, height: 720 });

    // Navigate to page
    await page.goto(userLink, { 
      waitUntil: 'networkidle2',
      timeout: 60000
    });

    // Handle age verification if needed
    try {
      await page.waitForSelector('.btn-visitors-agreement-accept', { timeout: 5000 });
      await page.click('.btn-visitors-agreement-accept');
      console.log('Clicked age verification button');
      await page.waitForTimeout(2000); // Wait for page to settle
    } catch (error) {
      console.log('No age verification needed');
    }

    // Calculate interval between frames
    const interval = 1000 / fps;
    const totalFrames = recordingDuration * fps;
    let frameCount = 0;

    console.log(`Recording ${recordingDuration} seconds at ${fps} FPS...`);

    // Function to capture a single frame
    const captureFrame = async (frameNumber) => {
      try {
        await page.screenshot({
          path: `frames/frame_${frameNumber.toString().padStart(5, '0')}.png`,
          fullPage: true // Capture full page
        });
      } catch (error) {
        console.error(`Error capturing frame ${frameNumber}:`, error.message);
        return false;
      }
      return true;
    };

    // Capture initial frame immediately
    await captureFrame(frameCount++);

    // Start interval for capturing frames
    captureInterval = setInterval(async () => {
      if (frameCount >= totalFrames) {
        clearInterval(captureInterval);
        return;
      }

      const success = await captureFrame(frameCount++);
      if (!success && captureInterval) {
        clearInterval(captureInterval);
      }
    }, interval);

    // Set timeout to stop recording
    timeoutId = setTimeout(async () => {
      if (captureInterval) clearInterval(captureInterval);
      await convertFramesToVideo();
      if (browser) await browser.close();
    }, recordingDuration * 1000);

    // Wait for recording to complete
    await new Promise(resolve => {
      timeoutId.unref(); // Prevent from keeping Node.js process running
    });

  } catch (error) {
    console.error('Main error:', error);
  } finally {
    if (captureInterval) clearInterval(captureInterval);
    if (timeoutId) clearTimeout(timeoutId);
    if (browser) await browser.close();
  }

  async function convertFramesToVideo() {
    console.log('Converting frames to video...');
    try {
      // First count how many frames we actually captured
      const frames = fs.readdirSync('frames').filter(file => file.endsWith('.png'));
      if (frames.length === 0) {
        console.log('No frames captured - cannot create video');
        return;
      }

      // Calculate actual duration based on captured frames
      const actualDuration = frames.length / fps;
      console.log(`Creating video from ${frames.length} frames (${actualDuration.toFixed(1)}s)`);

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
