// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import {IEulerMarkets} from "../../../euler/external/IEulerMarkets.sol";

contract EulerMarketsMock is IEulerMarkets {
    mapping(address => address) public override underlyingToEToken;

    function setETokenForUnderlying(address underlying, address eToken) external {
        underlyingToEToken[underlying] = eToken;
    }
}
