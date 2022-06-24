// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract EulerMock {
    function transferTokenFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    )
        external
    {
        token.transferFrom(from, to, amount);
    }
}