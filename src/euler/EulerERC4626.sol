// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {IEulerEToken} from "./external/IEulerEToken.sol";

/// @title EulerERC4626
/// @author zefram.eth
/// @notice ERC4626 wrapper for Euler Finance
contract EulerERC4626 is ERC4626 {
    /// -----------------------------------------------------------------------
    /// Libraries usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for ERC20;

    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Euler main contract address
    /// @dev Target of ERC20 approval when depositing
    address public immutable euler;

    /// @notice The Euler eToken contract
    IEulerEToken public immutable eToken;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(ERC20 asset_, address euler_, IEulerEToken eToken_)
        ERC4626(asset_, _vaultName(asset_), _vaultSymbol(asset_))
    {
        euler = euler_;
        eToken = eToken_;
    }

    /// -----------------------------------------------------------------------
    /// ERC4626 overrides
    /// -----------------------------------------------------------------------

    function totalAssets() public view virtual override returns (uint256) {
        return eToken.balanceOfUnderlying(address(this));
    }

    function beforeWithdraw(uint256 assets, uint256 /*shares*/ )
        internal
        virtual
        override
    {
        /// -----------------------------------------------------------------------
        /// Withdraw assets from Euler
        /// -----------------------------------------------------------------------

        eToken.withdraw(0, assets);
    }

    function afterDeposit(uint256 assets, uint256 /*shares*/ )
        internal
        virtual
        override
    {
        /// -----------------------------------------------------------------------
        /// Deposit assets into Euler
        /// -----------------------------------------------------------------------

        // approve to euler
        asset.safeApprove(address(euler), assets);

        // deposit into eToken
        eToken.deposit(0, assets);
    }

    /// -----------------------------------------------------------------------
    /// ERC20 metadata generation
    /// -----------------------------------------------------------------------

    function _vaultName(ERC20 asset_)
        internal
        view
        virtual
        returns (string memory vaultName)
    {
        vaultName = string.concat("ERC4626-Wrapped Euler ", asset_.symbol());
    }

    function _vaultSymbol(ERC20 asset_)
        internal
        view
        virtual
        returns (string memory vaultSymbol)
    {
        vaultSymbol = string.concat("we", asset_.symbol());
    }
}