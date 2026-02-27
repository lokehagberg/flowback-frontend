# Blockchain_v2_CrossChain

## Networks
- Base Sepolia (chainId: 84532)
- Ethereum Sepolia (chainId: 11155111)

## Environment (.env)
Required:
- `PRIVATE_KEY`
- `BASE_SEPOLIA_RPC_URL`
- `ETHEREUM_SEPOLIA_RPC_URL`
- `ETHERSCAN_API_KEY`

Deployed addresses (current):
### Base Sepolia
- `POLLS_ADDRESS=0x8d15eD0A80330C54f31120b5fac5aF0a321409f6`
- `META_TX_HANDLER_ADDRESS=0xF900d067E12BAeD1FFdf39B236ca924B84441b21`
- `META_VOTING_ADDRESS=0x18E811D1BF9a44017579D2271703fa363CC5DF64`
- `POLLS_BRIDGE_ADDRESS=0x47ed3234a168CDD8019604d178CD2Dd70D2566DC`
- `RIGHT_TO_VOTE_ADDRESS=0x7EC7fDB2d85a4513AF07775f37ebeE8c3679eDbE`
- `DELEGATIONS_ADDRESS=0x91257dCdc14E61cBB9D2D84dd42365E1297Da515`
- `POLL_HELPERS_ADDRESS=0x00d9665D94b2Aa9A2D860734e359c2D8E3a5b9D8`
- `PROPOSAL_HELPERS_ADDRESS=0x336b64F13A312116C53035Ca89D12c9FbA63a2Ea`
- `PREDICTIONS_ADDRESS=0xDA11A806b4055aC202da49Bb8E244464C36bE252`
- `PREDICTION_HELPERS_ADDRESS=0xD7c7743E1771Bf9c94B48b846c5852fa73071fD6`
- `PREDICTION_BET_HELPERS_ADDRESS=0xA4DF1d3b5c163088C2F641C3788a604291c1b355`
- `PREDICTION_BETS_ADDRESS=0x91f098095017b96f73bab105D97d865fEE65585a`

### Ethereum Sepolia
- `POLLS_ON_ETHEREUM_ADDRESS=0x74365c47C0e9D2EF879FF60b75156ecf15a8D270`

## Build + Test
```bash
forge build --sizes
forge test
```

## Deploy

> Use Git Bash on Windows and load `.env`:

```bash
set -a
source .env
set +a
```

### Base Sepolia

```bash
forge script script/Base_deploy.s.sol:Base_deploy --rpc-url "$BASE_SEPOLIA_RPC_URL" --broadcast -vvv
```

### Ethereum Sepolia

```bash
forge script script/Eth_deploy.s.sol:ETH_deploy --rpc-url "$ETHEREUM_SEPOLIA_RPC_URL" --broadcast -vvv
```

## Configure Bridge Addresses

### Base Sepolia (configure PollsBridge)

```bash
forge script script/ConfigureBridgeBase.s.sol:ConfigureBridgeBase --rpc-url "$BASE_SEPOLIA_RPC_URL" --broadcast -vvv
```

### Ethereum Sepolia (temporary: EOA as bridgeContract)

```bash
forge script script/ConfigureBridgeEthereum.s.sol:ConfigureBridgeEthereum --rpc-url "$ETHEREUM_SEPOLIA_RPC_URL" --broadcast -vvv
```

## Verify

### Base Sepolia

```bash
forge verify-contract --verifier etherscan --chain base-sepolia --etherscan-api-key "$ETHERSCAN_API_KEY" \
  0x47ed3234a168CDD8019604d178CD2Dd70D2566DC src/PollsBridge.sol:PollsBridge

forge verify-contract --verifier etherscan --chain base-sepolia --etherscan-api-key "$ETHERSCAN_API_KEY" \
  0x8d15eD0A80330C54f31120b5fac5aF0a321409f6 src/Polls.sol:Polls \
  --constructor-args $(cast abi-encode "constructor(address)" 0x7B95c1314BD7d95737157d9E6EcFCf0b6c22f272)

forge verify-contract --verifier etherscan --chain base-sepolia --etherscan-api-key "$ETHERSCAN_API_KEY" \
  0xF900d067E12BAeD1FFdf39B236ca924B84441b21 src/MetaTxHandler.sol:MetaTxHandler \
  --constructor-args $(cast abi-encode "constructor(address)" 0x8d15eD0A80330C54f31120b5fac5aF0a321409f6)

forge verify-contract --verifier etherscan --chain base-sepolia --etherscan-api-key "$ETHERSCAN_API_KEY" \
  0x18E811D1BF9a44017579D2271703fa363CC5DF64 src/MetaVoting.sol:MetaVoting \
  --constructor-args $(cast abi-encode "constructor(address)" 0x336b64F13A312116C53035Ca89D12c9FbA63a2Ea)
```

### Ethereum Sepolia

```bash
forge verify-contract --verifier etherscan --chain sepolia --etherscan-api-key "$ETHERSCAN_API_KEY" \
  0x74365c47C0e9D2EF879FF60b75156ecf15a8D270 src/PollsOnEthereum.sol:PollsOnEthereum
```

## Notes

* `PollsBridge` and `PollsOnEthereum` are configured with addresses, but cross-chain messaging is not implemented yet (TODO in contract).
* `PollsOnEthereum.bridgeContract` is temporarily set to the deployer EOA for manual testing. Replace it later with a real cross-chain receiver contract on Ethereum.
* Never commit `.env` or private keys.
