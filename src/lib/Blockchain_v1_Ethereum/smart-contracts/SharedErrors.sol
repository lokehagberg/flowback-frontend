// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

/** @title SharedErrors
* @dev This contract defines custom errors used across various contracts.
* @author @MashaVaverova
*/

contract SharedErrors {
/// @notice Error thrown when a user attempts to vote more than once.
/// @param pollId The ID of the poll.
/// @param voter The address of the voter who tried to vote again.
    error SH_AlreadyVoted(uint256 pollId, address voter);
}
