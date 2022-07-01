// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {IWStETH} from "./external/IWStETH.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {IStETH} from "../../src/lido/external/IStETH.sol";
import {StETHERC4626} from "../../src/lido/StETHERC4626.sol";

contract StETHERC4626Test is Test {
    ERC20 constant underlying = stETH;
    IStETH constant stETH = IStETH(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IWStETH constant wstETH =
        IWStETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);

    StETHERC4626 public vault;

    function setUp() public {
        vault = new StETHERC4626(underlying);

        vm.label(address(stETH), "stETH");
        vm.label(address(wstETH), "wstETH");
        vm.label(address(0xABCD), "Alice");
        vm.label(address(0xDCBA), "Bob");
    }

    function mintUnderlying(address to, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 wstETHAmount = wstETH.getWstETHByStETH(amount);
        deal(address(wstETH), to, wstETHAmount * 2);
        vm.prank(to);
        uint256 stETHAmount = wstETH.unwrap(wstETHAmount);
        return stETHAmount;
    }

    function testSingleDepositWithdraw(uint64 amount) public {
        if (amount < 1e9) amount = 1e9;

        uint256 aliceUnderlyingAmount = amount;

        address alice = address(0xABCD);

        aliceUnderlyingAmount = mintUnderlying(alice, aliceUnderlyingAmount);

        vm.prank(alice);
        underlying.approve(address(vault), aliceUnderlyingAmount);
        assertEq(
            underlying.allowance(alice, address(vault)), aliceUnderlyingAmount
        );

        uint256 alicePreDepositBal = underlying.balanceOf(alice);

        vm.prank(alice);
        uint256 aliceShareAmount = vault.deposit(aliceUnderlyingAmount, alice);

        assertGe(
            vault.previewWithdraw(aliceUnderlyingAmount),
            aliceShareAmount,
            "previewWithdraw"
        );
        assertEq(
            vault.previewDeposit(aliceUnderlyingAmount),
            aliceShareAmount,
            "previewDeposit"
        );
        assertEq(vault.totalSupply(), aliceShareAmount, "totalSupply");
        assertGe(vault.totalAssets(), aliceUnderlyingAmount - 2, "totalAssets");
        assertLe(
            vault.balanceOf(alice), aliceShareAmount, "vault.balanceOf(alice)"
        );
        assertLe(
            vault.convertToAssets(vault.balanceOf(alice)),
            aliceUnderlyingAmount,
            "convertToAssets"
        );
        assertLe(
            underlying.balanceOf(alice),
            alicePreDepositBal + 2 - aliceUnderlyingAmount,
            "underlying.balanceOf(alice)"
        );

        aliceUnderlyingAmount = vault.previewRedeem(vault.balanceOf(alice));
        vm.prank(alice);
        vault.withdraw(aliceUnderlyingAmount, alice, alice);

        assertLe(vault.totalAssets(), 1, "totalAssets");
        assertEq(vault.balanceOf(alice), 0, "vault.balanceOf(alice)");
        assertEq(
            vault.convertToAssets(vault.balanceOf(alice)),
            0,
            "vault.convertToAssets(vault.balanceOf(alice))"
        );
        assertGe(
            underlying.balanceOf(alice),
            alicePreDepositBal - 2,
            "underlying.balanceOf(alice)"
        );
    }

    function testSingleMintRedeem(uint64 amount) public {
        if (amount < 1e9) amount = 1e9;

        uint256 aliceShareAmount = amount;

        address alice = address(0xABCD);

        mintUnderlying(alice, vault.previewMint(aliceShareAmount) + 2);

        vm.prank(alice);
        underlying.approve(address(vault), type(uint256).max);

        uint256 alicePreDepositBal = underlying.balanceOf(alice);

        vm.prank(alice);
        uint256 aliceUnderlyingAmount = vault.mint(aliceShareAmount, alice);

        assertGe(
            vault.previewWithdraw(aliceUnderlyingAmount),
            aliceShareAmount,
            "previewWithdraw"
        );
        assertEq(
            vault.previewDeposit(aliceUnderlyingAmount),
            aliceShareAmount,
            "previewDeposit"
        );
        assertEq(vault.totalSupply(), aliceShareAmount, "totalSupply");
        assertGe(vault.totalAssets(), aliceUnderlyingAmount - 1, "totalAssets");
        assertLe(
            vault.balanceOf(alice), aliceShareAmount, "vault.balanceOf(alice)"
        );
        assertLe(
            vault.convertToAssets(vault.balanceOf(alice)),
            aliceUnderlyingAmount,
            "convertToAssets"
        );
        assertLe(
            underlying.balanceOf(alice),
            alicePreDepositBal + 1 - aliceUnderlyingAmount,
            "underlying.balanceOf(alice)"
        );

        vm.prank(alice);
        vault.redeem(aliceShareAmount, alice, alice);

        assertLe(vault.totalAssets(), 1, "totalAssets");
        assertEq(vault.balanceOf(alice), 0, "vault.balanceOf(alice)");
        assertEq(
            vault.convertToAssets(vault.balanceOf(alice)),
            0,
            "vault.convertToAssets(vault.balanceOf(alice))"
        );
        assertGe(
            underlying.balanceOf(alice),
            alicePreDepositBal - 2,
            "underlying.balanceOf(alice)"
        );
    }

    function testFailDepositWithNotEnoughApproval() public {
        mintUnderlying(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);
        assertEq(underlying.allowance(address(this), address(vault)), 0.5e18);

        vault.deposit(1e18, address(this));
    }

    function testFailWithdrawWithNotEnoughUnderlyingAmount() public {
        mintUnderlying(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(0.5e18, address(this));

        vault.withdraw(1e18, address(this), address(this));
    }

    function testFailRedeemWithNotEnoughShareAmount() public {
        mintUnderlying(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(0.5e18, address(this));

        vault.redeem(1e18, address(this), address(this));
    }

    function testFailWithdrawWithNoUnderlyingAmount() public {
        vault.withdraw(1e18, address(this), address(this));
    }

    function testFailRedeemWithNoShareAmount() public {
        vault.redeem(1e18, address(this), address(this));
    }

    function testFailDepositWithNoApproval() public {
        vault.deposit(1e18, address(this));
    }

    function testFailMintWithNoApproval() public {
        vault.mint(1e18, address(this));
    }

    function testFailDepositZero() public {
        vault.deposit(0, address(this));
    }

    function testMintZero() public {
        vault.mint(0, address(this));

        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.convertToAssets(vault.balanceOf(address(this))), 0);
        assertEq(vault.totalSupply(), 0);
        assertEq(vault.totalAssets(), 0);
    }

    function testFailRedeemZero() public {
        vault.redeem(0, address(this), address(this));
    }

    function testWithdrawZero() public {
        vault.withdraw(0, address(this), address(this));

        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.convertToAssets(vault.balanceOf(address(this))), 0);
        assertEq(vault.totalSupply(), 0);
        assertEq(vault.totalAssets(), 0);
    }

    function testVaultInteractionsForSomeoneElse() public {
        // init 2 users with a 1e18 balance
        address alice = address(0xABCD);
        address bob = address(0xDCBA);
        mintUnderlying(alice, 1e18 + 1);
        mintUnderlying(bob, 1e18 + 1);
        uint256 underlyingAmount = 1e18;
        uint256 shareAmount = vault.convertToShares(1e18);

        vm.prank(alice);
        underlying.approve(address(vault), type(uint256).max);

        vm.prank(bob);
        underlying.approve(address(vault), type(uint256).max);

        // alice deposits 1e18 for bob
        vm.prank(alice);
        vault.deposit(underlyingAmount, bob);

        assertEq(vault.balanceOf(alice), 0);
        assertEq(vault.balanceOf(bob), shareAmount);
        assertEq(underlying.balanceOf(alice), 0);

        // bob mint 1e18 for alice
        vm.prank(bob);
        vault.mint(shareAmount, alice);
        assertEq(vault.balanceOf(alice), shareAmount);
        assertEq(vault.balanceOf(bob), shareAmount);
        assertEq(underlying.balanceOf(bob), 0);

        // alice redeem 1e18 for bob
        vm.prank(alice);
        vault.redeem(shareAmount, bob, alice);

        assertEq(vault.balanceOf(alice), 0);
        assertEq(vault.balanceOf(bob), shareAmount);
        assertGe(underlying.balanceOf(bob), underlyingAmount - 2);

        // bob withdraw 1e18 for alice
        underlyingAmount = vault.convertToAssets(shareAmount);
        vm.prank(bob);
        vault.withdraw(underlyingAmount, alice, bob);

        assertEq(vault.balanceOf(alice), 0);
        assertEq(vault.balanceOf(bob), 0);
        assertGe(underlying.balanceOf(bob), underlyingAmount - 1);
    }
}