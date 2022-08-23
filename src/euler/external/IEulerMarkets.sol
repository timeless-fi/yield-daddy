// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

/// @notice Activating and querying markets, and maintaining entered markets lists
interface IEulerMarkets {
    /// @notice Given an underlying, lookup the associated EToken
    /// @param underlying Token address
    /// @return EToken address, or address(0) if not activated
    function underlyingToEToken(address underlying) external view returns (address);
}
