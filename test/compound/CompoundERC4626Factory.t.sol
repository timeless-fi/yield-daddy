// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {ICERC20} from "../../src/compound/external/ICERC20.sol";
import {CompoundERC4626} from "../../src/compound/CompoundERC4626.sol";
import {IComptroller} from "../../src/compound/external/IComptroller.sol";
import {CompoundERC4626Factory} from "../../src/compound/CompoundERC4626Factory.sol";

contract CompoundERC4626FactoryTest is Test {
    address constant rewardRecipient = address(0x01);

    IComptroller constant comptroller =
        IComptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    ERC20 constant dai = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant cDaiAddress = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address constant cEtherAddress = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    CompoundERC4626Factory public factory;

    function setUp() public {
        factory =
            new CompoundERC4626Factory(comptroller, cEtherAddress, rewardRecipient);
    }

    function test_createERC4626() public {
        CompoundERC4626 vault =
            CompoundERC4626(address(factory.createERC4626(dai)));

        assertEq(
            address(vault.comp()),
            address(comptroller.getCompAddress()),
            "comp incorrect"
        );
        assertEq(address(vault.cToken()), cDaiAddress, "cToken incorrect");
        assertEq(
            address(vault.rewardRecipient()),
            rewardRecipient,
            "rewardRecipient incorrect"
        );
        assertEq(
            address(vault.comptroller()),
            address(comptroller),
            "comptroller incorrect"
        );
    }

    function test_computeERC4626Address() public {
        CompoundERC4626 vault =
            CompoundERC4626(address(factory.createERC4626(dai)));

        assertEq(
            address(factory.computeERC4626Address(dai)),
            address(vault),
            "computed vault address incorrect"
        );
    }

    function test_fail_createERC4626ForAssetWithoutEToken() public {
        ERC20Mock fakeAsset = new ERC20Mock();
        vm.expectRevert(
            abi.encodeWithSignature("CompoundERC4626Factory__CTokenNonexistent()")
        );
        factory.createERC4626(fakeAsset);
    }
}