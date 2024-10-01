# Polls
**Inherits:**
[RightToVote](/src/RightToVote.sol/contract.RightToVote.md), [Delegations](/src/Delegations.sol/contract.Delegations.md), [PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md), [PredictionHelpers](/src/PredictionHelpers.sol/contract.PredictionHelpers.md), [Predictions](/src/Predictions.sol/contract.Predictions.md), [PredictionBetHelpers](/src/PredictionBetHelpers.sol/contract.PredictionBetHelpers.md), [PredictionBets](/src/PredictionBets.sol/contract.PredictionBets.md)

**Author:**
@EllenLng, @KristofferGW

Audited by @MashaVaverova.

*This contract manages the creation and voting on polls and proposals. It integrates several modules such as voting rights, delegations, and predictions.*


## Functions
### createPoll

Creates a new poll with the given parameters.

*This function increments the poll count and emits the PollCreated event.*


```solidity
function createPoll(
    string calldata _title,
    string calldata _tag,
    uint256 _group,
    uint256 _pollStartDate,
    uint256 _proposalEndDate,
    uint256 _votingStartDate,
    uint256 _delegateEndDate,
    uint256 _endDate,
    uint8 _maxVoteScore
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_title`|`string`|The title of the poll.|
|`_tag`|`string`|The tag categorizing the poll.|
|`_group`|`uint256`|The group associated with the poll.|
|`_pollStartDate`|`uint256`|The start date of the poll.|
|`_proposalEndDate`|`uint256`|The date when the proposal phase ends.|
|`_votingStartDate`|`uint256`|The date when the voting phase begins.|
|`_delegateEndDate`|`uint256`|The date when the delegation phase ends.|
|`_endDate`|`uint256`|The date when the poll ends.|
|`_maxVoteScore`|`uint8`|The maximum score that can be given in the poll.|


### vote

Casts a vote in a specific poll for a proposal.

*This function ensures the user has not already voted, checks that the proposal exists, and ensures that the user has not delegated their vote.*


```solidity
function vote(uint256 _pollId, uint256 _proposalId, uint8 _score) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_proposalId`|`uint256`|The ID of the proposal to vote on.|
|`_score`|`uint8`|The score assigned to the proposal by the voter.|


### voteAsDelegate

Casts a delegate vote in a specific poll for a proposal.

*This function checks if the user is a delegate and if the delegate has already voted. It calculates delegated voting power and applies it to the vote.*


```solidity
function voteAsDelegate(uint256 _pollId, uint256 _proposalId, uint8 _score) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll.|
|`_proposalId`|`uint256`|The ID of the proposal to vote on.|
|`_score`|`uint8`|The score assigned to the proposal by the delegate voter.|


## Events
### PollCreated
Emitted when a new poll is created.


```solidity
event PollCreated(uint256 pollId, string title);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The unique ID of the created poll.|
|`title`|`string`|The title of the poll.|

### VoteSubmitted
Emitted when a vote is submitted to a proposal.


```solidity
event VoteSubmitted(uint256 indexed pollId, address indexed voter, uint256 votesForProposal);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll the vote was cast in.|
|`voter`|`address`|The address of the voter.|
|`votesForProposal`|`uint256`|The total number of votes cast for the proposal.|

