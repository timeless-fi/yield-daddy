// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {AaveMiningMock} from "./mocks/AaveMiningMock.sol";
import {LendingPoolMock} from "./mocks/LendingPoolMock.sol";
import {AaveV2ERC4626} from "../../aave-v2/AaveV2ERC4626.sol";
import {IAaveMining} from "../../aave-v2/external/IAaveMining.sol";
import {ILendingPool} from "../../aave-v2/external/ILendingPool.sol";
import {AaveV2ERC4626Factory} from "../../aave-v2/AaveV2ERC4626Factory.sol";

contract AaveV2ERC4626FactoryTest is Test {
    address public constant rewardRecipient = address(0x01);

    ERC20 public asset;
    ERC20 public aToken;
    ERC20Mock public aave;
    IAaveMining public aaveMining;
    LendingPoolMock public lendingPool;
    AaveV2ERC4626Factory public factory;

    function setUp() public {
        aave = new ERC20Mock();
        asset = new ERC20Mock();
        aToken = new ERC20Mock();
        lendingPool = new LendingPoolMock();
        aaveMining = new AaveMiningMock(address(aave));
        factory =
            new AaveV2ERC4626Factory(aaveMining, rewardRecipient, lendingPool);

        lendingPool.setReserveAToken(address(asset), address(aToken));
    }

    function test_createERC4626() public {
        AaveV2ERC4626 vault =
            AaveV2ERC4626(address(factory.createERC4626(asset)));

        assertEq(address(vault.aToken()), address(aToken), "aToken incorrect");
        assertEq(
            address(vault.lendingPool()),
            address(lendingPool),
            "lendingPool incorrect"
        );
        assertEq(
            address(vault.aaveMining()), address(aaveMining), "aaveMining incorrect"
        );
        assertEq(
            address(vault.rewardRecipient()),
            address(rewardRecipient),
            "rewardRecipient incorrect"
        );
    }

    function test_computeERC4626Address() public {
        AaveV2ERC4626 vault =
            AaveV2ERC4626(address(factory.createERC4626(asset)));

        assertEq(
            address(factory.computeERC4626Address(asset)),
            address(vault),
            "computed vault address incorrect"
        );
    }

    function test_fail_createERC4626ForAssetWithoutAToken() public {
        ERC20Mock fakeAsset = new ERC20Mock();
        vm.expectRevert(
            abi.encodeWithSignature("AaveV2ERC4626Factory__ATokenNonexistent()")
        );
        factory.createERC4626(fakeAsset);
    }
}