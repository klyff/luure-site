# Playbook de demonstração das PoCs

Roteiros curtos para apresentar as PoCs do São Paulo Identity Trust a stakeholders. Use `*.luure.com.br` quando o DNS estiver ativo; caso contrário, os fallbacks `*.vercel.app` listados abaixo.

## Arquitetura da demo

```mermaid
flowchart TB
  subgraph hub [Portal Sou]
    Login[Entrar demo João Silva]
    Carteira[Minha Carteira - galeria]
    Servicos[Serviços conectados]
  end

  subgraph walletApp [wallet.luure.com.br]
    Oferta[/oferta - aceitar credencial]
    Apresentar[/apresentar - prova ZKP]
  end

  subgraph verifier [Verificadores PoC]
    Efolha[/verificar + Simular sucesso]
    Licitacoes[/verificar + Simular apresentação]
    Cras[/verificar + Simular elegível]
  end

  subgraph agent [agent.luure.com.br]
    API[OID4VP /verify/request]
  end

  Login --> Carteira
  Carteira -->|CTA carteira completa| walletApp
  Servicos -->|link externo| verifier
  verifier -->|QR real| walletApp
  verifier -->|botão simular| verifier
  walletApp -.->|quando online| agent
  verifier -.->|quando online| agent
```

## URLs de acesso

| PoC | Canônico | Fallback Vercel |
|-----|----------|-----------------|
| Portal Sou | https://sou.luure.com.br | https://sovereignid-sou.vercel.app |
| e-Folha | https://efolha.luure.com.br | https://sovereignid-efolha.vercel.app |
| Gestão RH | https://gestao.luure.com.br | https://sovereignid-gestao.vercel.app |
| Wallet | https://wallet.luure.com.br | https://sovereignid-wallet.vercel.app |
| Licenças | https://licencas.luure.com.br | https://sovereignid-licencas.vercel.app |
| Licitações | https://licitacoes.luure.com.br | https://sovereignid-licitacoes.vercel.app |
| Cidadão | https://cidadao.luure.com.br | https://sovereignid-cidadao.vercel.app |
| CRAS | https://cras.luure.com.br | https://sovereignid-cras.vercel.app |
| eSocial | https://esocial.luure.com.br | https://sovereignid-esocial.vercel.app |
| RH | https://rh.luure.com.br | https://sovereignid-rh.vercel.app |
| Agent OID4VC | https://agent.luure.com.br | https://agent.sovereignid.cloud |

## Roteiro mínimo (15 minutos)

### 1. Portal Sou (3 min)

**URL:** https://sou.luure.com.br ou https://sovereignid-sou.vercel.app

1. `/entrar` → clicar **Entrar com gov.br** (qualquer CPF; usuário demo: João da Silva)
2. `/` → mostrar credenciais, feed de atividade e cards de serviços
3. `/minha-carteira` → abrir credencial; clicar **Abrir carteira completa** para ir à wallet standalone
4. `/servicos` → abrir **e-Folha SP** em nova aba

### 2. e-Folha (4 min)

**URL:** https://efolha.luure.com.br

1. `/` → **Iniciar verificação**
2. `/verificar` → mostrar QR de prova
3. Clicar **Simular sucesso** (plano B se o agent estiver offline)
4. `/dashboard` → painel do servidor liberado
5. `/servicos` → simular consulta de holerite com prova verificável

### 3. Wallet standalone (3 min)

**URL:** https://wallet.luure.com.br

1. `/` → grade de credenciais e DID
2. `/oferta` → **Aceitar credencial** (oferta de demonstração)
3. `/apresentar` → selecionar modo ZKP → **Apresentar prova**

### 4. Licitações — prova cruzada PoC2 (4 min)

**URL:** https://licitacoes.luure.com.br

1. Login: `licitacao@detran.sp.gov.br` / `Demo@2025!`
2. `/editais` → abrir um edital
3. `/verificar` → **Gerar solicitação** → **Simular apresentação do profissional**
4. `/resultado/:id` → resultado com nota de ZKP

## Credenciais de demonstração

| Portal | Login | Senha |
|--------|-------|-------|
| Gestão RH / RH gestor | `gestor.demo@prodesp.sp.gov.br` | `Demo@2025!` |
| Licenças | `eng.demo@crea-sp.org.br` | `Demo@2025!` |
| Conselhos | `emissor@crea-sp.org.br` | `Demo@2025!` |
| Licitações | `licitacao@detran.sp.gov.br` | `Demo@2025!` |
| Cidadão | `cidadao.demo@teste.gov.br` | `Demo@2025!` |
| CRAS | `cras.demo@seds.sp.gov.br` | `Demo@2025!` |
| Portal Sou / e-Folha | qualquer CPF + Entrar / Simular | — |
| eSocial | pré-logado como João da Silva | — |

## Botões de simulação (plano B)

Use quando `agent.luure.com.br` estiver indisponível ou a demo precisar ser rápida.

| App | Botão | Rota |
|-----|-------|------|
| e-Folha | Simular sucesso | `/verificar` |
| Licitações | Simular apresentação do profissional | `/verificar` |
| CRAS | Simular cidadão elegível / não elegível | `/verificar` |
| Cidadão | Simular apresentação (demo) | `/comprovar` |
| RH | Simular apresentação do candidato | `/verificar` |

## Roteiros estendidos por PoC

### Gestão RH + Wallet (emissão → recebimento)

1. **Gestão** (`gestao.luure.com.br`): login gestor → `/funcionarios` → `/emitir` → emitir credencial → QR `voce-br://offer/...`
2. **Wallet** (`wallet.luure.com.br`): `/oferta` → aceitar credencial

### Elegibilidade social (Cidadão + CRAS)

1. **Cidadão**: login → `/beneficios` → `/comprovar` → gerar prova ZKP → simular apresentação
2. **CRAS**: login assistente → `/verificar` → simular cidadão elegível → `/atendimentos`

### eSocial + RH (PoC4)

1. **eSocial**: `/vinculos` → detalhe com campos ZKP → `/apresentar` → gerar prova
2. **RH**: alternar perfil **Servidor** (`/rendimentos`) → **Gestor** (`/rh/emitir`) → **Verificador** (`/verificar`)

## Validação automatizada

```bash
# Smoke test geral da migração
./scripts/validate-luure-migration.sh

# Validação de rotas internas (canônico + fallback)
./scripts/validate-poc-navigation.sh
```

O relatório é gravado em `docs/poc-navigation-report.md`.

## Checklist pré-demo

- [ ] Portal Sou abre em `/` e `/minha-carteira` sem 404
- [ ] Botão **Simular sucesso** visível no e-Folha `/verificar`
- [ ] Wallet `/oferta` e `/apresentar` respondem 200
- [ ] Agent health: `curl https://agent.luure.com.br/health` retorna `{"status":"ok"}` (opcional)
- [ ] Credenciais demo anotadas para portais com login por e-mail
