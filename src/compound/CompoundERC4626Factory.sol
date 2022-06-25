// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {ICERC20} from "./external/ICERC20.sol";
import {CompoundERC4626} from "./CompoundERC4626.sol";
import {IComptroller} from "./external/IComptroller.sol";
import {ERC4626Factory} from "../base/ERC4626Factory.sol";

/// @title CompoundERC4626Factory
/// @author zefram.eth
/// @notice Factory for creating CompoundERC4626 contracts
contract CompoundERC4626Factory is ERC4626Factory {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @notice Thrown when trying to deploy an CompoundERC4626 vault using an asset without a cToken
    error CompoundERC4626Factory__CTokenNonexistent();

    /// -----------------------------------------------------------------------
    /// Immutable params
    /// -----------------------------------------------------------------------

    /// @notice The Compound comptroller contract
    IComptroller public immutable comptroller;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /// @notice Maps underlying asset to the corresponding cToken
    mapping(ERC20 => ICERC20) public underlyingToCToken;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(IComptroller comptroller_, address cEtherAddress) {
        comptroller = comptroller_;

        // initialize underlyingToCToken
        ICERC20[] memory allCTokens = comptroller_.getAllMarkets();
        uint256 numCTokens = allCTokens.length;
        ICERC20 cToken;
        for (uint256 i; i < numCTokens;) {
            cToken = allCTokens[i];
            if (address(cToken) != cEtherAddress) {
                underlyingToCToken[cToken.underlying()] = cToken;
            }

            unchecked {
                ++i;
            }
        }
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
        ICERC20 cToken = underlyingToCToken[asset];
        if (address(cToken) == address(0)) {
            revert CompoundERC4626Factory__CTokenNonexistent();
        }

        vault = new CompoundERC4626{salt: bytes32(0)}(asset, cToken);

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
                        type(CompoundERC4626).creationCode,
                        // Constructor arguments:
                        abi.encode(asset, underlyingToCToken[asset])
                    )
                )
            )
        );
    }

    /// @notice Updates the underlyingToCToken mapping in order to support newly added cTokens
    /// @dev This is needed because Compound doesn't have an onchain registry of cTokens corresponding to underlying assets.
    /// @param newCTokenIndices The indices of the new cTokens to register in the comptroller.allMarkets array
    function updateUnderlyingToCToken(uint256[] memory newCTokenIndices)
        public
    {
        uint256 numCTokens = newCTokenIndices.length;
        ICERC20 cToken;
        uint256 index;
        for (uint256 i; i < numCTokens;) {
            index = newCTokenIndices[i];
            cToken = comptroller.allMarkets(index);
            underlyingToCToken[cToken.underlying()] = cToken;

            unchecked {
                ++i;
            }
        }
    }
}