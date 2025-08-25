const puppeteer = require('puppeteer');

const userLink = process.argv[2] || 'https://www.shine.com/myshine/login/?frgt_pwd=true';

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    headless: false // Run in non-headless mode for debugging
  });
  const page = await browser.newPage();
  
  try {
    // Set viewport and user agent to mimic a real browser
    await page.setViewport({ width: 1366, height: 768 });
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

    console.log('Navigating to page...');
    await page.goto(userLink, { 
      waitUntil: 'networkidle2',
      timeout: 60000 
    });

    // Try to close popup if it exists
    try {
      console.log('Looking for popup close button...');
      await page.waitForSelector('#id_fpCancel', { 
        visible: true, 
        timeout: 10000 
      });
      await page.click('#id_fpCancel');
      console.log('Popup closed successfully');
      await page.waitForTimeout(1000);
    } catch (popupError) {
      console.log('No popup found or could not close it:', popupError.message);
    }

    // Alternative approach: check for iframes
    const frames = await page.frames();
    for (const frame of frames) {
      try {
        const closeButton = await frame.$('#id_fpCancel');
        if (closeButton) {
          console.log('Found close button in iframe');
          await closeButton.click();
          break;
        }
      } catch (frameError) {
        console.log('Error checking frame:', frameError.message);
      }
    }

    // Get final content
    const content = await page.content();
    console.log('Page content length:', content.length);
    // console.log(content); // Uncomment to see full HTML

  } catch (error) {
    console.error('Main error:', error);
  } finally {
    await browser.close();
  }
})();
