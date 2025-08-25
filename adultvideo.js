const puppeteer = require('puppeteer');
const { PuppeteerScreenRecorder } = require('puppeteer-screen-recorder');

const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1920,1080']
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1080 });

  // Configure screen recorder
  const recorder = new PuppeteerScreenRecorder(page);
  const config = {
    followNewTab: true,
    fps: 25,
    videoFrame: {
      width: 1280,
      height: 720
    },
    videoCrf: 18,
    videoCodec: 'libx264',
    videoPreset: 'ultrafast',
    videoBitrate: 1000,
    autopad: {
      color: 'black'
    }
  };

  try {
    // Start recording
    await recorder.start('recording.mp4'); 

    await page.goto(userLink, { waitUntil: 'networkidle0' });
    
    // Handle age verification if needed
    try {
      await page.waitForSelector('.visitors-agreement-modal', { timeout: 5000 });
      await page.click('.visitors-agreement-modal .btn-visitors-agreement-accept');
      console.log('Clicked age verification button');
    } catch (error) {
      console.log('No age verification needed');
    }

    // Record for exactly 60 seconds
    await new Promise(resolve => setTimeout(resolve, 60000));

  } catch (error) {
    console.error('Error during recording:', error);
  } finally {
    // Stop recording and close browser
    await recorder.stop();
    await browser.close();
    console.log('60-second video saved as recording.mp4');
  }
})();
