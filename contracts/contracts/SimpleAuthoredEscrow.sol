// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//////////////////////////////////////////////////////////////////////////////////////
// @title   Peanut Protocol, Authored Escrow Contract (simplified)
// @version 1.0
// @author  H & K
// @dev     This contract is used to send link payments.
// @dev     more at: https://sendpeanuts.com
//////////////////////////////////////////////////////////////////////////////////////
//⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//                         ⠀⠀⢀⣀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣶⣦⣌⠙⠋⢡⣴⣶⡄⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⣿⣿⣿⡿⢋⣠⣶⣶⡌⠻⣿⠟⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡆⠸⠟⢁⣴⣿⣿⣿⣿⣿⡦⠉⣴⡇⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠟⠀⠰⣿⣿⣿⣿⣿⣿⠟⣠⡄⠹⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢸⡿⢋⣤⣿⣄⠙⣿⣿⡿⠟⣡⣾⣿⣿⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣾⠿⠀⢠⣾⣿⣿⣿⣦⠈⠉⢠⣾⣿⣿⣿⠏⠀⠀⠀
// ⠀⠀⠀⠀⣀⣤⣦⣄⠙⠋⣠⣴⣿⣿⣿⣿⠿⠛⢁⣴⣦⡄⠙⠛⠋⠁⠀⠀⠀⠀
// ⠀⠀⢀⣾⣿⣿⠟⢁⣴⣦⡈⠻⣿⣿⡿⠁⡀⠚⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠘⣿⠟⢁⣴⣿⣿⣿⣿⣦⡈⠛⢁⣼⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⢰⡦⠀⢴⣿⣿⣿⣿⣿⣿⣿⠟⢀⠘⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠘⢀⣶⡀⠻⣿⣿⣿⣿⡿⠋⣠⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⢿⣿⣿⣦⡈⠻⣿⠟⢁⣼⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠈⠻⣿⣿⣿⠖⢀⠐⠿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀⠀⠀
//
//////////////////////////////////////////////////////////////////////////////////////

// imports
import "@openzeppelin/contracts/access/Ownable.sol";

contract AuthoredEscrow is Ownable {
    // escrow contract, sends ether to a beneficiary address.
    // beta version of the decentralized escrow contract.
    // This is still centralized (relies on Oracle).
    // Fully decentralized, zk based contract is in the horizon (<4 weeks)
    // erc-20 and erc-721 support is in the horizon (<4 weeks)

    struct transaction {
        address sender;
        uint256 amount; // amount to send
    }
    transaction[] public transactions; // array of transactions

    // events
    event Deposit(address indexed sender, uint256 amount, uint256 index);
    event Withdraw(address indexed recipient, uint256 amount);

    // constructor
    constructor() {}

    // deposit ether to escrow & get a deposit id
    function deposit() external payable returns (uint256) {
        require(msg.value > 0, "deposit must be greater than 0");

        // store new transaction
        transaction memory newTransaction;
        newTransaction.amount = msg.value;
        newTransaction.sender = msg.sender;
        transactions.push(newTransaction);
        emit Deposit(msg.sender, msg.value, transactions.length - 1);
        // return id of new transaction
        return transactions.length - 1;
    }

    // sender can always withdraw deposited assets at any time
    function withdrawSender(uint256 _index) external {
        require(_index < transactions.length, "index out of bounds");
        require(
            transactions[_index].sender == msg.sender,
            "only sender can withdraw"
        );

        // transfer ether back to sender
        payable(msg.sender).transfer(transactions[_index].amount);
        emit Withdraw(transactions[_index].sender, transactions[_index].amount);

        // remove transaction from array
        delete transactions[_index];
    }

    // centralized transfer function to transfer ether to recipients newly created wallet
    // TODO: replace with zk-SNARK based function
    function withdrawOwner(uint256 _index, address _recipient)
        external
        onlyOwner
    {
        require(_index < transactions.length, "index out of bounds");

        // transfer ether to recipient
        payable(_recipient).transfer(transactions[_index].amount);
        emit Withdraw(_recipient, transactions[_index].amount);

        // remove transaction from array
        delete transactions[_index];
    }

    //// Some utility functions ////

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _index)
        external
        view
        returns (transaction memory)
    {
        return transactions[_index];
    }

    function getTransactionCountSent(address _sender)
        external
        view
        returns (uint256)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].sender == _sender) {
                count++;
            }
        }
        return count;
    }

    // and that's all!
}
