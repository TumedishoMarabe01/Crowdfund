# Crowdfund Campaign

<img width="1897" height="868" alt="Screenshot 2026-10-28 155336" src="https://github.com/user-attachments/assets/833454c7-e43a-4624-bfeb-067ff81d6a71" />
<img width="1907" height="863" alt="image" src="https://github.com/user-attachments/assets/df70ea23-a2f7-4b91-b7f8-6d916f0b1f21" />


A local Ethereum crowdfunding dApp built with Solidity, Foundry/Remix tests, Viem, and a plain HTML/CSS/JavaScript frontend.

## Features

- Campaign goal and deadline stored in a Solidity smart contract
- ETH contributions from multiple backers
- Creator withdrawal after the deadline when the goal is reached
- Backer refunds after the deadline when the goal is missed
- MetaMask wallet connection through EIP-6963 and legacy `window.ethereum`
- Campaign state, transaction status, and contract events displayed in the web app

## Project Structure

```text
contracts/Campaign.sol       Crowdfunding smart contract
web/index.html               Web interface
web/app.js                   Wallet and contract integration
web/style.css                Page styles
web/vendor/viem.js           Browser Viem library
deployment.json              Local deployment address, chain details, and ABI
tests/Campaign_test.sol      Remix Solidity tests
tests/Backer.sol             Test helper contract
foundry.toml                 Foundry project configuration
```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`anvil`, `forge`, and `cast`)
- [MetaMask](https://metamask.io/) or another compatible browser wallet
- Python 3, or another static HTTP server

## Run Locally

### 1. Start Anvil

From the project directory, start a local Ethereum node:

```powershell
cd C:\Blockchain\Crowdfund
anvil
```

Anvil runs on `http://127.0.0.1:8545` with chain ID `31337` by default.

Keep this terminal running.

### 2. Deploy the Campaign contract

In a second terminal, deploy the contract with your preferred Anvil private key, goal, and duration. For example, the following uses Anvil's first default account and creates a campaign with a 1 ETH goal lasting 60 minutes:

```powershell
cd C:\Blockchain\Crowdfund
forge create contracts/Campaign.sol:Campaign `
  --rpc-url http://127.0.0.1:8545 `
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 `
  --constructor-args 1000000000000000000 60
```

Update [deployment.json](deployment.json) with the newly deployed address. Also check that `chainId`, `rpcUrl`, `deployBlock`, and `abi` match your deployment.

You can verify that code exists at the configured address with:

```powershell
cast code 0x5FbDB2315678afecb367f032d93F642f64180aa3 --rpc-url http://127.0.0.1:8545
```

Replace the address with the address returned by `forge create`. Its output should begin with contract bytecode rather than `0x`.

### 3. Configure MetaMask

Add the local network to MetaMask:

- Network name: `Anvil (local)`
- RPC URL: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Currency symbol: `ETH`

Then import an Anvil test account only when needed for local testing. Never use an Anvil private key or any other development key on a public network.

### 4. Serve the frontend

From the project root:

```powershell
cd C:\Blockchain\Crowdfund
python -m http.server 8080
```

Open:

```text
http://localhost:8080/web/
```

The **Connect MetaMask** button should appear when MetaMask is installed and has injected its provider. If no button appears, reload the page after enabling MetaMask or check the browser console for errors.

## Tests

The Solidity tests in `tests/` are written for Remix's Solidity Unit Testing plugin. Open the project in Remix and run `tests/Campaign_test.sol` with the Remix test environment.

The Foundry configuration also treats the `tests/` directory as project source through `foundry.toml`, but the file currently imports Remix-specific `remix_tests.sol` and is intended primarily for Remix.

## Contract Rules

- The goal must be greater than zero.
- The duration must be greater than zero minutes.
- Contributions must be greater than zero ETH.
- Contributions close when the deadline is reached.
- Only the creator can withdraw.
- Withdrawal succeeds only after the deadline when the total raised is at least the goal.
- Refunds succeed only after the deadline when the total raised is below the goal.
