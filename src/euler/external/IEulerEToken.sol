// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

/// @notice Tokenised representation of assets
interface IEulerEToken {
    /// @notice Balance of a particular account, in underlying units (increases as interest is earned)
    function balanceOfUnderlying(address account)
        external
        view
        returns (uint256);

    /// @notice Transfer underlying tokens from sender to the Euler pool, and increase account's eTokens
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 for full underlying token balance)
    function deposit(uint256 subAccountId, uint256 amount) external;

    /// @notice Transfer underlying tokens from Euler pool to sender, and decrease account's eTokens
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 for full pool balance)
    function withdraw(uint256 subAccountId, uint256 amount) external;
}