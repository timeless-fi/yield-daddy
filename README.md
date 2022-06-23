# Yield daddy

Gas-optimized ERC4626 wrappers for common yield-generating protocols (e.g. Aave, Compound).

## Architecture

-   [`base/`](src/base/): Base contracts shared by different wrappers
    -   [`ERC4626Factory.sol`](src/base/ERC4626Factory.sol): Abstract base contract for deploying ERC4626 wrappers
-   [`aave-v2/`](src/aave-v2/): Aave v2 wrapper
    -   [`AaveV2ERC4626.sol`](src/aave-v2/AaveV2ERC4626.sol): ERC4626 wrapper for Aave V2
    -   [`AaveV2ERC4626Factory.sol`](src/aave-v2/AaveV2ERC4626Factory.sol): Factory for creating AaveV2ERC4626 contracts

## Installation

To install with [DappTools](https://github.com/dapphub/dapptools):

```
dapp install timeless-fi/yield-daddy
```

To install with [Foundry](https://github.com/foundry-rs/foundry):

```
forge install timeless-fi/yield-daddy
```

## Local development

This project uses [Foundry](https://github.com/foundry-rs/foundry) as the development framework.

### Dependencies

```
make install
```

### Compilation

```
make build
```

### Testing

```
make test
```
