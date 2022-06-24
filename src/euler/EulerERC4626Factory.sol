// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {EulerERC4626} from "./EulerERC4626.sol";
import {ERC4626Factory} from "../base/ERC4626Factory.sol";
import {IEulerMarkets} from "./external/IEulerMarkets.sol";

/// @title EulerERC4626Factory
/// @author zefram.eth
/// @notice Factory for creating EulerERC4626 contracts
contract EulerERC4626Factory is ERC4626Factory {
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
        vault = new EulerERC4626{salt: bytes32(0)}(asset, euler, markets);

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
                        abi.encode(asset, euler, markets)
                    )
                )
            )
        );
    }
}