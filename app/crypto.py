import json
import web3
from web3.middleware import geth_poa_middleware
import os
import dotenv
dotenv.load_dotenv("../.env")

CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS_POLYGON_MAIN")
NETWORK = "MAINNET"
PROVIDER_URL = os.getenv("INFURA_POLYGON_MAINNET_URI")
ADMIN_ACCOUNT_KEY = os.getenv("PRIVATE_KEY")

# load abi from abi.json
with open("abi.json") as f:
    abi = json.load(f)

# create web3 instance
web3 = web3.Web3(web3.Web3.HTTPProvider(PROVIDER_URL))
web3.middleware_onion.inject(geth_poa_middleware, layer=0)
web3.eth.defaultAccount = web3.eth.account.privateKeyToAccount(ADMIN_ACCOUNT_KEY).address

# create contract instance
contract = web3.eth.contract(address=CONTRACT_ADDRESS, abi=abi)

# create admin account
admin_account = web3.eth.account.privateKeyToAccount(ADMIN_ACCOUNT_KEY)


def make_deposit(recipient, amount):
    print(f"Contract Balance: {get_balance(CONTRACT_ADDRESS)}. Deposit Amount: {amount}")
    
    # create and sign transaction
    txn = contract.functions.deposit(recipient).buildTransaction({
        'value': amount,
        'gas': 100000,
        "nonce": web3.eth.getTransactionCount(web3.eth.defaultAccount),
    })
    signed_txn = admin_account.signTransaction(txn)

    # send transaction
    tx_hash = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
    print(f"Transaction hash: {web3.toHex(tx_receipt.transactionHash)}")
    print(f"Contract Balance: {get_balance(CONTRACT_ADDRESS)}")
    return tx_receipt, web3.toHex(tx_receipt.transactionHash)


def make_withdrawal(index, recipient):
    # makes an ether withdrawal to the recipient if the key is correct
    print(f"Contract Balance: {get_balance(CONTRACT_ADDRESS)}. Withdrawing deposit {index} to {recipient}")

    # 1. call contract withdrawOwner
    txn = contract.functions.withdrawOwner(index, recipient).buildTransaction({
        'gas': 100000,
        "nonce": web3.eth.getTransactionCount(web3.eth.defaultAccount),
    })
    signed_txn = admin_account.signTransaction(txn)

    # 2. send transaction
    tx_hash = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)    
    print(f"Transaction hash: {web3.toHex(tx_receipt.transactionHash)}")
    print(f"Contract Balance: {get_balance(CONTRACT_ADDRESS)}")
    return tx_receipt, web3.toHex(tx_receipt.transactionHash)



def get_balance(address):
    return web3.eth.getBalance(address)


## util

def check_if_address_is_valid(address):
    return web3.isAddress(address)
    

# if __name__ == "__main__":
    # send test deposit of 0.33 MATIC
    # make_deposit("test@hugomontenegro.com", web3.toWei(0.33, "ether"))

    # make withdrawal
    # make_withdrawal(0, web3.eth.defaultAccount)
