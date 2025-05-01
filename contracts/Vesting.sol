// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract VestingContract  {
    IERC20 public immutable token;

    struct VestingInfo {
        address beneficiary;
        uint256 startTime;
        uint256 totalAmount;
        uint256 monthlyAmount;
        uint256 released;
    }
