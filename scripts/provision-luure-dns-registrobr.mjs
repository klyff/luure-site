#!/usr/bin/env node
/**
 * Adiciona CNAME *.luure.com.br → cname.vercel-dns.com no Registro.br (FreeDNS).
 * Requer: REGISTROBR_USER, REGISTROBR_PASS
 */
import puppeteer from 'puppeteer';

const USER = process.env.REGISTROBR_USER;
const PASS = process.env.REGISTROBR_PASS;
const DOMAIN = 'luure.com.br';
const CNAME_TARGET = 'cname.vercel-dns.com';

const SUBDOMAINS = [
  'efolha',
  'gestao',
  'wallet',
  'licencas',
  'conselhos',
  'licitacoes',
  'cidadao',
  'cras',
  'esocial',
  'rh',
  'agent',
  'voce',
];

if (!USER || !PASS) {
  console.error('Defina REGISTROBR_USER e REGISTROBR_PASS');
  process.exit(1);
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function login(page) {
  await page.goto('https://registro.br/login', { waitUntil: 'networkidle2' });
  await page.waitForSelector('input[name="login.user"]', { timeout: 20000 });
  await page.type('input[name="login.user"]', USER, { delay: 20 });
  await page.type('input[name="login.password"]', PASS, { delay: 20 });
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle2' }),
    page.click('button.bt'),
  ]);
}

async function openDnsEditor(page) {
  await page.goto(`https://registro.br/painel/dominios/?dominio=${DOMAIN}`, {
    waitUntil: 'networkidle2',
  });
  await sleep(1500);
  const dnsLink = await page.$('a[href*="freedns"], a.edit-config[href*="freedns"]');
  if (!dnsLink) {
    throw new Error('Link FreeDNS não encontrado — ative Modo Avançado no Registro.br');
  }
  await Promise.all([page.waitForNavigation({ waitUntil: 'networkidle2' }), dnsLink.click()]);
}

async function recordExists(page, host) {
  return page.evaluate((host, domain) => {
    const text = document.body.innerText;
    return text.includes(`${host}.${domain}`) || text.includes(`${host} ${domain}`);
  }, host, DOMAIN);
}

async function addCname(page, host) {
  const exists = await recordExists(page, host);
  if (exists) {
    console.log(`✓ ${host}.${DOMAIN} já existe`);
    return;
  }

  await page.waitForSelector('#new-rr-button', { timeout: 15000 });
  await page.click('#new-rr-button');
  await page.waitForSelector('#add-rr-ownername', { timeout: 10000 });
  await page.evaluate(() => {
    document.querySelector('#add-rr-ownername').value = '';
    document.querySelector('#add-rr-type').value = 'CNAME';
  });
  await page.type('#add-rr-ownername', host, { delay: 15 });

  const cnameField =
    (await page.$('#add-rr-cname')) ||
    (await page.$('#add-rr-target')) ||
    (await page.$('input[name="rr.cname"]'));
  if (!cnameField) {
    throw new Error('Campo CNAME não encontrado no editor FreeDNS');
  }
  await cnameField.click({ clickCount: 3 });
  await cnameField.type(CNAME_TARGET, { delay: 15 });

  await page.click('#add-button');
  await sleep(800);
  console.log(`+ ${host}.${DOMAIN} CNAME ${CNAME_TARGET}`);
}

async function save(page) {
  const saveBtn =
    (await page.$('input[type="submit"][value*="Salvar"]')) ||
    (await page.$('input[type="submit"]'));
  if (saveBtn) {
    await Promise.all([page.waitForNavigation({ waitUntil: 'networkidle2' }), saveBtn.click()]);
    console.log('Alterações salvas no Registro.br');
  }
}

async function main() {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  page.setDefaultTimeout(30000);

  try {
    console.log('Login Registro.br…');
    await login(page);
    console.log('Abrindo editor DNS…');
    await openDnsEditor(page);

    for (const sub of SUBDOMAINS) {
      await addCname(page, sub);
    }

    await save(page);
    console.log('DNS provisionado. Aguarde propagação (minutos a horas).');
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
