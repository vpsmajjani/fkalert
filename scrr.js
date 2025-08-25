const puppeteer = require('puppeteer');

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
  
  // Set a longer default navigation timeout (30 seconds)
  await page.setDefaultNavigationTimeout(30000);
  
  try {
    // Navigate to page with networkidle wait
    await page.goto(userLink, { 
      waitUntil: 'networkidle0'
    });

    // Universal delay method that works in all versions
    await new Promise(resolve => setTimeout(resolve, 3000)); // 3 second delay

    // Alternative: wait for specific element
    // await page.waitForFunction(() => document.readyState === 'complete');

    // Take screenshot
    await page.screenshot({ path: 'screenshot.png' });
    console.log('Screenshot saved as screenshot.png');
  } catch (error) {
    console.error('Error during scraping:', error);
  } finally {
    await browser.close();
  }
})();
