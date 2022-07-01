// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {IStEth} from "./external/IStEth.sol";

/// @title StETHERC4626
/// @author zefram.eth
/// @notice ERC4626 wrapper for Lido stETH
contract StETHERC4626 is ERC4626 {
    /// -----------------------------------------------------------------------
    /// Libraries usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for ERC20;

    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Lido stETH contract
    IStEth public immutable stETH;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(ERC20 asset_, IStETH stETH_)
        ERC4626(asset_, "ERC4626-Wrapped Lido stETH", "wlstETH")
    {
        stETH = stETH_;
    }

    /// -----------------------------------------------------------------------
    /// ERC4626 overrides
    /// -----------------------------------------------------------------------

    function totalAssets() public view virtual override returns (uint256) {
        return stETH.getPooledEthByShares(totalSupply);
    }

    function convertToShares(uint256 assets)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 supply = stETH.totalSupply();

        return
            supply == 0
            ? assets
            : assets.mulDivDown(stETH.getTotalShares(), supply);
    }

    function convertToAssets(uint256 shares)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 totalShares = stETH.getTotalShares();

        return
            totalShares == 0
            ? shares
            : shares.mulDivDown(stETH.totalSupply(), totalShares);
    }

    function previewMint(uint256 shares)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 totalShares = stETH.getTotalShares();

        return
            totalShares == 0
            ? shares
            : shares.mulDivUp(stETH.totalSupply(), totalShares);
    }

    function previewWithdraw(uint256 assets)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 supply = stETH.totalSupply();

        return
            supply == 0
            ? assets
            : assets.mulDivUp(stETH.getTotalShares(), supply);
    }
}