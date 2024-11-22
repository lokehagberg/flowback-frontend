// SPDX-License-Identifier: CPL-3.0
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "src/Polls.sol";
import "forge-std/Vm.sol";

contract RightToVoteTest is Test, Polls {
    Polls public testPolls; // Instance of the Polls contract for testing
    address user1 = address(0x1); // Address for user1
    address user2 = address(0x2); // Address for user2

    function setUp() public {   // Set up the test environment before each test
        testPolls = new Polls(); // Deploy a new instance of the Polls contract
    }
    function run() public {      // Function to run when broadcasting
        vm.broadcast(); // Broadcasting the transaction
    }

    function testbecomeMemberOfGroup(uint256 group) public {
    vm.startPrank(user1); // Set the caller to user1
    assertFalse(testPolls.isUserMemberOfGroup(group)); // Assert user1 is not a member of the group before joining
    vm.startPrank(user1); // Start the prank again for the same user
    testPolls.becomeMemberOfGroup(group); // User1 becomes a member of the specified group
    assertTrue(testPolls.isUserMemberOfGroup(group)); // Assert user1 is now a member of the group
    assertEq(testPolls.getGroupsUserIsMemberIn()[0], group); // Check if the group is in the list of groups user1 is a member of
    }
    function testRemoveGroupMembership(uint256 group) public {
    vm.startPrank(user1); // Set the caller to user1
    testPolls.becomeMemberOfGroup(group); // User1 becomes a member of the specified group
    assertTrue(testPolls.isUserMemberOfGroup(group)); // Assert user1 is a member of the group
    
    vm.startPrank(user1); // Start the prank again for user1
    testPolls.removeGroupMembership(group); // User1 removes themselves from the group
    assertEq(testPolls.isUserMemberOfGroup(group), false); // Assert user1 is no longer a member of the group
    
    vm.startPrank(user1); // Start the prank again for user1
    testPolls.becomeMemberOfGroup(1); // User1 becomes a member of group 1
    vm.startPrank(user1); // Start the prank again for user1
    testPolls.becomeMemberOfGroup(2); // User1 becomes a member of group 2
    vm.startPrank(user1); // Start the prank again for user1
    testPolls.becomeMemberOfGroup(3); // User1 becomes a member of group 3
    
    uint256[] memory groupsOne = testPolls.getGroupsUserIsMemberIn(); // Retrieve the list of groups user1 is a member of
    assertEq(groupsOne.length, 3); // Assert user1 is in three groups
    
    vm.startPrank(user1); // Start the prank again for user1
    testPolls.removeGroupMembership(2); // User1 removes themselves from group 2
    
    uint256[] memory groups = testPolls.getGroupsUserIsMemberIn(); // Retrieve the updated list of groups
    assertEq(testPolls.getGroupsUserIsMemberIn()[0], 1); // Assert user1 is still a member of group 1
    assertEq(testPolls.getGroupsUserIsMemberIn()[1], 3); // Assert user1 is still a member of group 3
    assertEq(groups.length, 2); // Assert the length of groups is now 2
    }
    function testGetGroupsUserIsMemberIn() public {
    uint256[] memory groupsOne = testPolls.getGroupsUserIsMemberIn(); // Retrieve the initial list of groups for the user
    assertEq(groupsOne.length, 0); // Assert that the user has no group memberships initially

    vm.startPrank(user1); // Set the caller to user1
    testPolls.becomeMemberOfGroup(1); // User1 becomes a member of group 1
    vm.startPrank(user1); // Start the prank again for user1
    testPolls.becomeMemberOfGroup(4); // User1 becomes a member of group 4

    uint256[] memory groups = testPolls.getGroupsUserIsMemberIn(); // Retrieve the updated list of groups
    assertTrue(groups.length > 0); // Assert that user1 is now a member of at least one group
    assertEq(groups.length, 2); // Assert that user1 is a member of exactly two groups
    assertEq(testPolls.getGroupsUserIsMemberIn()[0], 1); // Assert that group 1 is included in the list
    assertEq(testPolls.getGroupsUserIsMemberIn()[1], 4); // Assert that group 4 is included in the list

    vm.startPrank(user1); // Start the prank again for user1
    testPolls.becomeMemberOfGroup(3); // User1 becomes a member of group 3
    assertEq(testPolls.getGroupsUserIsMemberIn()[2], 3); // Assert that user1 is now also a member of group 3
    }
}
