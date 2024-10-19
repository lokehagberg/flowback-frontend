# PredictionHelpers
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md)

**Author:**
@EllenLng, @KristofferGW

This contract is used to interact with predictions and validate their existence within specific proposals and polls.

Audited by @MashaVaverova

*This contract manages predictions related to proposals and polls, providing utility functions to ensure predictions exist and are valid.*


## State Variables
### predictions
Mapping from a proposal ID to an array of predictions related to that proposal.


```solidity
mapping(uint256 => Prediction[]) public predictions;
```


## Functions
### requirePredictionToExist

Ensures that the prediction exists for the given proposal.

*This function checks if a prediction with the specified prediction ID exists within a proposal's predictions.*


```solidity
function requirePredictionToExist(uint256 _proposalId, uint256 _predictionId)
    internal
    view
    returns (bool predictionExists);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proposalId`|`uint256`|The ID of the proposal to check for the prediction.|
|`_predictionId`|`uint256`|The ID of the prediction to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`predictionExists`|`bool`|Returns true if the prediction exists, false otherwise.|


## Structs
### Prediction
*Struct representing a prediction linked to a poll and proposal.*


```solidity
struct Prediction {
    uint256 pollId;
    uint256 proposalId;
    uint256 predictionId;
    string prediction;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll the prediction is linked to.|
|`proposalId`|`uint256`|The ID of the proposal the prediction is related to.|
|`predictionId`|`uint256`|The unique ID of the prediction.|
|`prediction`|`string`|The textual content of the prediction.|

