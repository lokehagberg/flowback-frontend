# PredictionBetHelpers
**Inherits:**
[PollHelpers](/src/PollHelpers.sol/contract.PollHelpers.md), [ProposalHelpers](/src/ProposalHelpers.sol/contract.ProposalHelpers.md), [PredictionHelpers](/src/PredictionHelpers.sol/contract.PredictionHelpers.md)

**Author:**
@EllenLng, @KristofferGW

This contract facilitates the storage and management of prediction bets made by users on proposals and predictions within polls.

Audited by @MashaVaverova

*This contract extends PollHelpers, ProposalHelpers, and PredictionHelpers to manage prediction bets related to polls and proposals.*


## State Variables
### predictionBets
Maps a poll ID to an array of PredictionBet structures representing all bets made in that poll.


```solidity
mapping(uint256 => mapping(uint256 => PredictionBet[])) public predictionBets;
```


## Structs
### PredictionBet
*Struct to represent a prediction bet placed by a user.*


```solidity
struct PredictionBet {
    uint256 pollId;
    uint256 proposalId;
    uint256 predictionId;
    bool bet;
    uint256 likelihood;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll where the bet is placed.|
|`proposalId`|`uint256`|The ID of the proposal within the poll that the bet is related to.|
|`predictionId`|`uint256`|The ID of the prediction related to the bet.|
|`bet`|`bool`|A boolean representing whether the bet is for or against the prediction.|
|`likelihood`|`uint256`|The likelihood score assigned to the prediction.|

