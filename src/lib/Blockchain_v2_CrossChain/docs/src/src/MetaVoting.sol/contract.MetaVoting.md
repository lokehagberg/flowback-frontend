# MetaVoting
**Inherits:**
Ownable

This contract enables meta-transactions for voting, allowing a relayer to submit votes on behalf
of users. It facilitates gasless voting through a relayer who covers the transaction fees.

*This contract interacts with ProposalHelpers to record votes, using a designated relayer to submit
meta-transaction votes for participants in various polls.
Inherits:
- `Ownable`: Allows only the contract owner to assign the relayer.
State Variables:
- `relayer`: The address authorized to submit meta-transactions on behalf of voters.
- `proposalHelpersContract`: Reference to the ProposalHelpers contract where votes are recorded.
Features:
- **Relayer Management**: Enables the contract owner to assign a relayer responsible for submitting votes.
- **Meta-Vote Submission**: Allows the relayer to submit a vote via `castVoteMeta` for a specified voter and proposal.
Events:
- `VoteCastMeta`: Emitted when a meta-vote is successfully cast, providing poll and proposal IDs along with the voter's address.
Requirements:
- Only the contract owner can change the relayer.
- Only the designated relayer can call `castVoteMeta`.*


## State Variables
### relayer

```solidity
address public relayer;
```


### proposalHelpersContract

```solidity
ProposalHelpers public proposalHelpersContract;
```


## Functions
### constructor


```solidity
constructor(address _proposalHelpersContract);
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


### castVoteMeta

Casts a vote via meta-transaction on behalf of a voter.

*The relayer submits this transaction on behalf of the voter, covering the gas fees.*


```solidity
function castVoteMeta(uint256 pollId, uint256 proposalId, address voter) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll in which to cast a vote.|
|`proposalId`|`uint256`|The ID of the proposal within the poll to vote on.|
|`voter`|`address`|The address of the voter casting the vote.|


### _processVote

*Internal function to process the vote. Calls recordMetaVote in ProposalHelpers.*


```solidity
function _processVote(uint256 pollId, uint256 proposalId, address voter) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll.|
|`proposalId`|`uint256`|The ID of the proposal.|
|`voter`|`address`|The address of the voter casting the vote.|


## Events
### VoteCastMeta

```solidity
event VoteCastMeta(uint256 indexed pollId, uint256 indexed proposalId, address indexed voter);
```

