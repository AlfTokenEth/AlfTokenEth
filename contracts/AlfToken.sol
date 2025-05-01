// SPDX-License-Identifier: UNLICENSED
// AlfToken.sol
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./RoleManager.sol";
import "./TaxManager.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AlfToken is
    ERC20("ALF", "ALF"),
    Pausable,
    RoleManager,
    TaxManager(msg.sender),
    ERC20Permit("ALF"),
    ERC20Votes,
    ReentrancyGuard
{
    uint256 public maxTransferLimit;
    bool public applyTransferLimit;
    bool public appyControlTransferLimit;
    mapping(address => bool) private controlList;
    address[] public controlListAddresses;
    mapping(address => bool) private pairList;
    event Log(string message);

    constructor(address admin, address multisigWallet, uint256 _initialSupply) {
        require(_initialSupply > 0, "Initial supply must be greater than zero");
        emit Log("Initial supply is valid");

        applyTransferLimit = false; // Default: limit is not applied
        appyControlTransferLimit = false; // Default: limit is  applied

        _mint(multisigWallet, _initialSupply);
        emit Log("Minting initial supply to multisig wallet");
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(msg.sender, _value);
    }

    /**
     * @param recipient The address to transfer to.
     * @param amount The amount to be transferred.
     * @return A boolean that indicates if the operation was successful.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        return super.transfer(recipient, amount);
    }

   /**
     * @param recipient The address to transfer to.
     * @param amount The amount to be transferred.
     * @return A boolean that indicates if the operation was successful.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        override
        returns (bool)
    {
        return super.transferFrom(sender, recipient, amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused nonReentrant {
        bool iscontrolList = controlList[from] || controlList[to];
        bool ispair = false;
        uint256 taxAmount = 0;
        uint256 netAmount = amount;

        //IsControlTransferLimit Applied? If yes, check if sender or receiver is ControlListed
        if (appyControlTransferLimit) {
            require(
                iscontrolList,
                "Transfer not allowed: sender or receiver must be controllisted"
            );
        }

        //Check if from or to is in pair
        if (isInPair(from) || isInPair(to)) {
            ispair = true;
        }

        //Check transfer limit if transfer limit is applied and ispair is true and iscontrolList is false
        if (ispair && !iscontrolList && applyTransferLimit) {
            require(
                amount <= maxTransferLimit,
                "Transfer amount exceeds the maximum transfer limit"
            );
        }

        if (ispair && !iscontrolList) {
            taxAmount = calculateTax(amount);
            netAmount = amount - taxAmount;
        }
        if (taxAmount > 0) {
            super._transfer(from, taxAccount, taxAmount);
        }
        super._transfer(from, to, netAmount);
    }
    /**
     * @dev Pauses all token transfers.
     * Can only be called by an admin.
     */
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     * Can only be called by an admin.
     */
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Adds an address to the controlList.
     * Can only be called by an admin.
     * @param account The address to be added to the controlList.
     */
    function addToControlList(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!controlList[account]) {
            controlList[account] = true;
            controlListAddresses.push(account);
        }
    }

    /**
     * @dev Removes an address from the controlList.
     * Can only be called by an admin.
     * @param account The address to be removed from the controlList.
     */
    function removeFromControlList(
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (controlList[account]) {
            controlList[account] = false;
            for (uint256 i = 0; i < controlListAddresses.length; i++) {
                if (controlListAddresses[i] == account) {
                    controlListAddresses[i] = controlListAddresses[
                        controlListAddresses.length - 1
                    ];
                    controlListAddresses.pop();
                    break;
                }
            }
        }
    }
    function getcontrolListAddresses() public view returns (address[] memory) {
        return controlListAddresses;
    }

    /**
     * @dev Sets whether only controlListed addresses can transfer tokens.
     * Can only be called by an admin.
     * @param _appyControlTransferLimit Boolean indicating whether only controlListed addresses can transfer tokens.
     */
    function setApplyControlTransferLimit(
        bool _appyControlTransferLimit
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        appyControlTransferLimit = _appyControlTransferLimit;
    }

    /**
     * @dev Sets the maximum transfer limit.
     * Can only be called by an admin.
     * @param _maxTransferLimit The maximum transfer limit to be set.
     */
    function setMaxTransferLimit(
        uint256 _maxTransferLimit
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxTransferLimit = _maxTransferLimit;
    }

    /**
     * @dev Sets whether the transfer limit should be applied.
     * Can only be called by an admin.
     * @param _applyTransferLimit Boolean indicating whether the transfer limit should be applied.
     */
    function setApplyTransferLimit(
        bool _applyTransferLimit
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        applyTransferLimit = _applyTransferLimit;
    }

    //Add Pair into the list.
    function addPair(address pair) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(pair != address(0), "Invalid address");
        pairList[pair] = true;
    }

    //Remove Pair from the list.
    function removePair(address pair) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(pair != address(0), "Invalid address");
        pairList[pair] = false;
    }

    // Check if the pair is in the list.
    function isInPair(address pair) public view returns (bool) {
        return pairList[pair];
    }

    // Override required by Solidity for ERC20Votes
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
