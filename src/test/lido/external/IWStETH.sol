// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";

abstract contract IWStETH is ERC20 {
    function unwrap(uint256 _wstETHAmount) external virtual returns (uint256);
    function getWstETHByStETH(uint256 _stETHAmount) external view virtual returns (uint256);
}
