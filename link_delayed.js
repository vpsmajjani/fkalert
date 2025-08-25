const puppeteer = require('puppeteer');

// Check if a URL is provided as a command-line argument
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
  
  try {
    const page = await browser.newPage();
    
    // Set longer timeout (30 seconds)
    await page.setDefaultNavigationTimeout(30000);
    
    // Navigate with network idle check
    await page.goto(userLink, { 
      waitUntil: 'networkidle0'
    });
    
    // Universal delay method (3 seconds)
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Get page content
    const content = await page.content();
    console.log(content);
    
  } catch (error) {
    console.error('Error during scraping:', error);
  } finally {
    await browser.close();
  }
})();
