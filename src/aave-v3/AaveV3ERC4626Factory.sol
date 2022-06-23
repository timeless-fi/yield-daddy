// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {IPool} from "./external/IPool.sol";
import {AaveV3ERC4626} from "./AaveV3ERC4626.sol";
import {ERC4626Factory} from "../base/ERC4626Factory.sol";
import {IRewardsController} from "./external/IRewardsController.sol";

/// @title AaveV3ERC4626Factory
/// @author zefram.eth
/// @notice Factory for creating AaveV3ERC4626 contracts
contract AaveV3ERC4626Factory is ERC4626Factory {
    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Aave Pool contract
    IPool public immutable lendingPool;

    /// @notice The address that will receive the liquidity mining rewards (if any)
    address public immutable rewardRecipient;

    /// @notice The Aave RewardsController contract
    IRewardsController public immutable rewardsController;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        IPool lendingPool_,
        address rewardRecipient_,
        IRewardsController rewardsController_
    ) {
        lendingPool = lendingPool_;
        rewardRecipient = rewardRecipient_;
        rewardsController = rewardsController_;
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
        new AaveV3ERC4626{salt: bytes32(0)}(asset, lendingPool, rewardRecipient, rewardsController);

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
                        type(AaveV3ERC4626).creationCode,
                        // Constructor arguments:
                        abi.encode(asset, lendingPool, rewardRecipient, rewardsController)
                    )
                )
            )
        );
    }
}