const puppeteer = require('puppeteer');

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

  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
  await page.setExtraHTTPHeaders({
    'Accept-Language': 'en-US,en;q=0.9',
  });

  await page.goto(userLink, {
    waitUntil: 'networkidle2',
  });

  await new Promise(resolve => setTimeout(resolve, 5000));

  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await new Promise(resolve => setTimeout(resolve, 2000));

  const httpsLinks = await page.evaluate(() => {
    const links = Array.from(document.querySelectorAll('a, [data-href]'));
    return links
      .map(link => link.href || link.getAttribute('data-href'))
      .filter(href => href && href.startsWith('https://'));
  });

  console.log('HTTPS Links found on the page:\n');
  console.log(httpsLinks.join('\n'));

  await browser.close();
})();

