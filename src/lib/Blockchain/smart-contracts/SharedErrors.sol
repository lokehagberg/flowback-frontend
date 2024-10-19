// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract SharedErrors {
    error SH_AlreadyVoted(uint256 pollId, address voter);
}
