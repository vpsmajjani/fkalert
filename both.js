const puppeteer = require('puppeteer');

// Check if a URL is provided as a command-line argument
const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  // Launch the browser
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome', // Specify the correct path to the browser
    args: ['--no-sandbox', '--disable-setuid-sandbox'] // Add flags to disable sandbox
  });

  // Open a new page
  const page = await browser.newPage();
  
  // Navigate to the provided URL
  await page.goto(userLink);  // Use the URL provided by the user

  // Capture and log the page content (HTML)
  const content = await page.content();
  console.log(content);

  // Take a screenshot of the page
  await page.screenshot({ path: 'screenshot.png', fullPage: true });  // Save the screenshot as 'screenshot.png'

  console.log('Screenshot saved as screenshot.png');

  // Close the browser
  await browser.close();
})();

