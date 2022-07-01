// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {PoolMock} from "./mocks/PoolMock.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {IPool} from "../../src/aave-v3/external/IPool.sol";
import {AaveV3ERC4626} from "../../src/aave-v3/AaveV3ERC4626.sol";
import {RewardsControllerMock} from "./mocks/RewardsControllerMock.sol";
import {AaveV3ERC4626Factory} from "../../src/aave-v3/AaveV3ERC4626Factory.sol";
import {IRewardsController} from "../../src/aave-v3/external/IRewardsController.sol";

contract AaveV3ERC4626FactoryTest is Test {
    address public constant rewardRecipient = address(0x01);

    ERC20Mock public aave;
    ERC20Mock public aToken;
    ERC20Mock public underlying;
    PoolMock public lendingPool;
    AaveV3ERC4626Factory public factory;
    IRewardsController public rewardsController;

    function setUp() public {
        aave = new ERC20Mock();
        aToken = new ERC20Mock();
        underlying = new ERC20Mock();
        lendingPool = new PoolMock();
        rewardsController = new RewardsControllerMock(address(aave));
        factory =
        new AaveV3ERC4626Factory(lendingPool, rewardRecipient, rewardsController);

        lendingPool.setReserveAToken(address(underlying), address(aToken));
    }

    function test_createERC4626() public {
        AaveV3ERC4626 vault =
            AaveV3ERC4626(address(factory.createERC4626(underlying)));

        assertEq(address(vault.aToken()), address(aToken), "aToken incorrect");
        assertEq(
            address(vault.lendingPool()),
            address(lendingPool),
            "lendingPool incorrect"
        );
        assertEq(
            address(vault.rewardsController()),
            address(rewardsController),
            "rewardsController incorrect"
        );
        assertEq(
            address(vault.rewardRecipient()),
            address(rewardRecipient),
            "rewardRecipient incorrect"
        );
    }

    function test_computeERC4626Address() public {
        AaveV3ERC4626 vault =
            AaveV3ERC4626(address(factory.createERC4626(underlying)));

        assertEq(
            address(factory.computeERC4626Address(underlying)),
            address(vault),
            "computed vault address incorrect"
        );
    }

    function test_fail_createERC4626ForAssetWithoutAToken() public {
        ERC20Mock fakeAsset = new ERC20Mock();
        vm.expectRevert(
            abi.encodeWithSignature("AaveV3ERC4626Factory__ATokenNonexistent()")
        );
        factory.createERC4626(fakeAsset);
    }
}