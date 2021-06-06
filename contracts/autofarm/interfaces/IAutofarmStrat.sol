// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IAutofarmStrat {
    function buyBackRate() external view returns (uint256);
    function buyBackRateMax() external view returns (uint256);
    function controllerFee() external view returns (uint256);
    function controllerFeeMax() external view returns (uint256);
    function pid() external view returns (uint256);
    function farmContractAddress() external view returns (address);
}
