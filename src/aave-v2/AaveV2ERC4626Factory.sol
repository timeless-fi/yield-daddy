// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {AaveV2ERC4626} from "./AaveV2ERC4626.sol";
import {IAaveMining} from "./external/IAaveMining.sol";
import {ILendingPool} from "./external/ILendingPool.sol";
import {ERC4626Factory} from "../base/ERC4626Factory.sol";

/// @title AaveV2ERC4626Factory
/// @author zefram.eth
/// @notice Factory for creating AaveV2ERC4626 contracts
contract AaveV2ERC4626Factory is ERC4626Factory {
    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Aave liquidity mining contract
    IAaveMining public immutable aaveMining;

    /// @notice The address that will receive the liquidity mining rewards (if any)
    address public immutable rewardRecipient;

    /// @notice The Aave LendingPool contract
    ILendingPool public immutable lendingPool;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        IAaveMining aaveMining_,
        address rewardRecipient_,
        ILendingPool lendingPool_
    ) {
        aaveMining = aaveMining_;
        lendingPool = lendingPool_;
        rewardRecipient = rewardRecipient_;
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
        vault =
        new AaveV2ERC4626{salt: bytes32(0)}(asset, aaveMining, rewardRecipient, lendingPool);

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
                        type(AaveV2ERC4626).creationCode,
                        // Constructor arguments:
                        abi.encode(asset, aaveMining, rewardRecipient, lendingPool)
                    )
                )
            )
        );
    }
}