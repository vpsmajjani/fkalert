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

  const page = await browser.newPage();

  await page.goto(userLink, {
    waitUntil: 'domcontentloaded',
  });

  const filteredLinks = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('a'))
      .map(link => link.href)
      .filter(href => href.includes('lid=')) // Filter links with 'lid'
      .map(href => {
        const baseLink = href.split('&lid=')[0]; // Crop after 'lid='
        return baseLink;
      });
  });

  console.log('Filtered and Cropped Links:');
  if (filteredLinks.length === 0) {
    console.log('No matching links found.');
  } else {
    filteredLinks.forEach(link => console.log(link));
  }

  await browser.close();
})();

