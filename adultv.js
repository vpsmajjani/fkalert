const puppeteer = require('puppeteer');
const { record } = require('puppeteer-video-recorder');

const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  // Start recording
  const recorder = await record({
    browser,
    output: 'recording.mp4',
    fps: 30,
    duration: 60 * 1000 // 60 seconds
  });

  try {
    await page.goto(userLink, { waitUntil: 'networkidle0' });
    
    // Handle age verification
    try {
      await page.click('.btn-visitors-agreement-accept');
    } catch {} // Ignore if no button exists

    // Let the recording continue for 60 seconds
    await new Promise(r => setTimeout(r, 60000));

  } finally {
    await recorder.stop();
    await browser.close();
    console.log('Video saved as recording.mp4');
  }
})();
