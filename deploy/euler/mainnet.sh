# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/mainnet.json
export RPC_URL=$RPC_URL_MAINNET

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
euler_factory_address=$(deploy EulerERC4626Factory $EULER_MAINNET $EULER_MARKETS_MAINNET)
echo "EulerERC4626Factory=$euler_factory_address"