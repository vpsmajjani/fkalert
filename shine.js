const puppeteer = require('puppeteer');

const userLink = process.argv[2];
const mobileNumber = '8088861333';

if (!userLink) {
  console.log('Please provide a URL as the first argument.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage'
    ],
    headless: 'new'
  });
  
  const page = await browser.newPage();
  await page.setViewport({ width: 1366, height: 768 });
  await page.setDefaultNavigationTimeout(60000);
  await page.setDefaultTimeout(30000);

  try {
    console.log('Navigating to URL...');
    await page.goto(userLink, { 
      waitUntil: 'networkidle2',
      timeout: 60000
    });

    // Multiple selector options for mobile input
    console.log('Locating mobile input field...');
    const inputSelector = await Promise.race([
      page.waitForSelector('input.cls_base_2_input.animation-input.mt-0', { visible: true, timeout: 30000 }),
      page.waitForSelector('input[aria-label="Email/Mobile"]', { visible: true, timeout: 30000 }),
      page.waitForSelector('input[type="text"]', { visible: true, timeout: 30000 })
    ]).catch(() => null);

    if (!inputSelector) {
      const screenshotPath = 'input_not_found.png';
      await page.screenshot({ path: screenshotPath });
      throw new Error(`Mobile input field not found. Screenshot saved as ${screenshotPath}`);
    }

    console.log('Entering mobile number...');
    await inputSelector.click({ clickCount: 3 }); // Triple click to select existing text if any
    await inputSelector.type(mobileNumber, { delay: 50 });

    // Verify input value
    const enteredValue = await inputSelector.evaluate(el => el.value);
    if (enteredValue !== mobileNumber) {
      throw new Error(`Failed to enter mobile number. Current value: ${enteredValue}`);
    }

    console.log('Mobile number entered successfully:', enteredValue);

    // Continue with OTP button click...
    // [Your existing OTP button code here]

  } catch (error) {
    console.error('Error:', error.message);
    await page.screenshot({ path: 'error.png' });
    console.log('Error screenshot saved as error.png');
  } finally {
    await browser.close();
  }
})();
