// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

// vault that controls a single token
interface IBunnyVault {
    function pid() external view returns (uint);

    function vToken() external view returns (address);
}
