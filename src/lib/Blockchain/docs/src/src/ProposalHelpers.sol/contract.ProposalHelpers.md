# ProposalHelpers
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md)

**Author:**
@EllenLng, @KristofferGW

This contract allows for the creation of proposals within polls and retrieves the results of proposals.

Audited by @MashaVaverova

*This contract manages proposals associated with polls, including adding proposals, retrieving results, and ensuring proposals exist.*


## State Variables
### proposals
Maps a poll ID to an array of proposals within that poll.


```solidity
mapping(uint256 => Proposal[]) public proposals;
```


## Functions
### addProposal

Adds a new proposal to a specified poll.

*The poll must exist, and the proposal phase must still be open for a new proposal to be added.*


```solidity
function addProposal(uint256 _pollId, string calldata _description) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to add the proposal to.|
|`_description`|`string`|The text description of the proposal.|


### getPollResults

Retrieves the results of all proposals in a specified poll.


```solidity
function getPollResults(uint256 _pollId)
    public
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


### getProposals

Retrieves all proposals associated with a specified poll.


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


### requireProposalToExist

Ensures that a proposal exists within a specified poll.

*This function checks if a proposal with the specified ID exists in the poll's proposal list.*


```solidity
function requireProposalToExist(uint256 _pollId, uint256 _proposalId) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|
|`_proposalId`|`uint256`|The ID of the proposal to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the proposal exists, false otherwise.|


## Events
### ProposalAdded
Emitted when a new proposal is added to a poll.


```solidity
event ProposalAdded(uint256 indexed pollId, uint256 proposalId, string description);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll to which the proposal was added.|
|`proposalId`|`uint256`|The unique ID of the added proposal.|
|`description`|`string`|The description of the added proposal.|

## Structs
### Proposal
*Struct representing a proposal in a poll.*


```solidity
struct Proposal {
    string description;
    uint256 voteCount;
    uint256 proposalId;
    uint256 predictionCount;
    uint256 score;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`description`|`string`|The text describing the proposal.|
|`voteCount`|`uint256`|The total number of votes received by the proposal.|
|`proposalId`|`uint256`|The unique ID of the proposal.|
|`predictionCount`|`uint256`|The count of predictions linked to the proposal.|
|`score`|`uint256`|The total score assigned to the proposal by voters.|

