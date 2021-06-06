// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../common/Apy.sol";

import "./interfaces/IVToken.sol";

contract VenusApy is Apy {
    using SafeMath for uint;

    function venusApy(address vToken) view public returns(uint) {
        return compounding(venusApr(vToken), 1 days);
    }

    function venusApr(address vToken) view public returns(uint) {
        uint rate = IVToken(vToken).supplyRatePerBlock();
        uint apy = rate.mul(blockPerYear());
        console.log('venusApy');
        console.log(rate);
        console.log(apy);
        return apy;
    }
}
