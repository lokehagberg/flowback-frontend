# SharedErrors
**Author:**
@MashaVaverova

*This contract defines custom errors used across various contracts.*


## Errors
### SH_AlreadyVoted
Error thrown when a user attempts to vote more than once.


```solidity
error SH_AlreadyVoted(uint256 pollId, address voter);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pollId`|`uint256`|The ID of the poll.|
|`voter`|`address`|The address of the voter who tried to vote again.|

