const puppeteer = require('puppeteer');
const fs = require('fs');
const { execSync } = require('child_process');

const userLink = process.argv[2];
const recordingDuration = 120; // seconds
const targetFps = 10; // Increased FPS to 10

// Desktop view settings
const viewport = {
  width: 1280,
  height: 720,
  deviceScaleFactor: 1,
  isMobile: false
};

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

// Generate unique filename based on URL
function getUniqueFilename(url) {
  // Extract the last part of the URL (after last /)
  const urlParts = url.split('/');
  let baseName = urlParts[urlParts.length - 1];
  if (!baseName) baseName = 'recording'; // Fallback if empty

  // Remove any characters that might be problematic for filenames
  baseName = baseName.replace(/[^a-zA-Z0-9_-]/g, '');

  let counter = 0;
  let fileName = `${baseName}.mp4`;

  while (fs.existsSync(fileName)) {
    counter++;
    fileName = `${baseName}${counter}.mp4`;
  }

  return fileName;
}

// Clear frames directory
function clearFrames() {
  if (!fs.existsSync('frames')) fs.mkdirSync('frames');
  fs.readdirSync('frames').forEach(file => fs.unlinkSync(`frames/${file}`));
}

(async () => {
  clearFrames();
  const outputFilename = getUniqueFilename(userLink);

  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--single-process' // Improved stability
    ],
    headless: "new",
    timeout: 60000
  });

  const page = await browser.newPage();
  await page.setViewport(viewport);
  await page.setDefaultNavigationTimeout(60000);

  try {
    // Navigate to page
    await page.goto(userLink, {
      waitUntil: 'domcontentloaded',
      timeout: 60000
    });

    // Handle age verification
    try {
      await page.waitForSelector('.btn-visitors-agreement-accept', { timeout: 5000 });
      await page.click('.btn-visitors-agreement-accept');
      await page.waitForTimeout(2000);
    } catch {} // Ignore if no button

    const startTime = Date.now();
    let frameCount = 0;
    const frameInterval = 1000 / targetFps;

    console.log(`Recording ${recordingDuration} seconds at ${targetFps} FPS...`);

    // Capture frames with error handling
    const captureFrame = async () => {
      try {
        await page.screenshot({
          path: `frames/frame_${frameCount.toString().padStart(5, '0')}.png`,
          omitBackground: true, // Faster captures
          fullPage: false // Viewport-only is faster
        });
        frameCount++;
      } catch (err) {
        console.error('Frame error:', err.message);
      }
    };

    // Initial frame
    await captureFrame();

    // Periodic capture with precise timing
    const captureInterval = setInterval(async () => {
      if (Date.now() - startTime >= recordingDuration * 1000) {
        clearInterval(captureInterval);
        return;
      }
      await captureFrame();
    }, frameInterval);

    // Stop after duration
    await new Promise(resolve => {
      setTimeout(async () => {
        clearInterval(captureInterval);
        const actualDuration = (Date.now() - startTime) / 1000;
        console.log(`Captured ${frameCount} frames in ${actualDuration.toFixed(1)}s`);

        // Create video with correct duration
        execSync(
          `ffmpeg -r ${targetFps} -i frames/frame_%05d.png ` +
          `-c:v libx264 -pix_fmt yuv420p ` +
          `-vf "fps=${targetFps},setpts=N/(${targetFps}*TB)" ` +
          `-y ${outputFilename}`,
          { stdio: 'inherit' }
        );

        console.log(`Video saved as ${outputFilename}`);
        await browser.close();
        resolve();
      }, recordingDuration * 1000);
    });

  } catch (error) {
    console.error('Main error:', error);
    await browser.close();
  }
})();

