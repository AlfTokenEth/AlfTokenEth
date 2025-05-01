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

    mapping(string => VestingInfo) public vestingGroups;

    event TokensReleased(address indexed beneficiary, uint256 amount);
    constructor(
        IERC20 _token,
        address OO,
        address OC,
        address OG,
        address OM,
        address OA,
        address OAT,
        address OCN,
        address OB,
        address OMP,
        uint256 teamTotalAmount,
        uint256 ATotalAmount
    ) {
        token = _token;

        vestingGroups["TeamO"] = VestingInfo({
            beneficiary: OO,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: teamTotalAmount/4,
            monthlyAmount: teamTotalAmount / 24, // 6 months
            released: 0
        });

        vestingGroups["TeamC"] = VestingInfo({
            beneficiary: OC,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: teamTotalAmount/4,
            monthlyAmount: teamTotalAmount / 24, // 6 months
            released: 0
        });

        vestingGroups["TeamG"] = VestingInfo({
            beneficiary: OG,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: teamTotalAmount/4,
            monthlyAmount: teamTotalAmount / 24, // 6 months
            released: 0
        });

        vestingGroups["TeamM"] = VestingInfo({
            beneficiary: OM,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: teamTotalAmount/4,
            monthlyAmount: teamTotalAmount / 24, // 6 months
            released: 0
        });

        vestingGroups["TeamA"] = VestingInfo({
            beneficiary: OA,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: ATotalAmount,
            monthlyAmount: ATotalAmount,
            released: 0
        });
        vestingGroups["TeamAT"] = VestingInfo({
            beneficiary: OAT,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: 414000000000 ether,
            monthlyAmount: (414000000000 ether) / 6,
            released: 0
        });

        vestingGroups["TeamCN"] = VestingInfo({
            beneficiary: OCN,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: 92000000004 ether,
            monthlyAmount: (92000000004 ether)/6,
            released: 0
        });

        vestingGroups["TeamB"] = VestingInfo({
            beneficiary: OB,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: 92000000004 ether,
            monthlyAmount: (92000000004 ether)/6,
            released: 0
        });
        vestingGroups["TeamMP"] = VestingInfo({
            beneficiary: OMP,
            startTime: 1739232000, // 11 Feb 2025, Unix timestamp
            totalAmount: 92000000004 ether,
            monthlyAmount: (92000000004 ether)/6,
            released: 0
        });

        vestingGroups["RewardsO"] = VestingInfo({
            beneficiary: OO,
            startTime: 1733020800, // 1 Dec 2024, Unix timestamp
            totalAmount: 862500000000 ether,
            monthlyAmount: (862500000000 ether) / 6, // 6 month
            released: 0
        });

        vestingGroups["RewardsC"] = VestingInfo({
            beneficiary: OC,
            startTime: 1733020800, // 1 Dec 2024, Unix timestamp
            totalAmount: 862500000000 ether,
            monthlyAmount: (862500000000 ether) / 6, // 6 month
            released: 0
        });

        vestingGroups["RewardsG"] = VestingInfo({
            beneficiary: OG,
            startTime: 1733020800, // 1 Dec 2024, Unix timestamp
            totalAmount: 1600800000000 ether,
            monthlyAmount: (1600800000000 ether) / 6, // 6 month
            released: 0
        });

        vestingGroups["RewardsM"] = VestingInfo({
            beneficiary: OM,
            startTime: 1733020800, // 1 Dec 2024, Unix timestamp
            totalAmount: 1400700000000 ether,
            monthlyAmount: (1400700000000 ether) / 6, // 6 month
            released: 0
        });
        vestingGroups["Sample"] = VestingInfo({
            beneficiary: OA,
            startTime: 1727740800, // 1 october 2024, Unix timestamp
            totalAmount: 10 ether,
            monthlyAmount: (10 ether) / 5, // 6 month
            released: 0
        });

    }

    /**
     * @dev Releases vested tokens for a specific group.
     * @param group The name of the vesting group (e.g., "Team", "Ecosystem", or "CommunityRewards").
     */
    function releaseTokens(string memory group) external {
        VestingInfo storage vesting = vestingGroups[group];
        require(vesting.totalAmount > 0, "No tokens to release");

        uint256 monthsElapsed = (block.timestamp - vesting.startTime) / 30 days;
        uint256 calculatedVestedAmount = monthsElapsed * vesting.monthlyAmount;
        if (calculatedVestedAmount > vesting.totalAmount) {
            calculatedVestedAmount = vesting.totalAmount;
        }

        uint256 releasableAmount = calculatedVestedAmount - vesting.released;
        require(releasableAmount > 0, "No tokens to release");

        vesting.released += releasableAmount;
        require(
            token.transfer(vesting.beneficiary, releasableAmount),
            "Transfer failed"
        );

        emit TokensReleased(vesting.beneficiary, releasableAmount);
    }

    /**
     * @dev Returns the amount of tokens that have been released for a specific group.
     * @param group The name of the vesting group (e.g., "Team", "Ecosystem", or "CommunityRewards").
     * @return The amount of tokens that have been released.
     */
    function releasedAmount(
        string memory group
    ) external view returns (uint256) {
        return vestingGroups[group].released;
    }

    /**
     * @dev Returns the amount of tokens that are still vested but not yet released for a specific group.
     * @param group The name of the vesting group (e.g., "Team", "Ecosystem", or "CommunityRewards").
     * @return The amount of tokens that are still vested but not yet released.
     */
    function vestedAmount(string memory group) external view returns (uint256) {
        VestingInfo storage vesting = vestingGroups[group];
        uint256 monthsElapsed = (block.timestamp - vesting.startTime) / 30 days;
        uint256 calculatedVestedAmount = monthsElapsed * vesting.monthlyAmount;
        if (calculatedVestedAmount > vesting.totalAmount) {
            calculatedVestedAmount = vesting.totalAmount;
        }
        return calculatedVestedAmount - vesting.released;
    }
}
