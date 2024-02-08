# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/sepolia.json
export RPC_URL=$RPC_URL_SEPOLIA

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
aavev3_factory_address=$(deploy AaveV3ERC4626Factory $AAVE_V3_LENDING_POOL_SEPOLIA $AAVE_V3_REWARDS_RECIPIENT_SEPOLIA $AAVE_V3_REWARDS_CONTROLLER_SEPOLIA)
echo "AaveV3ERC4626Factory=$aavev3_factory_address"