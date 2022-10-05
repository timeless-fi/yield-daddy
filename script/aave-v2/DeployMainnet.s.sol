// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {CREATE3Factory} from "create3-factory/CREATE3Factory.sol";

import {AaveV2ERC4626Factory} from "../../src/aave-v2/AaveV2ERC4626Factory.sol";

contract DeployScript is Script {
    function run() public returns (AaveV2ERC4626Factory deployed) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        CREATE3Factory create3 = CREATE3Factory(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);
        address aaveMining = vm.envAddress("AAVE_V2_MINING_MAINNET");
        address rewardRecipient = vm.envAddress("AAVE_V2_REWARDS_RECIPIENT_MAINNET");
        address lendingPool = vm.envAddress("AAVE_V2_LENDING_POOL_MAINNET");

        vm.startBroadcast(deployerPrivateKey);

        deployed = AaveV2ERC4626Factory(
            create3.deploy(
                keccak256("AaveV2ERC4626Factory"),
                bytes.concat(
                    type(AaveV2ERC4626Factory).creationCode, abi.encode(aaveMining, rewardRecipient, lendingPool)
                )
            )
        );

        vm.stopBroadcast();
    }
}
