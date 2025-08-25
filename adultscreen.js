const puppeteer = require('puppeteer');

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

  try {
    await page.goto(userLink, { waitUntil: 'networkidle0' });
    
    // Wait for modal to appear (up to 10 seconds)
    await page.waitForSelector('.visitors-agreement-modal', { timeout: 10000 });

    // Click the button using the exact CSS selector from your inspection
    await page.click('.visitors-agreement-modal .btn-visitors-agreement-accept');
    console.log('Successfully clicked age verification button');

    // Wait for the modal to disappear
    await page.waitForFunction(() => !document.querySelector('.visitors-agreement-modal'), { timeout: 5000 });

    // Take screenshot
    await page.screenshot({ path: 'screenshot.png' });
    console.log('Screenshot saved as screenshot.png');

  } catch (error) {
    console.error('Error:', error.message);
    await page.screenshot({ path: 'error.png' });
    console.log('Saved error screenshot as error.png');
  } finally {
    await browser.close();
  }
})();
