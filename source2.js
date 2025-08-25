const puppeteer = require('puppeteer');

// Check if a URL is provided as a command-line argument
const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome', // Path to the browser, adjust if necessary
    args: ['--no-sandbox', '--disable-setuid-sandbox'] // Disable sandboxing if needed
  });

  const page = await browser.newPage();

  // Navigate to the provided URL
  await page.goto(userLink, {
    waitUntil: 'domcontentloaded', // Wait until the DOM is fully loaded
  });

  // Extract all the HTTPS links from the page
  const httpsLinks = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('a'))
      .map(link => link.href)
      .filter(href => href.startsWith('https://'));
  });

  // Print cleaned links
  console.log('HTTPS Links found on the page:');
  if (httpsLinks.length === 0) {
    console.log('No links found.');
  } else {
    httpsLinks.forEach(link => {
      console.log(link.replace(/^https:\/\//, ''));
    });
  }

  await browser.close();
})();

