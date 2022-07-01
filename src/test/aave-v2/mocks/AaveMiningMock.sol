// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

// interfaces
import {ERC20Mock} from "../../mocks/ERC20Mock.sol";
import {IAaveMining} from "../../../aave-v2/external/IAaveMining.sol";

contract AaveMiningMock is IAaveMining {
    uint256 public constant CLAIM_AMOUNT = 10 ** 18;
    ERC20Mock public aave;

    constructor(address _aave) {
        aave = ERC20Mock(_aave);
    }

    function claimRewards(
        address[] calldata, /*assets*/
        uint256, /*amount*/
        address to
    )
        external
        override
        returns (uint256)
    {
        aave.mint(to, CLAIM_AMOUNT);
        return CLAIM_AMOUNT;
    }
}