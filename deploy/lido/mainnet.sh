# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/mainnet.json
export RPC_URL=$RPC_URL_MAINNET

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
vault_address=$(deploy StETHERC4626 $STETH_MAINNET)
echo "StETHERC4626=$vault_address"