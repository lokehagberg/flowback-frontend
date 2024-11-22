# MetaTxHandler
**Inherits:**
Ownable

This contract handles meta-transactions for voting, allowing off-chain signature verification
and relayed transactions to the Polls contract for gasless voting.

*The MetaTxHandler contract interacts with an instance of the Polls contract, enabling
verified votes to be relayed by an authorized relayer. The relayer is initially set to the
deployer but can be changed by the contract owner.
Inherits:
- `Ownable`: Provides access control, allowing only the owner to change the relayer address.
State Variables:
- `pollsContract`: Address of the Polls contract instance where votes are relayed.
- `relayer`: Address authorized to submit meta-transaction votes on behalf of users.
Features:
- **Relayer Management**: Allows the owner to set or update the relayer responsible for submitting
meta-transactions.
- **Meta-Vote Handling**: Processes meta-votes, which are relayed to the Polls contract after
off-chain signature verification.
Events:
- `Debug`: Emitted to log and track each meta-vote, useful for off-chain debugging and monitoring.
Requirements:
- Only the contract owner can set a new relayer address.
- Only the relayer can submit meta-votes via the `handleMetaVote` function.*


## State Variables
### pollsContract

```solidity
Polls public pollsContract;
```


### relayer

```solidity
address public relayer;
```


## Functions
### onlyRelayer


```solidity
modifier onlyRelayer();
```

### constructor


```solidity
constructor(address _pollsContract);
```

### setRelayer

Sets a new relayer responsible for submitting meta-transactions.

*Only the owner can set the relayer.*


```solidity
function setRelayer(address _relayer) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_relayer`|`address`|The address of the new relayer.|


### handleMetaVote

Processes a meta-vote after off-chain verification.

*Only the relayer can call this function after verifying the voter's signature off-chain.*


```solidity
function handleMetaVote(uint256 _pollId, uint256 _proposalId, uint8 _score, address voter, uint256 _group)
    external
    onlyRelayer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_proposalId`|`uint256`|The ID of the proposal within the poll.|
|`_score`|`uint8`|The score for the vote.|
|`voter`|`address`|The address of the voter.|
|`_group`|`uint256`|The ID of the group in which the voter is participating.|


## Events
### Debug

```solidity
event Debug(address voter, uint256 pollId, uint256 proposalId, uint8 score, uint256 group);
```

