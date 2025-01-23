# PollsBridge
This contract facilitates bridging poll results between the Base and Ethereum networks.
It enables the transfer of finalized poll results from the Polls contract on Base to
the corresponding Polls contract on Ethereum using cross-chain messaging.

*This contract is designed to interact with cross-chain solutions (e.g., LayerZero, Axelar, Chainlink CCIP)
to securely bridge poll data across chains. Only the authorized Polls contract on Base can initiate a
bridge request to send results to Ethereum.
State Variables:
- `ethereumPollsContract`: The address of the Polls contract on Ethereum, where results will be sent.
- `basePollsContract`: The address of the Polls contract on Base, which has permission to bridge results.
Events:
- `BridgeRequestSent`: Emitted when a bridge request is sent to Ethereum, including the poll ID and result hash.
Requirements:
- Only the designated `basePollsContract` can call `bridgeResults` to ensure only authorized results are bridged.
Usage:
- **Cross-Chain Bridging**: Use `bridgeResults` to send finalized poll results to the Polls contract on Ethereum.
- **Contract Address Management**: Use `setEthereumPollsContract` and `setBasePollsContract` to set or update
the respective Polls contract addresses.*


## State Variables
### ethereumPollsContract

```solidity
address public ethereumPollsContract;
```


### basePollsContract

```solidity
address public basePollsContract;
```


## Functions
### setEthereumPollsContract


```solidity
function setEthereumPollsContract(address _ethereumPollsContract) external;
```

### setBasePollsContract


```solidity
function setBasePollsContract(address _basePollsContract) external;
```

### bridgeResults

Sends the finalized poll results to the Ethereum contract.


```solidity
function bridgeResults(uint256 _pollId, bytes32 _resultHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_resultHash`|`bytes32`|The result hash of the poll.|


## Events
### BridgeRequestSent

```solidity
event BridgeRequestSent(uint256 indexed pollId, bytes32 resultHash);
```

