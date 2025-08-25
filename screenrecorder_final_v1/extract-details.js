const fs = require('fs');
const cheerio = require('cheerio');

const html = fs.readFileSync('output.html', 'utf-8');
const $ = cheerio.load(html);

// Iterate over flight containers
$('.jvoo4S').each((i, el) => {
  const airline = $(el).find('span').eq(0).text().trim();
  const flightNo = $(el).find('span').eq(1).text().trim();
  const price = $(el).parent().nextAll('.p23Ra6').find('.O+irE2').first().text().trim();

  console.log(`${airline} ${flightNo} ${price}`);
});

