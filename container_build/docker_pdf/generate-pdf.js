// Run using 'node generate-pdf.js'
const puppeteer = require('puppeteer');

var args = process.argv.slice(2);
var url = args[0]

console.log('Generating pdf for: ', url);

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    // TODO should not be running with no-sandbox really, see
    // https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#setting-up-chrome-linux-sandbox
    args: [
      "--no-sandbox",
      "--disable-gpu",
    ]
  });
  const page = await browser.newPage();

  await page.goto(url, {
    waitUntil: 'networkidle2',
  });
  await page.pdf({ path: 'stroom-docs.pdf', format: 'a4' });

  await browser.close();
})();
