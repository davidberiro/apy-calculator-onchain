// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../pancake/PancakeApy.sol";
import "./interfaces/IAutofarm.sol";
import "./interfaces/IAutofarmStrat.sol";

contract AutofarmApy is PancakeApy {
    using SafeMath for uint;

    address internal constant AUTO_POOL = 0x4d0228EBEB39f6d2f29bA528e2d15Fc9121Ead56;

    IBEP20 internal constant AUTO = IBEP20(0xa184088a740c695E156F91f5cC086a06bb78b827);

    IAutofarm internal constant autofarm = IAutofarm(0x0895196562C7868C5Be92459FaE7f877ED450452);

    function getAutofarmVaultApy(uint _pid) public view returns (uint) {
        (,,,,address strat) = autofarm.poolInfo(_pid);
        console.log(strat);
        // try to read pid, otherwise assume venus strategy :)
        try IAutofarmStrat(strat).pid() {
            uint farmPid = IAutofarmStrat(strat).pid();
            console.log(farmPid);
            uint underlyingApy = pancakeApy(farmPid);
            uint256 buyBackRate = IAutofarmStrat(strat).buyBackRate();
            uint256 buyBackRateMax = IAutofarmStrat(strat).buyBackRateMax();
            uint256 controllerFee = IAutofarmStrat(strat).controllerFee();
            uint256 controllerFeeMax = IAutofarmStrat(strat).controllerFeeMax();
            uint postFeeApy = underlyingApy.sub(underlyingApy.mul(controllerFee).div(controllerFeeMax));
            uint postBuybackApy = postFeeApy.sub(postFeeApy.mul(buyBackRate).div(buyBackRateMax));
            uint autofarmPoolApy = autofarmApy(_pid);
            console.log('david');
            console.log(underlyingApy);
            console.log(autofarmPoolApy);
            console.log(postBuybackApy);
            return postBuybackApy.add(autofarmPoolApy);
        } catch(bytes memory) {
            // TODO: venus
            return 1e18;
        }
    }
  
    function autofarmApy(uint pid) public view returns (uint) {
        (address token,,,, address strat) = autofarm.poolInfo(pid);
        uint poolSize = tvl(token, IBEP20(token).balanceOf(IAutofarmStrat(strat).farmContractAddress())).mul(1e18).div(bnbPriceInUSD());
        console.log(poolSize);
        console.log(autoPriceInBNB());
        console.log(autoPerYearOfPool(pid));
        return autoPriceInBNB().mul(autoPerYearOfPool(pid)).div(poolSize);
    }

    function autoPriceInBNB() view public returns(uint) {
        console.log('auto price in bnb');
        console.log(AUTO.balanceOf(AUTO_POOL));
        console.log(WBNB.balanceOf(AUTO_POOL));
        return WBNB.balanceOf(AUTO_POOL).mul(1e18).div(AUTO.balanceOf(AUTO_POOL));
    }

    function autoPerYearOfPool(uint pid) view public returns(uint) {
        console.log('auto per year of pool');
        (, uint allocPoint,,,) = autofarm.poolInfo(pid);
        console.log(allocPoint);
        console.log(autofarm.AUTOPerBlock());
        console.log(autofarm.totalAllocPoint());
        return autofarm.AUTOPerBlock().mul(blockPerYear()).mul(allocPoint).div(autofarm.totalAllocPoint());
    }
}
