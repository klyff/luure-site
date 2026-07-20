# SovereignID.io — Corporate Website

Institutional website for **SovereignID.io**, a distributed sovereign identity infrastructure for governments and enterprises.

**Live domain:** <https://luure.com.br>

Domínio canônico do site institucional (PT-BR na raiz, inglês em `/en`). Todos os domínios legados redirecionam para `luure.com.br` (ver [docs/luure-canonical-policy.md](docs/luure-canonical-policy.md)).

## Stack

- Static HTML/CSS/Vanilla JavaScript
- Visual system adapted from `smartecm-site`
- Bilingual pages: English (`/`) and Portuguese (`/pt-br/`)
- Deploy target: Vercel

## Content source

Executive positioning, market data, product layers and roadmap were distilled from:

- `/Users/klyff/Downloads/SovereignID_io_BusinessPlan_v3.pdf`

The public site intentionally summarizes the business plan and omits confidential detail.

## Structure

```text
.
├── index.html
├── pt-br/
│   └── index.html
├── assets/
│   ├── css/styles.css
│   ├── js/main.js
│   └── img/logo.svg
├── favicon.svg
└── vercel.json
```

## Local preview

```bash
python3 -m http.server 8000
```

Open <http://localhost:8000>.

## Deploy

```bash
vercel --prod
```

Attach the custom domain:

```bash
vercel domains add luure.com.br
vercel domains add www.luure.com.br
```

DNS no Registro.br: ver [docs/DNS_LUURE.md](docs/DNS_LUURE.md).
