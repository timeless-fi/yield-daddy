# load environment variables from .env
source .env

# set env variables
export ADDRESSES_FILE=./deployments/mainnet.json
export RPC_URL=$RPC_URL_MAINNET

# load common utilities
. $(dirname $0)/../common.sh

# deploy contracts
compound_factory_address=$(deploy CompoundERC4626Factory $COMPOUND_COMPTROLLER_MAINNET $COMPOUND_CETHER_MAINNET $COMPOUND_REWARDS_RECIPIENT_MAINNET)
echo "CompoundERC4626Factory=$compound_factory_address"