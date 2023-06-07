// Run using 'node generate-pdf.js'
const puppeteer = require('puppeteer');

var args = process.argv.slice(2);
var url = args[0]

console.log('Generating stroom-docs.pdf for url: ', url);

(async () => {
  const browser = await puppeteer.launch({
    headless: "new",
    // TODO should not be running with no-sandbox really, see
    // https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#setting-up-chrome-linux-sandbox
    args: [
      "--no-sandbox",
      "--disable-gpu",
    ]
  });
  const page = await browser.newPage();

  await page.setDefaultNavigationTimeout(300000);
  await page.goto(url, {
    waitUntil: 'networkidle2'});

  // If networkidle2 doesn't work then try
  //await page.goto(url, {
    //waitUntil: 'domcontentloaded'});
  //await page.waitForSelector('h1');

  await page.pdf({ 
    path: 'stroom-docs.pdf', 
    format: 'a4', 
    timeout: 300000 });

  await browser.close();
})();
