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
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1920,1080']
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1080 });

  try {
    await page.goto(userLink, { waitUntil: 'networkidle0' });

    // Wait for modal to appear (up to 10 seconds)
    await page.waitForSelector('.visitors-agreement-modal', { timeout: 10000 });

    // Click the button using the exact CSS selector from your inspection
    await page.click('.visitors-agreement-modal .btn-visitors-agreement-accept');
    console.log('Successfully clicked age verification button');

    // Wait for the modal to disappear
    await page.waitForFunction(() => !document.querySelector('.visitors-agreement-modal'), { timeout: 5000 });

    // Recording parameters
    const totalScreenshots = 30;
    const interval = 2000; // 2 seconds between screenshots (30 screenshots in 60 seconds)
    const screenshotQuality = 80; // JPG quality (0-100)

    // Find the next available recording number
    let recordingNumber = 1;
    while (fs.existsSync(path.join(outputDir, `${recordingPrefix}${recordingNumber}.jpg`))) {
      recordingNumber++;
    }

    console.log(`Starting screenshot sequence (${totalScreenshots} screenshots)`);

    // Take screenshots at regular intervals
    for (let i = 0; i < totalScreenshots; i++) {
      const screenshotPath = path.join(outputDir, `${recordingPrefix}${recordingNumber}_${i + 1}.jpg`);
      
      await page.screenshot({
        path: screenshotPath,
        type: 'jpeg',
        quality: screenshotQuality
      });
      
      console.log(`Saved ${screenshotPath}`);
      
      if (i < totalScreenshots - 1) {
        await new Promise(resolve => setTimeout(resolve, interval));
      }
    }

    console.log('Screenshot sequence completed');

  } catch (error) {
    console.error('Error:', error.message);
    await page.screenshot({ path: 'error.jpg', type: 'jpeg' });
    console.log('Saved error screenshot as error.jpg');
  } finally {
    await browser.close();
  }
})();
