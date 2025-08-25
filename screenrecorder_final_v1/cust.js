const puppeteer = require('puppeteer');

const userLink = process.argv[2];

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.goto(userLink, { waitUntil: 'networkidle2' });

  // Scroll to bottom
  await autoScroll(page);

  // Extract flight details
  const flights = await page.evaluate(() => {
    const results = [];
    const items = document.querySelectorAll('div.p23Ra6');

    items.forEach(item => {
      const airlineName = item.closest('div').querySelector('span')?.textContent.trim() || '';
      const flightNumber = item.closest('div').querySelectorAll('span')[1]?.textContent.trim() || '';
      const price = item.querySelector('.0+iF2, .O+iF2')?.textContent.trim() || '';
      
      // For time, you may need to inspect DOM and adjust selector accordingly
      const time = item.closest('div').querySelector('.dA8PvK')?.textContent.trim() || '';

      results.push({ airlineName, flightNumber, time, price });
    });

    return results;
  });

  console.log(JSON.stringify(flights, null, 2));

  await browser.close();
})();

// Scrolling function
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

