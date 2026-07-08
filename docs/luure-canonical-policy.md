# Política canônica — luure.com.br

## Princípio

**`*.luure.com.br` é o domínio principal** — serve o conteúdo real de cada app.

**Todos os outros domínios** (`sovereignid.cloud`, `*.vercel.app`, `sovereignid.smartecm.io`, `idsoberano.com`, etc.) fazem **apenas redirect 301/308** para a URL equivalente em `luure.com.br`.

## Mapa de redirects

### Site institucional → `sovereignid-home`

| Origem | Destino |
|--------|---------|
| `sovereignid.cloud` | `luure.com.br` |
| `www.sovereignid.cloud` | `luure.com.br` |
| `idsoberano.com` | `luure.com.br` |
| `sovereignid.tech` | `luure.com.br` |
| `sovereignid.global` | `luure.com.br` |
| `sovereignid.smartecm.io` | `luure.com.br` |
| `www.luure.com.br` | `luure.com.br` |

### PoC 1 (efolha, gestao, wallet) → projeto `frontend`

| Origem | Destino |
|--------|---------|
| `efolha.sovereignid.cloud` | `efolha.luure.com.br` |
| `gestao.sovereignid.cloud` | `gestao.luure.com.br` |
| `wallet.sovereignid.cloud` | `wallet.luure.com.br` |

### PoCs 2–4 → projetos `sovereignid-*`

| Origem | Destino |
|--------|---------|
| `sovereignid-voce.vercel.app` | `voce.luure.com.br` |
| `sovereignid-licencas.vercel.app` | `licencas.luure.com.br` |
| `sovereignid-conselhos.vercel.app` | `conselhos.luure.com.br` |
| `sovereignid-licitacoes.vercel.app` | `licitacoes.luure.com.br` |
| `sovereignid-cidadao.vercel.app` | `cidadao.luure.com.br` |
| `sovereignid-cras.vercel.app` | `cras.luure.com.br` |
| `sovereignid-esocial.vercel.app` | `esocial.luure.com.br` |
| `sovereignid-rh.vercel.app` | `rh.luure.com.br` |
| `sovereignid-efolha.vercel.app` | `efolha.luure.com.br` |
| `sovereignid-gestao.vercel.app` | `gestao.luure.com.br` |
| `sovereignid-wallet.vercel.app` | `wallet.luure.com.br` |

## Sintaxe Vercel (redirects)

```json
{
  "source": "/:path(.*)",
  "has": [{ "type": "host", "value": "DOMINIO-ANTIGO" }],
  "destination": "https://SUBDOMINIO.luure.com.br/:path",
  "permanent": true
}
```

## Pré-requisito

DNS de `luure.com.br` configurado no Registro.br (ver [DNS_LUURE.md](DNS_LUURE.md)). Sem DNS, os redirects levam a destinos inacessíveis.
