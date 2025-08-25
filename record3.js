const puppeteer = require('puppeteer');
const fs = require('fs');
const { execSync } = require('child_process');

const userLink = process.argv[2];
const recordingDuration = 60; // seconds
const fps = 10; // frames per second

// Set desktop dimensions (16:9 aspect ratio)
const DESKTOP_VIEWPORT = {
  width: 1280,  // Standard laptop width
  height: 720,  // 720p height
  isMobile: false,
  hasTouch: false
};

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

// Create frames directory
if (!fs.existsSync('frames')) fs.mkdirSync('frames');

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--window-size=1280,720'  // Sets browser window size
    ],
    headless: "new"
  });

  const page = await browser.newPage();
  
  // Set desktop viewport (critical change)
  await page.setViewport(DESKTOP_VIEWPORT);
  
  // Emulate desktop user agent
  await page.setUserAgent(
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  );

  try {
    await page.goto(userLink, { 
      waitUntil: 'networkidle2',
      timeout: 60000
    });

    // Handle age verification
    try {
      await page.click('.btn-visitors-agreement-accept');
      await page.waitForTimeout(2000);
    } catch {} // Ignore if no button

    // Frame capture logic
    let frameCount = 0;
    const captureFrame = async () => {
      await page.screenshot({
        path: `frames/frame_${frameCount.toString().padStart(5, '0')}.png`,
        fullPage: true  // Captures full scrollable page
      });
      frameCount++;
    };

    console.log(`Recording ${recordingDuration}s in desktop view...`);
    
    // Initial capture
    await captureFrame();
    
    // Periodic captures
    const interval = setInterval(captureFrame, 1000/fps);
    setTimeout(() => {
      clearInterval(interval);
      execSync(
        `ffmpeg -framerate ${fps} -i frames/frame_%05d.png -c:v libx264 -pix_fmt yuv420p -y recording.mp4`,
        { stdio: 'inherit' }
      );
      console.log('Desktop recording saved as recording.mp4');
      browser.close();
    }, recordingDuration * 1000);

  } catch (error) {
    console.error('Error:', error);
    await browser.close();
  }
})();
