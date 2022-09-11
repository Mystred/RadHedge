#!/usr/bin/env bash

# set -x
set -e

# Getting the directory of this bash script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "Operating out of: $SCRIPT_DIR"

resim reset

OP1=$(resim new-account)
export PRIV_KEY1=$(echo "$OP1" | sed -nr "s/Private key: ([[:alnum:]_]+)/\1/p")
export PUB_KEY1=$(echo "$OP1" | sed -nr "s/Public key: ([[:alnum:]_]+)/\1/p")
export ACC_ADDRESS1=$(echo "$OP1" | sed -nr "s/Account component address: ([[:alnum:]_]+)/\1/p")
echo acc_address1 $ACC_ADDRESS1


OP2=$(resim new-account)
export PRIV_KEY2=$(echo "$OP2" | sed -nr "s/Private key: ([[:alnum:]_]+)/\1/p")
export PUB_KEY2=$(echo "$OP2" | sed -nr "s/Public key: ([[:alnum:]_]+)/\1/p")
export ACC_ADDRESS2=$(echo "$OP2" | sed -nr "s/Account component address: ([[:alnum:]_]+)/\1/p")
echo acc_address2 $ACC_ADDRESS2

OP2=$(resim new-account)
export PRIV_KEY2=$(echo "$OP2" | sed -nr "s/Private key: ([[:alnum:]_]+)/\1/p")
export PUB_KEY2=$(echo "$OP2" | sed -nr "s/Public key: ([[:alnum:]_]+)/\1/p")
export ACC_ADDRESS2=$(echo "$OP2" | sed -nr "s/Account component address: ([[:alnum:]_]+)/\1/p")
echo acc_address3 $ACC_ADDRESS3

resim set-default-account $ACC_ADDRESS1 $PRIV_KEY1



PK_OP=$(resim publish ".")
export PACKAGE=$(echo "$PK_OP" | sed -nr "s/Success! New Package: ([[:alnum:]_]+)/\1/p")
echo package_address $PACKAGE
echo
echo

# export REPLACEMENT_LOOKUP=" s/<<<account1_address>>>/$ACC_ADDRESS1/g; \
#    s/<<<package_address>>>/$PACKAGE/g; \
#"
#sed "$REPLACEMENT_LOOKUP" test_transactions/create_component.rtm > test_transactions/create_component.rtm

# Update the package address in the transaction manifest.
# Create the test environment

# Update the package address in the transaction manifest.
# Create the test environment
# TestEnvLog=$(resim run test_transactions/create_test_environment.rtm)
resim run test_transactions/create_test_environment.rtm

# This sould be done automatically. Unfortunately I didn't have the time until challenge deadline.
#export ORACLE=02ba6c6d3d7e09ee1c3f50683103c47a97b090b3bcbe9868264db1
# export ORACLE=$(echo "$TestEnvLog" | sed -nr "s/price oracle address: ([[:alnum:]_]+)/\1/p")
# export RADEX=$(echo "$TestEnvLog" | sed -nr "s/RaDEX address: ([[:alnum:]_]+)/\1/p")

# export BASE_CURRENCY=$(echo "$TestEnvLog" | sed -nr "s/USDT address: ([[:alnum:]_]+)/\1/p")
# export BTC=$(echo "$TestEnvLog" | sed -nr "s/BTC address: ([[:alnum:]_]+)/\1/p")
# export ETH=$(echo "$TestEnvLog" | sed -nr "s/ETH address: ([[:alnum:]_]+)/\1/p")
# export BNB=$(echo "$TestEnvLog" | sed -nr "s/BNB address: ([[:alnum:]_]+)/\1/p")
# export ADA=$(echo "$TestEnvLog" | sed -nr "s/ADA address: ([[:alnum:]_]+)/\1/p")


# echo ORacle address: $ORACLE
# echo Radex address: $RADEX

# This sould be done automatically. Unfortunately I didn't have the time until challenge deadline.
export TEST_ENV=02ef7e843bedb3f9b0557edf8aaa1662387917e110b99e9ae0b2d4
export ORACLE=02ae33978ffd35c7567703eb1ca20c1b1e03d82e59bc969eea76a1
export RADEX=02c62ede6aba5759245eed1cef9411115a48905cc2c634846679bc

export USDT=032c8f6c62bab3d633a56318195b9fb1ed90835908a9066c5be4fb
export BTC=03ac64cd197a1bbbac92dff6e64a2a93eb00a2e32102acb9282bd1
export ETH=03a7386408ff26449dd5a466c009a9e7c2f5e908d5ac2f73e3c911
export BNB=030f5d2fba0e0d6b1bd93918371b18c6dc34373482a6214b667205
export ADA=03ea8323e21a9de6102144999317ca84ca122474c438eee32e06a9

# Switch to account 2: the pool manager. Due to shortness of time till deadline everything will be done from one account (all resources are there for now)
# Of course that doesn't make any sense in reality.
# resim set-default-account $ACC_ADDRESS2 $PRIV_KEY2

# Create an investment_pool
resim run test_transactions/create_investment_pool.rtm
echo
echo

export POOL=0213373ce80d1923211efae57acd3d88693c938325474935153ec9
export ADMIN_BADGE=03a3c429bd0d89b8f23fc59ad9ce1da7dd6980b714e35f0a01ae3b

# Fund the investment_pool with eth and btc. Still in the role of the pool manager.
echo Calling "test_transactions/fund_pool.rtm"
resim run test_transactions/fund_pool.rtm
echo
echo


# Switch to account 3: the investor. Due to shortness of time till deadline everything will be done from one account (all resources are there for now)
# Of course that doesn't make any sense in reality.
# resim set-default-account $ACC_ADDRESS3 $PRIV_KEY3
	
# Invest 10000 USDT in the investment_pool.
echo Calling "test_transactions/invest_in_pool.rtm"
resim run test_transactions/invest_in_pool.rtm
echo
echo

# Switch to fund manager and change investments
# Switch to account 2: the pool manager. Due to shortness of time till deadline everything will be done from one account (all resources are there for now)
# Of course that doesn't make any sense in reality.
# resim set-default-account $ACC_ADDRESS2 $PRIV_KEY2
echo Read out a list of present assets in the pool and their respective amounts.
resim run test_transactions/get_pool_asset_list.rtm
echo
echo

echo Swap 20 ETH for BTC
resim run test_transactions/reallocate_investments.rtm
resim run test_transactions/get_pool_asset_list.rtm
echo
echo

# Change asset prices of test enviroment
echo Change of asset prices in test environment: BTC increases 20%, ETH increased 10%
resim run test_transactions/test_env_change_oracle_price.rtm
echo
echo

# Collect transaction fees
echo Collect transaction fees.
resim run test_transactions/collect_transaction_fees.rtm
echo
echo This little show case ends here. 