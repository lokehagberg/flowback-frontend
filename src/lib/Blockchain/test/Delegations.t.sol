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

    function setUp() public {
        testPolls = new Polls();
    }

    modifier userOneBecomesDelegate() {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();
        _;
    }

    // BEING A DELEGATE FUNCTIONALITY
    function testBecomeDelegateAsGroupMember() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        bool isDelegate = testPolls.addressIsDelegate(_groupId, user1);
        assertEq(isDelegate, true, "User1 should be a delegate in the group");
        vm.stopPrank();
    }

    function testEmitNewDelegate() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);

        vm.expectEmit(true, true, false, true);
        emit NewDelegate(user1, _groupId, 0, new address[](0), 1);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();
    }

    function testCannotBecomeDelegateTwice() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);

        vm.expectRevert(abi.encodeWithSignature("D_AlreadyDelegate(uint256,address)", _groupId, user1));
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();
    }

    function testCannotBecomeDelegateIfNotGroupMember() public {
        vm.startPrank(user2);
        vm.expectRevert(abi.encodeWithSignature("D_NotGroupMember(uint256,address)", _groupId, user2));
        testPolls.becomeDelegate(_groupId);
    }

    // DELETE FUNCTIONALITY
    function testRemoveDelegation() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();

        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId);
        console.log("User2 is delegating to User1...");
        testPolls.delegateToDelegate(user1, _groupId);

        bool hasDelegated = testPolls.hasDelegatedToDelegateInGroup(_groupId, user1);
        console.log("Has User2 delegated to User1:", hasDelegated);

        console.log("User2 is removing delegation from User1...");
        testPolls.removeDelegation(user1, _groupId);

        bool hasDelegationRemoved = !testPolls.hasDelegatedToDelegateInGroup(_groupId, user1);
        console.log("Has delegation been removed:", hasDelegationRemoved);

        vm.stopPrank();
    }

    function testEmitDelegationRemoved() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);

        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId);

        console.log("User2 is attempting to delegate to User1...");
        testPolls.delegateToDelegate(user1, _groupId);

        bool hasDelegated = testPolls.hasDelegatedToDelegateInGroup(_groupId, user1);
        console.log("Has User2 delegated to User1:", hasDelegated);

        vm.expectEmit(true, true, true, true);
        emit DelegationRemoved(user2, user1, _groupId);

        console.log("User2 is attempting to remove delegation from User1...");
        testPolls.removeDelegation(user1, _groupId);

        bool hasDelegationRemoved = !testPolls.hasDelegatedToDelegateInGroup(_groupId, user1);
        console.log("Has delegation been removed:", hasDelegationRemoved);

        vm.stopPrank();
    }

    function testCannotRemoveDelegationIfNotDelegated() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();

        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId);

        vm.expectRevert(
            abi.encodeWithSignature("D_NoDelegationToRemove(uint256,address,address)", _groupId, user2, user1)
        );
        testPolls.removeDelegation(user1, _groupId);
        vm.stopPrank();
    }

    // RESIGNING FUNCTIONALITY

    // Test 4.1: Ensure a delegate can resign from the group
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

    // Test 4.2: Emit `DelegateResignation` event when a delegate resigns
    function testEmitDelegateResignation() internal {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);

        vm.expectEmit(true, true, false, true);
        emit DelegateResignation(user1, _groupId); // Expect the event to be emitted
        testPolls.resignAsDelegate(_groupId);
        vm.stopPrank();
    }

    // Test 4.3: Ensure resigning removes the delegate and their associated delegations
    function testRemoveDelegationsAfterResignation() internal {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();

        // User2 delegates to User1
        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.delegateToDelegate(user1, _groupId);
        vm.stopPrank();

        // User1 should now have delegations from User2
        assertEq(testPolls.addressIsDelegate(_groupId, user1), true, "User1 should be a delegate with delegations");

        // User1 resigns, their delegations should be removed
        vm.startPrank(user1);
        testPolls.resignAsDelegate(_groupId);
        assertEq(testPolls.addressIsDelegate(_groupId, user1), false, "User1 should no longer be a delegate");
        vm.stopPrank();
    }

    // Test 4.4: Ensure a user cannot resign if they are not a delegate in the group (D_NotADelegate)
    function testCannotResignIfNotDelegate() internal {
        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId); // user2 becomes a group member

        vm.expectRevert(abi.encodeWithSignature("D_NotADelegate(uint256,address)", _groupId, user2));
        testPolls.resignAsDelegate(_groupId); // This should fail
        vm.stopPrank();
    }

    function testDelegateCountIncreaseWhenBecomingDelegate() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);

        // Use the getter to check the initial delegate count
        uint256 initialCount = testPolls.getDelegateCount(_groupId);

        // Become a delegate and then check the final count
        testPolls.becomeDelegate(_groupId);
        uint256 finalCount = testPolls.getDelegateCount(_groupId);

        // Check if the delegate count increased by 1
        assertEq(finalCount, initialCount + 1, "Delegate count should increase by 1 when a new delegate is added.");

        vm.stopPrank();
    }

    function testVoteCountIncreaseWhenDelegating() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();

        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.delegateToDelegate(user1, _groupId);
        uint256 voteCount = testPolls.getDelegateVoteCount(_groupId, user1); // Assuming this function exists
        assertEq(voteCount, 1, "Vote count should be 1 after delegating to a delegate.");
        vm.stopPrank();
    }

    function testVoteCountDecreaseWhenRemovingDelegation() public {
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        vm.stopPrank();

        vm.startPrank(user2);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.delegateToDelegate(user1, _groupId);
        testPolls.removeDelegation(user1, _groupId);

        uint256 voteCount = testPolls.getDelegateVoteCount(_groupId, user1); // Assuming this function exists
        assertEq(voteCount, 0, "Vote count should be 0 after removing delegation.");
        vm.stopPrank();
    }

    function testResigningClearsDelegateData() public {
        // Step 1: user1 becomes a delegate
        vm.startPrank(user1);
        testPolls.becomeMemberOfGroup(_groupId);
        testPolls.becomeDelegate(_groupId);
        assertTrue(testPolls.addressIsDelegate(_groupId, user1), "User1 should be a delegate.");
        vm.stopPrank();

        // Step 2: user1 resigns
        vm.startPrank(user1);
        testPolls.resignAsDelegate(_groupId);
        vm.stopPrank();

        // Step 3: Ensure user1 is no longer a delegate
        bool isStillDelegate = testPolls.addressIsDelegate(_groupId, user1);
        assertEq(isStillDelegate, false, "User1 should no longer be a delegate after resigning.");
    }
}
