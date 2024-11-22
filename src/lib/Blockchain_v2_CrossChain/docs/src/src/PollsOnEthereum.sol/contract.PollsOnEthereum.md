# PollsOnEthereum
This contract manages poll results and individual votes that are bridged from the Base network.
It stores finalized poll results and individual voter scores for verification on Ethereum.

*Only the designated bridge contract can call functions that store results and votes, ensuring
that only verified data from the bridge is recorded.
State Variables:
- `bridgeContract`: The address of the bridge contract authorized to store poll results and votes.
- `pollResults`: Mapping of poll IDs to their respective `PollResult` structs, storing poll results and finalization status.
- `voterScores`: Mapping that stores individual scores given by voters for each proposal in a poll.
Structs:
- `PollResult`: Contains the poll ID, result hash, and finalization status, representing the finalized state of a poll.
Events:
- `PollResultReceived`: Emitted when a poll result is successfully stored, including poll ID and result hash.
- `VoteStored`: Emitted when an individual vote score is recorded, including poll ID, voter, proposal ID, and score.
Modifiers:
- `onlyBridge`: Restricts function access to the bridge contract, ensuring that only verified data is stored.
Requirements:
- Only the bridge contract can call `storePollResult` and `storeIndividualVote`.
- Poll results can only be stored once; subsequent calls to store a finalized poll will revert.
Usage:
- **Set Bridge Contract**: Use `setBridgeContract` to set or update the bridge contract address.
- **Store Poll Results**: Use `storePollResult` to store bridged poll results, which finalizes the poll.
- **Store Individual Votes**: Use `storeIndividualVote` to record individual scores for verification on Ethereum.*


## State Variables
### bridgeContract

```solidity
address public bridgeContract;
```


### pollResults

```solidity
mapping(uint256 => PollResult) public pollResults;
```


### voterScores

```solidity
mapping(uint256 => mapping(address => mapping(uint256 => uint8))) public voterScores;
```


## Functions
### onlyBridge


```solidity
modifier onlyBridge();
```

### setBridgeContract

Sets the address of the bridge contract.


```solidity
function setBridgeContract(address _bridgeContract) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_bridgeContract`|`address`|The address of the bridge contract authorized to store results and votes.|


### storePollResult

Stores the bridged poll result from Base.


```solidity
function storePollResult(uint256 _pollId, bytes32 _resultHash) external onlyBridge;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_resultHash`|`bytes32`|The result hash. Requirements: - Only the bridge contract can call this function. - The poll must not have already been finalized. Emits: - `PollResultReceived` with the poll ID and result hash.|


### storeIndividualVote

Allows storing of individual votes for verification.


```solidity
function storeIndividualVote(uint256 _pollId, address _voter, uint256 _proposalId, uint8 _score) external onlyBridge;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The poll ID.|
|`_voter`|`address`|The voter's address.|
|`_proposalId`|`uint256`|The proposal ID.|
|`_score`|`uint8`|The score given by the voter. Requirements: - Only the bridge contract can call this function. Emits: - `VoteStored` with the poll ID, voter's address, proposal ID, and score.|


## Events
### PollResultReceived

```solidity
event PollResultReceived(uint256 indexed pollId, bytes32 resultHash);
```

### VoteStored

```solidity
event VoteStored(uint256 indexed pollId, address indexed voter, uint256 proposalId, uint8 score);
```

## Structs
### PollResult

```solidity
struct PollResult {
    uint256 pollId;
    bytes32 resultHash;
    bool finalized;
}
```

