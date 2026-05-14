// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./IStableCoin.sol";

/**
 * @title StableCoin
 * @dev Implementation of a stablecoin with multiple minters support
 */
contract StableCoin is ERC20Upgradeable, OwnableUpgradeable, AccessControlUpgradeable, IStableCoin {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bool public mintPaused;
    bool public burningPaused;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name,
        string memory symbol
    ) public initializer {
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Modifier that checks if the caller has minter role
     */
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "StableCoin: caller is not a minter");
        _;
    }

    /**
     * @dev Mints new tokens. Only callable by addresses with MINTER_ROLE.
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyMinter {
        require(!mintPaused, "StableCoin: minting is paused");
        _mint(to, amount);
    }

    /**
     * @dev Burns tokens. Only callable by addresses with MINTER_ROLE.
     * @param from The address whose tokens will be burned
     * @param amount The amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlyMinter {
        require(!burningPaused, "StableCoin: burning is paused");
        _burn(from, amount);
    }

    /**
     * @dev Sets pause status for minting and burning operations.
     * @param _mintPaused The pause status for minting
     * @param _burningPaused The pause status for burning
     * Only callable by owner.
     */
    function setPauseStatus(bool _mintPaused, bool _burningPaused) external onlyOwner {
        if (mintPaused != _mintPaused) {
            mintPaused = _mintPaused;
            if (_mintPaused) {
                emit MintingPaused();
            } else {
                emit MintingUnpaused();
            }
        }

        if (burningPaused != _burningPaused) {
            burningPaused = _burningPaused;
            if (_burningPaused) {
                emit BurningPaused();
            } else {
                emit BurningUnpaused();
            }
        }
    }

    /**
     * @dev Grants minter role to an address. Only callable by owner.
     * @param account The address to grant minter role to
     */
    function addMinter(address account) external onlyOwner {
        require(account != address(0), "StableCoin: invalid address");
        grantRole(MINTER_ROLE, account);
        emit MinterAdded(account);
    }

    /**
     * @dev Revokes minter role from an address. Only callable by owner.
     * @param account The address to revoke minter role from
     */
    function removeMinter(address account) external onlyOwner {
        revokeRole(MINTER_ROLE, account);
        emit MinterRemoved(account);
    }

    /**
     * @dev Checks if an address is a minter
     * @param account The address to check
     * @return Boolean indicating if the address has minter role
     */
    function isMinter(address account) external view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }
}
