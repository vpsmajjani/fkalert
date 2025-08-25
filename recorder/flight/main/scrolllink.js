const puppeteer = require('puppeteer');

const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/chromium',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.goto(userLink, { waitUntil: 'networkidle2' });

  // Scroll to the bottom to load dynamic content
  await autoScroll(page);

  // Capture the fully loaded HTML
  const content = await page.content();
  console.log(content);

  await browser.close();
})();

// Auto-scroll function
async function autoScroll(page) {
  await page.evaluate(async () => {
    await new Promise((resolve) => {
      let totalHeight = 0;
      const distance = 300;
      const timer = setInterval(() => {
        const scrollHeight = document.body.scrollHeight;
        window.scrollBy(0, distance);
        totalHeight += distance;

        if (totalHeight >= scrollHeight) {
          clearInterval(timer);
          resolve();
        }
      }, 200);
    });
  });
}

