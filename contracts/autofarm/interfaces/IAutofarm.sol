// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IAutofarm {
    function poolInfo(uint _pid) external view returns (address, uint256, uint256, uint256, address);

    function poolLength() external view returns (uint256);

    function AUTOPerBlock() external view returns (uint256); // AUTO tokens created per block 

    function totalAllocPoint() external view returns (uint256); // Total allocation points. Must be the sum of all allocation points in all pools.
}
