const puppeteer = require('puppeteer');

const userLink = process.argv[2] || 'https://www.shine.com/myshine/login/?frgt_pwd=true';

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    headless: false // Set to true after testing
  });
  const page = await browser.newPage();
  
  try {
    // Set realistic browser attributes
    await page.setViewport({ width: 1366, height: 768 });
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

    console.log('Navigating to page...');
    await page.goto(userLink, { 
      waitUntil: 'networkidle2',
      timeout: 60000 
    });

    // Add delay before looking for popup (5 seconds)
    console.log('Waiting for popup to appear...');
    await page.waitForTimeout(5000);

    // Try to close popup with multiple approaches
    try {
      console.log('Attempting to close popup...');
      
      // Approach 1: Direct click with delay
      await page.waitForSelector('#id_fpCancel', { 
        visible: true, 
        timeout: 10000 
      });
      await page.waitForTimeout(1000); // Additional delay before click
      await page.click('#id_fpCancel');
      console.log('Popup closed successfully');
      
    } catch (error) {
      console.log('Trying alternative approach...');
      
      // Approach 2: Check all frames
      const frames = await page.frames();
      for (const frame of frames) {
        try {
          await frame.waitForSelector('#id_fpCancel', { visible: true, timeout: 5000 });
          await frame.click('#id_fpCancel');
          console.log('Closed popup in iframe');
          break;
        } catch (frameError) {
          // Continue to next frame
        }
      }
    }

    // Final content capture
    await page.waitForTimeout(2000); // Wait for any post-close animations
    const content = await page.content();
    console.log('Page content length:', content.length);
    // console.log(content); // Uncomment to see full HTML

  } catch (error) {
    console.error('Main error:', error);
  } finally {
    await browser.close();
  }
})();
