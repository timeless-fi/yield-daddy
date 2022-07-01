// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {IStETH} from "./external/IStETH.sol";

/// @title StETHERC4626
/// @author zefram.eth
/// @notice ERC4626 wrapper for Lido stETH
/// @dev Uses stETH's internal shares accounting instead of using regular vault accounting
/// since this prevents attackers from atomically increasing the vault's share value
/// and exploiting lending protocols that use this vault as a borrow asset.
contract StETHERC4626 is ERC4626 {
    /// -----------------------------------------------------------------------
    /// Libraries usage
    /// -----------------------------------------------------------------------

    using FixedPointMathLib for uint256;

    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Lido stETH contract
    IStETH public immutable stETH;

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
        return stETH.balanceOf(address(this));
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