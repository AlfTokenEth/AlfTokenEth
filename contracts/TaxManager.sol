// SPDX-License-Identifier: UNLICENSED
// TaxManager.sol
pragma solidity ^0.8.19;

import "./RoleManager.sol";

contract TaxManager is RoleManager {
    address public taxAccount; // Tax account address

    constructor(address _taxAccount) {
        require(_taxAccount != address(0), "Tax account cannot be the zero address");
        taxAccount = _taxAccount; // Tax account address is deployer address by default
    }
    function setTaxAccount(address _taxAccount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_taxAccount != address(0), "Tax account cannot be the zero address");
        taxAccount = _taxAccount;
    }

    function calculateTax(uint256 amount) public pure returns (uint256) {
        return amount / 100;
    }
}
