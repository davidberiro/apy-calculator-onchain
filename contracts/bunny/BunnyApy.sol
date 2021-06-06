// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../pancake/PancakeApy.sol";
import "../venus/VenusApy.sol";
import "./interfaces/IBunnyMinter.sol";
import "./interfaces/IBunnyVault.sol";

contract BunnyApy is PancakeApy, VenusApy {
    using SafeMath for uint;

    IBEP20 internal constant BUNNY = IBEP20(0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51);

    IBunnyMinter internal constant bunnyMinter = IBunnyMinter(0x8cB88701790F650F273c8BB2Cc4c5f439cd65219);

    function getBunnyApy(address _vaultAddress) public view returns (uint) {
        uint pid = IBunnyVault(_vaultAddress).pid();
        // if pid == 9999, venus vault. calculation is different
        uint underlyingApy;
        if (pid == 9999) {
            address vTokenAddress = IBunnyVault(_vaultAddress).vToken();
            underlyingApy = venusApy(vTokenAddress);
        } else {
            underlyingApy = pancakeApy(pid);
        }
        uint performanceFee = bunnyMinter.performanceFee(underlyingApy);
        uint bunnyMinted = bunnyMinter.amountBunnyToMint(performanceFee);
        uint postApy = underlyingApy.sub(performanceFee).add(tokenPriceInBNB(address(BUNNY)).mul(bunnyMinted).div(1e18));
        console.log('get bunny vault apy');
        console.log(underlyingApy);
        console.log(performanceFee);
        console.log(bunnyMinted);
        console.log(postApy);
        return postApy;
    }
}