# ProposalHelpers
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md)

This contract provides functions for managing proposals within polls, including adding proposals,
casting votes, updating scores, and retrieving proposal details.

*Extends the `PollHelpers` contract and interacts with `SharedErrors`.*


## State Variables
### proposals

```solidity
mapping(uint256 => mapping(uint256 => Proposal)) public proposals;
```


### proposalCount

```solidity
mapping(uint256 => uint256) public proposalCount;
```


## Functions
### addProposal

Adds a new proposal to a poll.

*The poll must exist and be within the proposal submission phase.*


```solidity
function addProposal(uint256 _pollId, string calldata _description) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to add a proposal to.|
|`_description`|`string`|The description of the proposal. Requirements: - The specified poll must exist. - The current time must be within the proposal submission period. Emits: - `ProposalAdded`: Logs the poll ID, proposal ID, and proposal description.|


### castVote

Casts a vote on a specific proposal within a poll.


```solidity
function castVote(uint256 _pollId, uint256 _proposalId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll containing the proposal.|
|`_proposalId`|`uint256`|The ID of the proposal to vote on. Requirements: - The specified poll and proposal must exist. - The voter must not have already voted on the proposal. Emits: - `VoteCast`: Logs the voter address, poll ID, and proposal ID.|


### recordMetaVote

Records a meta-transaction vote on a proposal within a poll.


```solidity
function recordMetaVote(uint256 _pollId, uint256 _proposalId, address voter) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll containing the proposal.|
|`_proposalId`|`uint256`|The ID of the proposal to vote on.|
|`voter`|`address`|The address of the voter. Requirements: - Only the MetaVoting contract can call this function. - The specified poll and proposal must exist. - The voter must not have already voted on the proposal.|


### getProposals

Retrieves all proposals associated with a specific poll.


```solidity
function getProposals(uint256 _pollId) external view returns (Proposal[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to retrieve proposals from.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Proposal[]`|An array of Proposal structs representing all proposals in the specified poll. Requirements: - The specified poll must exist.|


### getPollResults

Retrieves descriptions, vote counts, and scores for all proposals within a poll.


```solidity
function getPollResults(uint256 _pollId)
    external
    view
    returns (string[] memory proposalDescriptions, uint256[] memory voteCounts, uint256[] memory scores);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to retrieve results from.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`proposalDescriptions`|`string[]`|An array of descriptions for each proposal.|
|`voteCounts`|`uint256[]`|An array of vote counts for each proposal.|
|`scores`|`uint256[]`|An array of scores for each proposal. Requirements: - The specified poll must exist.|


### getProposal

Retrieves a specific proposal within a poll.


```solidity
function getProposal(uint256 _pollId, uint256 _proposalId) public view returns (Proposal memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_proposalId`|`uint256`|The ID of the proposal.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Proposal`|The proposal struct. Requirements: - The specified proposal must exist within the poll.|


### updateProposalVotes

Updates the vote count and score of a specific proposal.


```solidity
function updateProposalVotes(uint256 _pollId, uint256 _proposalId, uint256 voteIncrease, uint256 scoreIncrease)
    public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll containing the proposal.|
|`_proposalId`|`uint256`|The ID of the proposal to update.|
|`voteIncrease`|`uint256`|The amount to increase the vote count by.|
|`scoreIncrease`|`uint256`|The amount to increase the score by. Requirements: - The specified proposal must exist. - Either `voteIncrease` or `scoreIncrease` must be greater than zero. Emits: - `ProposalUpdated`: Logs the poll ID, proposal ID, new vote count, and new score.|


### requireProposalToExist

*Checks that a specified proposal exists within a poll.*


```solidity
function requireProposalToExist(uint256 pollId, uint256 proposalId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll.|
|`proposalId`|`uint256`|The ID of the proposal. Reverts: - `SH_ProposalDoesNotExist` if the proposal does not exist.|


### controlProposalEndDate

*Ensures that the current time is within the proposal submission period for the specified poll.*


```solidity
function controlProposalEndDate(uint256 _pollId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check. Reverts: - `PH_ProposalPhaseEnded` if the proposal submission period has ended.|


### publicControlProposalEndDate


```solidity
function publicControlProposalEndDate(uint256 _pollId) external view;
```

## Events
### ProposalAdded

```solidity
event ProposalAdded(uint256 indexed pollId, uint256 indexed proposalId, string description);
```

### ProposalUpdated

```solidity
event ProposalUpdated(uint256 pollId, uint256 proposalId, uint256 newVoteCount, uint256 newScore);
```

### VoteCast

```solidity
event VoteCast(address indexed voter, uint256 indexed pollId, uint256 indexed proposalId);
```

## Structs
### Proposal

```solidity
struct Proposal {
    string description;
    uint256 voteCount;
    uint256 proposalId;
    uint256 predictionCount;
    uint256 score;
    uint256 totalScore;
    address creator;
}
```

