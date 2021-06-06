// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../common/Apy.sol";

import "./interfaces/IMasterChef.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakePair.sol";

contract PancakeApy is Apy {
    using SafeMath for uint;

    address internal constant CAKE_POOL = 0xA527a61703D82139F8a06Bc30097cC9CAA2df5A6;
    address internal constant BNB_BUSD_POOL = 0x1B96B92314C44b159149f7E0303511fB2Fc4774f;

    IBEP20 internal constant WBNB = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IBEP20 internal constant CAKE = IBEP20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    IBEP20 internal constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    IMasterChef internal constant master = IMasterChef(0x73feaa1eE314F8c655E354234017bE2193C9E24E);
    IPancakeFactory internal constant factory = IPancakeFactory(0xBCfCcbde45cE874adCB698cC183deBcF17952812);

    function pancakeApy(uint pid) view public returns(uint) {
        return compounding(pancakeApr(pid), 1 days);
    }

    function pancakeApr(uint pid) view internal returns(uint) {
        (address token,,,) = master.poolInfo(pid);
        uint poolSize = tvl(token, IBEP20(token).balanceOf(address(master))).mul(1e18).div(bnbPriceInUSD());
        return cakePriceInBNB().mul(cakePerYearOfPool(pid)).div(poolSize);
    }

    function cakePerYearOfPool(uint pid) view public returns(uint) {
        (, uint allocPoint,,) = master.poolInfo(pid);
        return master.cakePerBlock().mul(blockPerYear()).mul(allocPoint).div(master.totalAllocPoint());
    }

    function tvl(address _flip, uint amount) public view returns (uint) {
        if (_flip == address(CAKE)) {
            return cakePriceInBNB().mul(bnbPriceInUSD()).mul(amount).div(1e36);
        }
        address _token0 = IPancakePair(_flip).token0();
        address _token1 = IPancakePair(_flip).token1();
        if (_token0 == address(WBNB) || _token1 == address(WBNB)) {
            uint bnb = WBNB.balanceOf(address(_flip)).mul(amount).div(IBEP20(_flip).totalSupply());
            uint price = bnbPriceInUSD();
            return bnb.mul(price).div(1e18).mul(2);
        }

        uint balanceToken0 = IBEP20(_token0).balanceOf(_flip);
        uint price = tokenPriceInBNB(_token0);
        return balanceToken0.mul(price).div(1e18).mul(bnbPriceInUSD()).div(1e18).mul(2).mul(amount).div(IBEP20(_flip).totalSupply());
    }

    function tvlInBNB(address _flip, uint amount) public view returns (uint) {
        if (_flip == address(CAKE)) {
            return cakePriceInBNB().mul(amount).div(1e18);
        }
        address _token0 = IPancakePair(_flip).token0();
        address _token1 = IPancakePair(_flip).token1();
        if (_token0 == address(WBNB) || _token1 == address(WBNB)) {
            uint bnb = WBNB.balanceOf(address(_flip)).mul(amount).div(IBEP20(_flip).totalSupply());
            return bnb.mul(2);
        }

        uint balanceToken0 = IBEP20(_token0).balanceOf(_flip);
        uint price = tokenPriceInBNB(_token0);
        return balanceToken0.mul(price).div(1e18).mul(2).mul(amount).div(IBEP20(_flip).totalSupply());
    }

    function cakePriceInBNB() view public returns(uint) {
        return WBNB.balanceOf(CAKE_POOL).mul(1e18).div(CAKE.balanceOf(CAKE_POOL));
    }

    function bnbPriceInUSD() view public returns(uint) {
        return BUSD.balanceOf(BNB_BUSD_POOL).mul(1e18).div(WBNB.balanceOf(BNB_BUSD_POOL));
    }

    function flipPriceInBNB(address _flip) view public returns(uint) {
        return tvlInBNB(_flip, 1e18);
    }

    function flipPriceInUSD(address _flip) view public returns(uint) {
        return tvl(_flip, 1e18);
    }

    function tokenPriceInBNB(address _token) view public returns(uint) {
        address pair = factory.getPair(_token, address(WBNB));
        uint decimal = uint(IBEP20(_token).decimals());

        return WBNB.balanceOf(pair).mul(10**decimal).div(IBEP20(_token).balanceOf(pair));
    }
}

