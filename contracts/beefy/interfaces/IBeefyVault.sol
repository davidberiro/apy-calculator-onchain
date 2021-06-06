// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

// vault that controls a single token
interface IBeefyVault {
    function withdraw(uint256 _amount) external;

    function stake(uint256 _amount) external;

    function balanceOf(address account) external view returns (uint256);
}
