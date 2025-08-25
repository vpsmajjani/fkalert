const puppeteer = require('puppeteer');

// Check if a URL is provided as a command-line argument
const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',  // Path to the browser, adjust it if necessary
    args: ['--no-sandbox', '--disable-setuid-sandbox']  // Disable sandboxing (sometimes needed in certain environments)
  });

  const page = await browser.newPage();
  
  // Navigate to the provided URL
  await page.goto(userLink, {
    waitUntil: 'domcontentloaded',  // Wait until the DOM is fully loaded
  });

  // Extract all the HTTPS links from the page
  const httpsLinks = await page.evaluate(() => {
    // Get all anchor tags on the page
    const links = Array.from(document.querySelectorAll('a'));
    
    // Filter the links to get only those that start with 'https://'
    const httpsLinks = links
      .map(link => link.href)  // Extract href attribute from each anchor tag
      .filter(href => href.startsWith('https://'));  // Filter for 'https://' links

    return httpsLinks;  // Return the filtered array of HTTPS links
  });

  // Print all the HTTPS links
  console.log('HTTPS Links found on the page:');
  console.log(httpsLinks);

  await browser.close();
})();

