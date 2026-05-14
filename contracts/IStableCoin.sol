// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStableCoin is IERC20 {

    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;

    function addMinter(address _minter) external;
    function removeMinter(address account) external;
    function isMinter(address account) external view returns (bool);
    function setPauseStatus(bool _mintPaused, bool _burningPaused) external;

    event MinterChanged(address indexed newMinter);
    event MintingPaused();
    event MintingUnpaused();
    event BurningPaused();
    event BurningUnpaused();
    event MinterRemoved(address indexed account);
    event MinterAdded(address indexed account);
}
