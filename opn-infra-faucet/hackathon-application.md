# OPN Builders — Текст заявки

> Замінити: `MYTOKEN_ADDRESS`, `FAUCET_ADDRESS`, `TX_MYTOKEN`, `TX_FAUCET`, `YOUR_DOMAIN`, `YOUR_GITHUB`  
> Швидко: `bash scripts/apply-addresses.sh` (після заповнення змінних у скрипті)

## Project name

OPN Infrastructure Faucet

## One-line tagline

High-availability ERC20 faucet running on a self-hosted OPN Chain RPC node behind Nginx.

## Demo URL

https://faucet.YOUR_DOMAIN

## Repository URL

https://github.com/YOUR_GITHUB/opn-infra-faucet

## Contracts

| Contract | Address         | Network           | Deploy TX                                              |
| -------- | --------------- | ----------------- | ------------------------------------------------------ |
| MyToken  | MYTOKEN_ADDRESS | OPN Testnet (984) | https://testnet.iopn.tech/tx/TX_MYTOKEN                |
| Faucet   | FAUCET_ADDRESS  | OPN Testnet (984) | https://testnet.iopn.tech/tx/TX_FAUCET                 |

## Problem

Розробники DeFi-додатків на OPN Testnet залежать від централізованих публічних RPC-серверів
з жорстким rate-limiting. Відсутня стабільна інфраструктура розподілу тестових токенів,
що уповільнює цикл розробки та тестування.

## Solution

Децентралізований ERC20-кран, підключений до суверенного RPC-вузла OPN Chain
за Nginx-реверс-проксі. Архітектура виключає single point of failure та rate-limiting
публічних провайдерів, забезпечуючи безперебійний доступ до тестової ліквідності.

## How it works

1. Користувач підключає EVM-сумісний гаманець (MetaMask).
2. React-фронтенд автоматично перемикає Chain ID на OPN Testnet (984).
3. Запит проходить через Nginx → приватний RPC-ендпойнт → власний вузол OPN Chain.
4. Смарт-контракт Faucet перевіряє Sybil-захист (24-год cooldown через mapping).
5. Tendermint BFT фіналізує транзакцію за ~1 секунду; UI показує баланс у реальному часі.

## Roadmap

- Mainnet-деплой після launch OPN Chain.
- Інтеграція Neo ID (ZK-KYC) для розширеного Sybil-захисту крану.
- Node Telemetry dashboard — публічні метрики продуктивності вузла для екосистеми.
- Підтримка мультитокенного крану для інших ERC20-проєктів на OPN.
