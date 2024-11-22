// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Delegations} from "../src/Delegations.sol";
import {Polls} from "../src/Polls.sol";

contract DelegationsTest is Test, Delegations, Polls {
    Polls public testPolls;
    address user1 = address(0x1);
    address user2 = address(0x2);
    uint256 _groupId = 1;

    // Initialize the Polls contract
    function setUp() public {
        testPolls = new Polls();
    }

    // A modifier to make user1 both a group member and a delegate before running the test
    modifier userOneBecomesDelegate() {
        // Set the caller to user1 for the following operations
        vm.startPrank(user1);

        // User1 becomes a member of the specified group
        testPolls.becomeMemberOfGroup(_groupId);

        // User1 becomes a delegate of the specified group
        testPolls.becomeDelegate(_groupId);

        // Stop user1's prank state
        vm.stopPrank();
        _;
    }

    // BEING A DELEGATE FUNCTIONALITY
    function testBecomeDelegateAsGroupMember() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a group member
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group
        bool isDelegate = testPolls.addressIsDelegate(_groupId, user1); // Check if user1 is now marked as a delegate
        assertEq(isDelegate, true, "User1 should be a delegate in the group"); // Assert that user1 is indeed a delegate in the group
        vm.stopPrank(); // Stop user1's prank state
    }

    function testEmitNewDelegate() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a group member
        vm.expectEmit(true, true, false, true); // Expect the NewDelegate event to be emitted
        emit NewDelegate(user1, _groupId, 0, new address[](0), 1); // Emit the NewDelegate event with the expected parameters
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group
        vm.stopPrank(); // Stop user1's prank state
    }

    function testCannotBecomeDelegateTwice() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a group member
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group
        // Expect a revert when user1 tries to become a delegate again
        vm.expectRevert(abi.encodeWithSignature("D_AlreadyDelegate(uint256,address)", _groupId, user1));
        testPolls.becomeDelegate(_groupId); // Attempt to become a delegate again
        vm.stopPrank(); // Stop user1's prank state
    }

    function testCannotBecomeDelegateIfNotGroupMember() public {
        vm.startPrank(user2); // Set the caller to user2
        // Expect a revert when user2 tries to become a delegate without being a group member
        vm.expectRevert(abi.encodeWithSignature("D_NotGroupMember(uint256,address)", _groupId, user2));
        testPolls.becomeDelegate(_groupId); // Attempt to become a delegate
    }

    // DELETE FUNCTIONALITY
    function testRemoveDelegation() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a member of the group
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group
        vm.stopPrank(); // Stop user1's prank state

        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // User2 becomes a member of the group
        console.log("User2 is delegating to User1..."); // Log delegation action
        testPolls.delegateToDelegate(user1, _groupId); // User2 delegates to User1

        bool hasDelegated = testPolls.hasDelegatedToDelegateInGroup(_groupId, user1); // Check if User2 has delegated
        console.log("Has User2 delegated to User1:", hasDelegated); // Log result

        console.log("User2 is removing delegation from User1..."); // Log removal action
        testPolls.removeDelegation(user1, _groupId); // User2 removes delegation to User1

        bool hasDelegationRemoved = !testPolls.hasDelegatedToDelegateInGroup(_groupId, user1); // Check if delegation has been removed
        console.log("Has delegation been removed:", hasDelegationRemoved); // Log result

        vm.stopPrank(); // Stop user2's prank state
    }

    function testEmitDelegationRemoved() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a member of the group
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group

        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // User2 becomes a member of the group

        console.log("User2 is attempting to delegate to User1..."); // Log delegation attempt
        testPolls.delegateToDelegate(user1, _groupId); // User2 delegates to User1

        bool hasDelegated = testPolls.hasDelegatedToDelegateInGroup(_groupId, user1); // Check if User2 has delegated
        console.log("Has User2 delegated to User1:", hasDelegated); // Log delegation status

        vm.expectEmit(true, true, true, true); // Expect emit for DelegationRemoved event
        emit DelegationRemoved(user2, user1, _groupId); // Emit DelegationRemoved event

        console.log("User2 is attempting to remove delegation from User1..."); // Log removal attempt
        testPolls.removeDelegation(user1, _groupId); // User2 removes delegation to User1

        bool hasDelegationRemoved = !testPolls.hasDelegatedToDelegateInGroup(_groupId, user1); // Check if delegation has been removed
        console.log("Has delegation been removed:", hasDelegationRemoved); // Log result

        vm.stopPrank(); // Stop user2's prank state
    }

    function testCannotRemoveDelegationIfNotDelegated() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a member of the group
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group
        vm.stopPrank(); // Stop user1's prank state

        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // User2 becomes a member of the group

        vm.expectRevert( // Expect revert due to no delegation present
        abi.encodeWithSignature("D_NoDelegationToRemove(uint256,address,address)", _groupId, user2, user1));
        testPolls.removeDelegation(user1, _groupId); // User2 attempts to remove delegation to User1
        vm.stopPrank(); // Stop user2's prank state
    }

    // RESIGNING FUNCTIONALITY
    function testResignAsDelegate() internal {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId); // user1 becomes a group member
        testPolls.becomeDelegate(_groupId); // user1 becomes a delegate
        bool isDelegate = testPolls.addressIsDelegate(_groupId, user1);
        assertEq(isDelegate, true, "User1 should be a delegate in the group");

        testPolls.resignAsDelegate(_groupId); // user1 resigns as a delegate
        bool isStillDelegate = testPolls.addressIsDelegate(_groupId, user1);
        assertEq(isStillDelegate, false, "User1 should no longer be a delegate after resigning");
        vm.stopPrank();
    }

    function testEmitDelegateResignation() internal {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a member of the group
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group

        vm.expectEmit(true, true, false, true); // Expect the DelegateResignation event to be emitted
        emit DelegateResignation(user1, _groupId); // Prepare to emit the event
        testPolls.resignAsDelegate(_groupId); // User1 resigns as delegate
        vm.stopPrank(); // Stop user1's prank state
    }

    function testRemoveDelegationsAfterResignation() internal {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // User1 becomes a member of the group
        testPolls.becomeDelegate(_groupId); // User1 becomes a delegate for the group
        vm.stopPrank(); // Stop user1's prank state

        // User2 delegates to User1
        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // User2 becomes a member of the group
        testPolls.delegateToDelegate(user1, _groupId); // User2 delegates their vote to User1
        vm.stopPrank(); // Stop user2's prank state

        // User1 should now have delegations from User2
        assertEq(testPolls.addressIsDelegate(_groupId, user1), true, "User1 should be a delegate with delegations");

        // User1 resigns, their delegations should be removed
        vm.startPrank(user1); // Set the caller back to user1
        testPolls.resignAsDelegate(_groupId); // User1 resigns as a delegate
        assertEq(testPolls.addressIsDelegate(_groupId, user1), false, "User1 should no longer be a delegate"); // Assert User1 is no longer a delegate
        vm.stopPrank(); // Stop user1's prank state
    }

    function testCannotResignIfNotDelegate() internal {
        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // user2 becomes a group member

        vm.expectRevert(abi.encodeWithSignature("D_NotADelegate(uint256,address)", _groupId, user2)); // Expect revert if user2 tries to resign without being a delegate
        testPolls.resignAsDelegate(_groupId); // This should fail
        vm.stopPrank(); // Stop user2's prank state
    }

    function testDelegateCountIncreaseWhenBecomingDelegate() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // user1 becomes a group member

        // Use the getter to check the initial delegate count
        uint256 initialCount = testPolls.getDelegateCount(_groupId); // Get the initial delegate count

        // Become a delegate and then check the final count
        testPolls.becomeDelegate(_groupId); // user1 becomes a delegate
        uint256 finalCount = testPolls.getDelegateCount(_groupId); // Get the final delegate count

        // Check if the delegate count increased by 1
        assertEq(finalCount, initialCount + 1, "Delegate count should increase by 1 when a new delegate is added."); // Assert the delegate count increase

        vm.stopPrank(); // Stop user1's prank state
    }

    function testVoteCountIncreaseWhenDelegating() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // user1 becomes a group member
        testPolls.becomeDelegate(_groupId); // user1 becomes a delegate
        vm.stopPrank(); // Stop user1's prank state

        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // user2 becomes a group member
        testPolls.delegateToDelegate(user1, _groupId); // user2 delegates their vote to user1

        uint256 voteCount = testPolls.getDelegateVoteCount(_groupId, user1); // Get the vote count for user1 as delegate
        assertEq(voteCount, 1, "Vote count should be 1 after delegating to a delegate."); // Assert the vote count increase
        vm.stopPrank(); // Stop user2's prank state
    }

    function testVoteCountDecreaseWhenRemovingDelegation() public {
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // user1 becomes a group member
        testPolls.becomeDelegate(_groupId); // user1 becomes a delegate
        vm.stopPrank(); // Stop user1's prank state

        vm.startPrank(user2); // Set the caller to user2
        testPolls.becomeMemberOfGroup(_groupId); // user2 becomes a group member
        testPolls.delegateToDelegate(user1, _groupId); // user2 delegates their vote to user1
        testPolls.removeDelegation(user1, _groupId); // user2 removes delegation from user1

        uint256 voteCount = testPolls.getDelegateVoteCount(_groupId, user1); // Get the vote count for user1 as delegate
        assertEq(voteCount, 0, "Vote count should be 0 after removing delegation."); // Assert the vote count decrease
        vm.stopPrank(); // Stop user2's prank state
    }

    function testResigningClearsDelegateData() public {
        // Step 1: user1 becomes a delegate
        vm.startPrank(user1); // Set the caller to user1
        testPolls.becomeMemberOfGroup(_groupId); // user1 becomes a group member
        testPolls.becomeDelegate(_groupId); // user1 becomes a delegate
        assertTrue(testPolls.addressIsDelegate(_groupId, user1), "User1 should be a delegate."); // Verify user1 is a delegate
        vm.stopPrank(); // Stop user1's prank state

        // Step 2: user1 resigns
        vm.startPrank(user1); // Set the caller to user1
        testPolls.resignAsDelegate(_groupId); // user1 resigns as a delegate
        vm.stopPrank(); // Stop user1's prank state

        // Step 3: Ensure user1 is no longer a delegate
        bool isStillDelegate = testPolls.addressIsDelegate(_groupId, user1); // Check if user1 is still a delegate
        assertEq(isStillDelegate, false, "User1 should no longer be a delegate after resigning."); // Assert that user1 is no longer a delegate
    }
}
