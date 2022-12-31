const { ethers } = require("hardhat");
const TOKENS_IN_POOL = ethers.utils.parseEther("1000000");
console.log(TOKENS_IN_POOL.toString() / 10 ** 18);
