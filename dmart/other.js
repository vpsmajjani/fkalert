const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/chromium', // Specify the correct path to the browser
    args: ['--no-sandbox', '--disable-setuid-sandbox'] // Add flags to disable sandbox
  });
  const page = await browser.newPage();
  await page.goto('https://www.dmart.in/product/premia-badam-american?selectedProd=18001');
  const content = await page.content();
  console.log(content);
  await browser.close();
})();

