// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./vameon.sol";

contract TestVameon {
    Vameon public vameonToken;

    constructor(address _vameonToken) {
        vameonToken = Vameon(_vameonToken);
    }

    // Fungsi untuk menguji transferWithFee
    function testTransferWithFee(address to, uint256 value, uint256 fee) external {
        vameonToken.transferWithFee(to, value, fee);
    }

    // Fungsi untuk memeriksa saldo
    function getBalance(address account) external view returns (uint256) {
        return vameonToken.balanceOf(account);
    }
}
