// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {EulerMock} from "./mocks/EulerMock.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {EulerERC4626} from "../../src/euler/EulerERC4626.sol";
import {EulerETokenMock} from "./mocks/EulerETokenMock.sol";
import {EulerMarketsMock} from "./mocks/EulerMarketsMock.sol";
import {EulerERC4626Factory} from "../../src/euler/EulerERC4626Factory.sol";

contract EulerERC4626FactoryTest is Test {
    EulerMock public euler;
    ERC20Mock public underlying;
    EulerETokenMock public eToken;
    EulerMarketsMock public markets;
    EulerERC4626Factory public factory;

    function setUp() public {
        euler = new EulerMock();
        underlying = new ERC20Mock();
        eToken = new EulerETokenMock(underlying, euler);
        markets = new EulerMarketsMock();
        factory = new EulerERC4626Factory(address(euler), markets);

        markets.setETokenForUnderlying(address(underlying), address(eToken));
    }

    function test_createERC4626() public {
        EulerERC4626 vault =
            EulerERC4626(address(factory.createERC4626(underlying)));

        assertEq(address(vault.eToken()), address(eToken), "eToken incorrect");
        assertEq(address(vault.euler()), address(euler), "euler incorrect");
    }

    function test_computeERC4626Address() public {
        EulerERC4626 vault =
            EulerERC4626(address(factory.createERC4626(underlying)));

        assertEq(
            address(factory.computeERC4626Address(underlying)),
            address(vault),
            "computed vault address incorrect"
        );
    }

    function test_fail_createERC4626ForAssetWithoutEToken() public {
        ERC20Mock fakeAsset = new ERC20Mock();
        vm.expectRevert(
            abi.encodeWithSignature("EulerERC4626Factory__ETokenNonexistent()")
        );
        factory.createERC4626(fakeAsset);
    }
}