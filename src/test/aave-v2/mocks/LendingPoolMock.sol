// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {ERC20} from "solmate/tokens/ERC20.sol";

import {ERC20Mock} from "../../mocks/ERC20Mock.sol";
import {ILendingPool} from "../../../aave-v2/external/ILendingPool.sol";

contract LendingPoolMock is ILendingPool {
    mapping(address => address) internal reserveAToken;
    bool public override paused;

    function setReserveAToken(address _reserve, address _aTokenAddress) external {
        reserveAToken[_reserve] = _aTokenAddress;
    }

    function deposit(address asset, uint256 amount, address onBehalfOf, uint16) external override {
        require(!paused, "PAUSED");

        // Transfer asset
        ERC20 token = ERC20(asset);
        token.transferFrom(msg.sender, address(this), amount);

        // Mint aTokens
        address aTokenAddress = reserveAToken[asset];
        ERC20Mock aToken = ERC20Mock(aTokenAddress);
        aToken.mint(onBehalfOf, amount);
    }

    function withdraw(address asset, uint256 amount, address to) external override returns (uint256) {
        require(!paused, "PAUSED");

        // Burn aTokens
        address aTokenAddress = reserveAToken[asset];
        ERC20Mock aToken = ERC20Mock(aTokenAddress);
        aToken.burn(msg.sender, amount);

        // Transfer asset
        ERC20 token = ERC20(asset);
        token.transfer(to, amount);
        return amount;
    }

    function getReserveData(address asset) external view override returns (ILendingPool.ReserveData memory data) {
        data.aTokenAddress = reserveAToken[asset];
    }

    function setPaused(bool paused_) external {
        paused = paused_;
    }
}
