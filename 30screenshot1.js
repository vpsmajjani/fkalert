const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const userLink = process.argv[2];
const outputDir = 'screenshots';
const recordingPrefix = 'recording';

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

// Create output directory if it doesn't exist
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1920,1080'],
    headless: false // Running in headful mode helps with dynamic content
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1080 });

  try {
    await page.goto(userLink, { 
      waitUntil: 'networkidle0',
      timeout: 30000 
    });

    // Handle age verification if it exists
    try {
      await page.waitForSelector('.visitors-agreement-modal', { timeout: 5000 });
      await page.click('.visitors-agreement-modal .btn-visitors-agreement-accept');
      console.log('Clicked age verification');
      await page.waitForTimeout(1000);
    } catch (e) {
      console.log('No age verification found');
    }

    // Recording parameters
    const totalScreenshots = 30;
    const interval = 2000; // 2 seconds between screenshots
    const scrollStep = 100; // Pixels to scroll between shots

    // Find next available recording number
    let recordingNumber = 1;
    while (fs.existsSync(path.join(outputDir, `${recordingPrefix}${recordingNumber}_1.jpg`))) {
      recordingNumber++;
    }

    console.log(`Starting screenshot sequence (${totalScreenshots} screenshots)`);

    // Initial scroll position
    let scrollPosition = 0;
    const maxScroll = await page.evaluate(() => document.body.scrollHeight - window.innerHeight);

    for (let i = 0; i < totalScreenshots; i++) {
      const timestamp = Date.now();
      const screenshotPath = path.join(outputDir, `${recordingPrefix}${recordingNumber}_${i + 1}.jpg`);

      // Scroll the page (circular scrolling)
      scrollPosition = (scrollPosition + scrollStep) % maxScroll;
      await page.evaluate((pos) => {
        window.scrollTo(0, pos);
      }, scrollPosition);

      // Force a re-render by hovering over an element
      await page.mouse.move(Math.random() * 1920, Math.random() * 1080);

      // Add some random delay variation (100-300ms)
      await page.waitForTimeout(100 + Math.random() * 200);

      // Take screenshot with JPEG compression
      await page.screenshot({
        path: screenshotPath,
        type: 'jpeg',
        quality: 85,
        fullPage: false // Captures only viewport
      });

      console.log(`Saved ${screenshotPath} (${i + 1}/${totalScreenshots})`);

      // Wait for remaining interval time
      if (i < totalScreenshots - 1) {
        const elapsed = Date.now() - timestamp;
        const remainingWait = Math.max(0, interval - elapsed);
        await page.waitForTimeout(remainingWait);
      }
    }

    console.log('Screenshot sequence completed');

  } catch (error) {
    console.error('Error:', error);
    await page.screenshot({ path: 'error.jpg', type: 'jpeg' });
    console.log('Saved error screenshot as error.jpg');
  } finally {
    await browser.close();
  }
})();
