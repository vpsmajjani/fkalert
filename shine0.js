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
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--single-process'
    ],
    headless: 'new', // Use new headless mode
    timeout: 60000 // Increase launch timeout
  });
  
  const page = await browser.newPage();
  await page.setDefaultNavigationTimeout(60000);
  await page.setDefaultTimeout(30000);

  try {
    console.log('Navigating to URL...');
    await page.goto(userLink, { 
      waitUntil: 'domcontentloaded',
      timeout: 60000
    });

    console.log('Looking for mobile input field...');
    // Try multiple selector options
    const inputSelector = await Promise.race([
      page.waitForSelector('.cls_base_2_input.animation-input', { visible: true, timeout: 30000 }),
      page.waitForSelector('input[type="tel"]', { visible: true, timeout: 30000 }),
      page.waitForSelector('input[name="mobile"]', { visible: true, timeout: 30000 })
    ]).catch(() => null);

    if (!inputSelector) {
      throw new Error('Could not find mobile number input field');
    }

    console.log('Entering mobile number...');
    await inputSelector.type(mobileNumber, { delay: 50 });

    console.log('Looking for OTP button...');
    const otpButton = await Promise.race([
      page.waitForSelector('button#id_base_2_request_otp', { visible: true, timeout: 30000 }),
      page.waitForSelector('.cls_requestOtp', { visible: true, timeout: 30000 }),
      page.waitForSelector('button:has-text("Send OTP")', { visible: true, timeout: 30000 })
    ]).catch(() => null);

    if (!otpButton) {
      throw new Error('Could not find OTP button');
    }

    console.log('Clicking OTP button...');
    await otpButton.click();

    // Wait for OTP process to complete
    await page.waitForTimeout(5000);
    console.log('OTP process completed');

    // Take screenshot for verification
    await page.screenshot({ path: 'otp_sent.png' });
    console.log('Screenshot saved as otp_sent.png');

  } catch (error) {
    console.error('Error:', error);
    // Save error screenshot
    await page.screenshot({ path: 'error.png' });
    console.log('Error screenshot saved as error.png');
  } finally {
    await browser.close();
  }
})();
