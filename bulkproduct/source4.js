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

  const uniqueLinks = await page.evaluate(() => {
    const links = Array.from(document.querySelectorAll('a'))
      .map(link => link.href)
      .filter(href => href.includes('lid=')) // Filter links with 'lid'
      .map(href => href.split('&lid=')[0]); // Crop after 'lid='

    return [...new Set(links)]; // Remove duplicates
  });

  console.log('Unique Links:');
  if (uniqueLinks.length === 0) {
    console.log('No matching links found.');
  } else {
    uniqueLinks.forEach(link => console.log(link));
  }

  await browser.close();
})();

