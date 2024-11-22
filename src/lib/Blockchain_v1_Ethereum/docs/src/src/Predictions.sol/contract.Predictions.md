# Predictions
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md), [PredictionHelpers](/src/PredictionHelpers.sol/contract.PredictionHelpers.md)

**Author:**
@EllenLng, @KristofferGW

This contract allows users to create predictions for proposals and retrieve existing predictions for a specific poll and proposal.

Audited by @MashaVaverova

*This contract manages the creation and retrieval of predictions associated with proposals in polls.*


## Functions
### createPrediction

Creates a new prediction for a specific proposal within a poll.

*The proposal must exist before a prediction can be created. The prediction ID is incremented and assigned automatically.*


```solidity
function createPrediction(uint256 _pollId, uint256 _proposalId, string memory _prediction) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll where the prediction is being created.|
|`_proposalId`|`uint256`|The ID of the proposal associated with the prediction.|
|`_prediction`|`string`|The content of the prediction.|


### getPredictions

Retrieves all predictions associated with a specific proposal in a poll.

*The proposal must exist before predictions can be retrieved.*


```solidity
function getPredictions(uint256 _pollId, uint256 _proposalId) external view returns (Prediction[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll containing the proposal.|
|`_proposalId`|`uint256`|The ID of the proposal for which predictions are being retrieved.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Prediction[]`|An array of Prediction structs representing all predictions for the given proposal.|


## Events
### PredictionCreated
Emitted when a new prediction is created.


```solidity
event PredictionCreated(
    uint256 indexed pollId, uint256 indexed proposalId, uint256 indexed predictionId, string prediction
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll in which the prediction was created.|
|`proposalId`|`uint256`|The ID of the proposal associated with the prediction.|
|`predictionId`|`uint256`|The unique ID of the prediction.|
|`prediction`|`string`|The text content of the prediction.|

