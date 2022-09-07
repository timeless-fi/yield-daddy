# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/optimism.json
export RPC_URL=$RPC_URL_OPTIMISM

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
aavev3_factory_address=$(deployViaCast AaveV3ERC4626Factory 'constructor(address,address,address)' $AAVE_V3_LENDING_POOL_OPTIMISM $AAVE_V3_REWARDS_RECIPIENT_OPTIMISM $AAVE_V3_REWARDS_CONTROLLER_OPTIMISM)
echo "AaveV3ERC4626Factory=$aavev3_factory_address"