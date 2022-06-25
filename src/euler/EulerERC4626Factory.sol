// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {EulerERC4626} from "./EulerERC4626.sol";
import {IEulerEToken} from "./external/IEulerEToken.sol";
import {ERC4626Factory} from "../base/ERC4626Factory.sol";
import {IEulerMarkets} from "./external/IEulerMarkets.sol";

/// @title EulerERC4626Factory
/// @author zefram.eth
/// @notice Factory for creating EulerERC4626 contracts
contract EulerERC4626Factory is ERC4626Factory {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @notice Thrown when trying to deploy an EulerERC4626 vault using an asset without an eToken
    error EulerERC4626Factory__ETokenNonexistent();

    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Euler main contract address
    /// @dev Target of ERC20 approval when depositing
    address public immutable euler;

    /// @notice The Euler markets module address
    IEulerMarkets public immutable markets;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(address euler_, IEulerMarkets markets_) {
        euler = euler_;
        markets = markets_;
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc ERC4626Factory
    function createERC4626(ERC20 asset)
        external
        virtual
        override
        returns (ERC4626 vault)
    {
        address eTokenAddress = markets.underlyingToEToken(address(asset));
        if (eTokenAddress == address(0)) {
            revert EulerERC4626Factory__ETokenNonexistent();
        }

        vault =
        new EulerERC4626{salt: bytes32(0)}(asset, euler, IEulerEToken(eTokenAddress));

        emit CreateERC4626(asset, vault);
    }

    /// @inheritdoc ERC4626Factory
    function computeERC4626Address(ERC20 asset)
        external
        view
        virtual
        override
        returns (ERC4626 vault)
    {
        vault = ERC4626(
            _computeCreate2Address(
                keccak256(
                    abi.encodePacked(
                        // Deployment bytecode:
                        type(EulerERC4626).creationCode,
                        // Constructor arguments:
                        abi.encode(
                            asset, euler, IEulerEToken(markets.underlyingToEToken(address(asset)))
                        )
                    )
                )
            )
        );
    }
}