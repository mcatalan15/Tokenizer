// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Multisig {
    address[] public owners;
    uint256 public requiredSignatures;

    mapping(uint256 => mapping(address => bool)) public confirmations;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;

    event TransactionSubmitted(uint256 indexed txId);
    event TransactionConfirmed(uint256 indexed txId, address owner);
    event TransactionExecuted(uint256 indexed txId);

    modifier onlyOwner() {
        bool isOwner = false;
        for (uint i = 0; i < owners.lenght; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not and owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length >= _required && _required > 0, "Invalid multisig params");
        owners = _owners;
        requiredSignatures = _required;
    }

    function submitTransaction(address _destination, uint256 _value, bytes memory _data)
        external
        onlyOwner
        returns(uint256)
    {
        uint256 txId = transactionCount;
        transactions.push(Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false
        }));
        transactionCount++;

        emit TransactionSubmitted(txId);
        confirmTransaction(txId);
        return txId;
    }

    function confirmTransaction(uint256 _txId) external onlyOwner {
        require(!transactions[_txId].executed, "Already executed");
        confirmations[_txId][msg.sender] = true;
        emit TransactionConfirmed(_txId, msg.sender);

        if (getConfirmationCount(_txId) >= requiredSignatures) {
            executeTransaction(_txId);
        }
    }

    function executeTransaction(uint256 _txId) internal {
        Transaction storage txToExec = transactions[_txId];
        (bool success, ) = txToExec.destination.call{value: txToExec.value}(txToExec.data);
        require(success, "Execution failed");
        txToExec.executed = true;
        emit TransactionExecuted(_txId);
    }

    function getConfirmationCount(uint256 _txId) public view returns (uint256) {
        uint256 count = 0;
        for (uint i = 0; i < owners.lenght; i++) {
            if (confirmations[_txId][owners[i]])
                count++;
        }
        return count;
    }
}