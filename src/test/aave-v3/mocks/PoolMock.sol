// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {ERC20} from "solmate/tokens/ERC20.sol";

import {ERC20Mock} from "../../mocks/ERC20Mock.sol";
import {IPool} from "../../../aave-v3/external/IPool.sol";

contract PoolMock is IPool {
    mapping(address => address) internal reserveAToken;

    function setReserveAToken(address _reserve, address _aTokenAddress)
        external
    {
        reserveAToken[_reserve] = _aTokenAddress;
    }

    function supply(address asset, uint256 amount, address onBehalfOf, uint16)
        external
        override
    {
        // Transfer asset
        ERC20 token = ERC20(asset);
        token.transferFrom(msg.sender, address(this), amount);

        // Mint aTokens
        address aTokenAddress = reserveAToken[asset];
        ERC20Mock aToken = ERC20Mock(aTokenAddress);
        aToken.mint(onBehalfOf, amount);
    }

    function withdraw(address asset, uint256 amount, address to)
        external
        override
        returns (uint256)
    {
        // Burn aTokens
        address aTokenAddress = reserveAToken[asset];
        ERC20Mock aToken = ERC20Mock(aTokenAddress);
        aToken.burn(msg.sender, amount);

        // Transfer asset
        ERC20 token = ERC20(asset);
        token.transfer(to, amount);
        return amount;
    }

    function getReserveData(address asset)
        external
        view
        override
        returns (IPool.ReserveData memory data)
    {
        data.aTokenAddress = reserveAToken[asset];
    }
}