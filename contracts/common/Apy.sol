// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";

import "hardhat/console.sol";

contract Apy {
    using SafeMath for uint;

    function compounding(uint __apy, uint compoundUnit) public pure returns(uint) {
        uint compoundTimes = 365 days / compoundUnit;
        uint unitAPY = 1e18 + (__apy / compoundTimes);
        uint result = 1e18;

        for(uint i=0; i<compoundTimes; i++) {
            result = (result * unitAPY) / 1e18;
        }

        return result - 1e18;
    }

    function blockPerYear() pure public returns(uint) {
        // 86400 / 3 * 365
        return 10512000;
    }
}
