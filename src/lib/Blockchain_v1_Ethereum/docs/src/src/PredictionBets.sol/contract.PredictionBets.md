# PredictionBets
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md), [PredictionHelpers](/src/PredictionHelpers.sol/contract.PredictionHelpers.md), [PredictionBetHelpers](/src/PredictionBetHelpers.sol/contract.PredictionBetHelpers.md)

**Author:**
@EllenLng, @KristofferGW

This contract allows users to place and retrieve prediction bets, ensuring that the poll, proposal, and prediction exist before placing bets.

Audited by @MashaVaverova

*This contract manages prediction bets placed by users on proposals within polls. It extends PollHelpers, ProposalHelpers, PredictionHelpers, and PredictionBetHelpers.*


## Functions
### requireExist

Modifier to check that a poll, proposal, and prediction exist before placing or retrieving a bet.


```solidity
modifier requireExist(uint256 _pollId, uint256 _proposalId, uint256 _predictionId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll to check.|
|`_proposalId`|`uint256`|The ID of the proposal to check.|
|`_predictionId`|`uint256`|The ID of the prediction to check.|


### placePredictionBet

Places a new prediction bet for a specific poll, proposal, and prediction.

*The function ensures that the poll, proposal, and prediction exist, and the likelihood is greater than 0 before placing the bet.*


```solidity
function placePredictionBet(uint256 _pollId, uint256 _proposalId, uint256 _predictionId, uint256 _likelihood, bool _bet)
    external
    requireExist(_pollId, _proposalId, _predictionId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll associated with the bet.|
|`_proposalId`|`uint256`|The ID of the proposal associated with the bet.|
|`_predictionId`|`uint256`|The ID of the prediction being bet on.|
|`_likelihood`|`uint256`|The likelihood score given by the user for the prediction.|
|`_bet`|`bool`|Boolean indicating whether the user is betting for or against the prediction.|


### getPredictionBets

Retrieves the prediction bets placed on a specific proposal within a poll.


```solidity
function getPredictionBets(uint256 _pollId, uint256 _proposalId, uint256 _predictionId)
    external
    view
    requireExist(_pollId, _proposalId, _predictionId)
    returns (PredictionBet[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pollId`|`uint256`|The ID of the poll associated with the bets.|
|`_proposalId`|`uint256`|The ID of the proposal associated with the bets.|
|`_predictionId`|`uint256`|The ID of the prediction associated with the bets.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PredictionBet[]`|An array of PredictionBet structs representing all bets placed on the specified prediction.|


## Events
### PredictionBetCreated
Emitted when a new prediction bet is created.


```solidity
event PredictionBetCreated(uint256 indexed predictionId, bool bet, uint256 likelihood);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`predictionId`|`uint256`|The ID of the prediction for which the bet is placed.|
|`bet`|`bool`|Boolean indicating if the bet is for or against the prediction.|
|`likelihood`|`uint256`|The likelihood score assigned to the prediction by the user.|

## Errors
### PB_InvalidLikelihood

```solidity
error PB_InvalidLikelihood(uint256 likelihood);
```

