// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RoleManager is AccessControl {

    constructor() {
        //_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addRole(
        address account,
        bytes32 role
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(role, account);
    }

    /**
     * @dev Revokes the specified role from an account.
     * @param role The role to revoke.
     * @param account The account to revoke the role from.
     */
    function removeRole(
        address account,
        bytes32 role
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(role, account);
    }
}
