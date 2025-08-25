const puppeteer = require('puppeteer');

// Check if a URL is provided as a command-line argument
const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/snap/bin/chromium', // Specify the correct path to the browser
    args: ['--no-sandbox', '--disable-setuid-sandbox'] // Add flags to disable sandbox
  });
  const page = await browser.newPage();
  await page.goto(userLink);  // Use the URL provided by the user
  const content = await page.content();
  console.log(content);
  await browser.close();
})();

