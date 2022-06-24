# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/mainnet.json
export RPC_URL=$RPC_URL_MAINNET

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
aavev2_factory_address=$(deploy AaveV2ERC4626Factory $AAVE_V2_MINING_MAINNET $AAVE_V2_REWARDS_RECIPIENT_MAINNET $AAVE_V2_LENDING_POOL_MAINNET)
echo "AaveV2ERC4626Factory=$aavev2_factory_address"