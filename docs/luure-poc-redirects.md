# Redirects 301 — PoCs para luure.com.br

Templates `vercel.json` para mesclar no repositório de cada projeto Vercel.
Manter os domínios antigos como aliases no mesmo projeto.

## sovereignid-sou

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-voce.vercel.app" }],
      "destination": "https://sou.luure.com.br/:path*",
      "permanent": true
    },
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "voce.luure.com.br" }],
      "destination": "https://sou.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## frontend (efolha, gestao, wallet)

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "efolha.sovereignid.cloud" }],
      "destination": "https://efolha.luure.com.br/:path*",
      "permanent": true
    },
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "gestao.sovereignid.cloud" }],
      "destination": "https://gestao.luure.com.br/:path*",
      "permanent": true
    },
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "wallet.sovereignid.cloud" }],
      "destination": "https://wallet.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-licencas

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-licencas.vercel.app" }],
      "destination": "https://licencas.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-conselhos

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-conselhos.vercel.app" }],
      "destination": "https://conselhos.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-licitacoes

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-licitacoes.vercel.app" }],
      "destination": "https://licitacoes.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-cidadao

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-cidadao.vercel.app" }],
      "destination": "https://cidadao.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-cras

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-cras.vercel.app" }],
      "destination": "https://cras.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-esocial

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-esocial.vercel.app" }],
      "destination": "https://esocial.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```

## sovereignid-rh

```json
{
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "sovereignid-rh.vercel.app" }],
      "destination": "https://rh.luure.com.br/:path*",
      "permanent": true
    }
  ]
}
```
