# Predictions
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md), [PredictionHelpers](/src/PredictionHelpers.sol/contract.PredictionHelpers.md)

This contract allows users to create and retrieve predictions associated with specific proposals in polls.

*Extends `PollHelpers`, `ProposalHelpers`, and `PredictionHelpers`.
Events:
- `PredictionCreated`: Emitted when a new prediction is successfully created.
Requirements:
- Proposals must exist within a poll before predictions can be created or retrieved.
Usage:
- **Creating Predictions**: Call `createPrediction` to add a prediction to a specific proposal within a poll.
- **Retrieving Predictions**: Call `getPredictions` to view all predictions associated with a specific proposal.*


## Functions
### createPrediction

Creates a new prediction for a specific proposal within a poll.

*The proposal must exist before a prediction can be created. The prediction ID is auto-incremented.*


```solidity
function createPrediction(uint256 _pollId, uint256 _proposalId, string memory _prediction) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll where the prediction is being created.|
|`_proposalId`|`uint256`|The ID of the proposal associated with the prediction.|
|`_prediction`|`string`|The content of the prediction. Requirements: - The proposal identified by `_pollId` and `_proposalId` must exist. Emits: - `PredictionCreated`: Logs the poll ID, proposal ID, prediction ID, and prediction text.|


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
|`<none>`|`Prediction[]`|An array of Prediction structs representing all predictions for the given proposal. Requirements: - The proposal identified by `_pollId` and `_proposalId` must exist.|


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

