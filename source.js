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
    executablePath: '/usr/bin/google-chrome',  // Path to the browser, adjust it if necessary
    args: ['--no-sandbox', '--disable-setuid-sandbox']  // Disable sandboxing (sometimes needed in certain environments)
  });
  
  // Open a new page
  const page = await browser.newPage();
  
  // Navigate to the provided URL
  await page.goto(userLink, {
    waitUntil: 'domcontentloaded',  // Wait until the DOM is fully loaded
  });
  
  // Get the full source (HTML) of the page
  const content = await page.content(); // This gets the HTML content of the page
  
  // Print the page content (HTML)
  console.log(content);
  
  // Close the browser after capturing the content
  await browser.close();
})();

