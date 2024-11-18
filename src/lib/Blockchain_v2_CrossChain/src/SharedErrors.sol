// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

/**
 * @title SharedErrors
 * @notice This contract defines reusable custom errors for improved gas efficiency and standardized error handling across contracts.
 * @dev These custom errors provide structured error handling, helping reduce gas costs by avoiding traditional revert messages with strings.
 *      They cover a range of scenarios including voting, membership, delegation, and proposal validation.
 * 
 * @dev This contract is intended to be inherited by other contracts requiring these standardized errors.
 */
contract SharedErrors {
    // Voting-related errors
    error SH_AlreadyVoted(uint256 pollId, address voter);

    // Membership-related errors
    error SH_AlreadyMember(uint256 groupId, address user);
    error SH_NotMember(uint256 groupId, address user);

    // Delegation-related errors
    error SH_InvalidDelegation(uint256 groupId, address delegate);
    error SH_CannotDelegateToSelf(address user);

    error SH_ProposalDoesNotExist(uint256 pollId, uint256 proposalId);
}
