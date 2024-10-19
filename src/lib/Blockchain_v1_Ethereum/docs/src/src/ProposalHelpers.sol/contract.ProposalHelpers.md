# ProposalHelpers
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md)

**Author:**
@EllenLng, @KristofferGW

Audited by @MashaVaverova

*This contract manages proposals within polls, including adding proposals,
retrieving proposal details, and updating proposal votes and scores.*


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

Adds a proposal to a poll.


```solidity
function addProposal(uint256 _pollId, string calldata _description) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to add a proposal to.|
|`_description`|`string`|The description of the proposal.|


### getPollResults

Retrieves the results of all proposals in a specified poll.


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
|`proposalDescriptions`|`string[]`|An array of descriptions of the proposals.|
|`voteCounts`|`uint256[]`|An array of vote counts for each proposal.|
|`scores`|`uint256[]`|An array of scores for each proposal.|


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
|`<none>`|`Proposal`|The proposal struct.|


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
|`<none>`|`Proposal[]`|An array of Proposal structs representing all proposals in the specified poll.|


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
|`scoreIncrease`|`uint256`|The amount to increase the score by.|


### requireProposalToExist

Ensures that a proposal exists within a specified poll.


```solidity
function requireProposalToExist(uint256 _pollId, uint256 _proposalId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_proposalId`|`uint256`|The ID of the proposal.|


## Events
### ProposalAdded

```solidity
event ProposalAdded(uint256 indexed pollId, uint256 indexed proposalId, string description);
```

### ProposalUpdated

```solidity
event ProposalUpdated(uint256 pollId, uint256 proposalId, uint256 newVoteCount, uint256 newScore);
```

## Errors
### PH_ProposalDoesNotExist

```solidity
error PH_ProposalDoesNotExist(uint256 pollId, uint256 proposalId);
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
    address creator;
}
```

