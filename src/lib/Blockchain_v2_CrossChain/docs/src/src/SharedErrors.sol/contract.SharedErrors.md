# SharedErrors
This contract defines reusable custom errors for improved gas efficiency and standardized error handling across contracts.

*These custom errors provide structured error handling, helping reduce gas costs by avoiding traditional revert messages with strings.
They cover a range of scenarios including voting, membership, delegation, and proposal validation.*

*This contract is intended to be inherited by other contracts requiring these standardized errors.*


## Errors
### SH_AlreadyVoted

```solidity
error SH_AlreadyVoted(uint256 pollId, address voter);
```

### SH_AlreadyMember

```solidity
error SH_AlreadyMember(uint256 groupId, address user);
```

### SH_NotMember

```solidity
error SH_NotMember(uint256 groupId, address user);
```

### SH_InvalidDelegation

```solidity
error SH_InvalidDelegation(uint256 groupId, address delegate);
```

### SH_CannotDelegateToSelf

```solidity
error SH_CannotDelegateToSelf(address user);
```

### SH_ProposalDoesNotExist

```solidity
error SH_ProposalDoesNotExist(uint256 pollId, uint256 proposalId);
```

