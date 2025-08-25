const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto(process.argv[2], { waitUntil: 'networkidle2' });

    const statuses = await page.evaluate(() => {
        const rows = Array.from(document.querySelectorAll('table tbody tr'));
        return rows.map(row => {
            const tds = row.querySelectorAll('td');
            return tds.length > 2 ? tds[2].innerText.trim() : null;  // pick 3rd <td> (Current Status)
        }).filter(Boolean); // remove any nulls
    });

    statuses.forEach(status => console.log(status));

    await browser.close();
})();

