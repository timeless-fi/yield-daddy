// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {CREATE3Factory} from "create3-factory/CREATE3Factory.sol";

import {IComptroller} from "../../src/compound/external/IComptroller.sol";
import {CompoundERC4626Factory} from "../../src/compound/CompoundERC4626Factory.sol";

contract DeployScript is Script {
    function run() public returns (CompoundERC4626Factory deployed) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        CREATE3Factory create3 = CREATE3Factory(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);
        IComptroller comptroller = IComptroller(vm.envAddress("COMPOUND_COMPTROLLER_MAINNET"));
        address cEther = vm.envAddress("COMPOUND_CETHER_MAINNET");
        address rewardRecipient = vm.envAddress("COMPOUND_REWARDS_RECIPIENT_MAINNET");

        vm.startBroadcast(deployerPrivateKey);

        deployed = CompoundERC4626Factory(
            create3.deploy(
                keccak256("CompoundERC4626Factory"),
                bytes.concat(
                    type(CompoundERC4626Factory).creationCode, abi.encode(comptroller, cEther, rewardRecipient)
                )
            )
        );

        vm.stopBroadcast();
    }
}
