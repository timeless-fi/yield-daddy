// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {CREATE3Factory} from "create3-factory/src/CREATE3Factory.sol";

import {AaveV3ERC4626Factory} from "../../src/aave-v3/AaveV3ERC4626Factory.sol";

contract DeployScript is Script {
    function run() public returns (AaveV3ERC4626Factory deployed) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        CREATE3Factory create3 = CREATE3Factory(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);
        address rewardsController = vm.envAddress("AAVE_V3_REWARDS_CONTROLLER_MAINNET_LIDO");
        address rewardRecipient = vm.envAddress("AAVE_V3_REWARDS_RECIPIENT_MAINNET_LIDO");
        address lendingPool = vm.envAddress("AAVE_V3_LENDING_POOL_MAINNET_LIDO");

        vm.startBroadcast(deployerPrivateKey);

        deployed = AaveV3ERC4626Factory(
            create3.deploy(
                keccak256("AaveV3ERC4626Factory-Lido"),
                bytes.concat(
                    type(AaveV3ERC4626Factory).creationCode, abi.encode(lendingPool, rewardRecipient, rewardsController)
                )
            )
        );

        vm.stopBroadcast();
    }
}
