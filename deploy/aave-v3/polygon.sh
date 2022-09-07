# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/polygon.json
export RPC_URL=$RPC_URL_POLYGON

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
aavev3_factory_address=$(deploy AaveV3ERC4626Factory $AAVE_V3_LENDING_POOL_POLYGON $AAVE_V3_REWARDS_RECIPIENT_POLYGON $AAVE_V3_REWARDS_CONTROLLER_POLYGON)
echo "AaveV3ERC4626Factory=$aavev3_factory_address"