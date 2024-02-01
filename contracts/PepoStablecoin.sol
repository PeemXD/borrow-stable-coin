// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "tests/MockAggregatorV3.sol";

contract PepoStablecoin is ERC20, ERC20Permit, Ownable{
    struct deptCollateralRatio {
        uint dept;
        uint collateral;
    }
    mapping(address => deptCollateralRatio) deptCollateralRatios;
    AggregatorV3Interface internal ethPriceFeed;

    event Borrow(address indexed owner, uint amount, bool isUSDP);
    event Liquidate(address indexed owner, uint amount, bool isETH);
    event LogMsgValue(uint value);


    constructor() ERC20("Pepo Stablecoin", "USDP") ERC20Permit("USDP") Ownable(_msgSender()) {
        // Use MockAggregatorV3 for local development
        ethPriceFeed = AggregatorV3Interface(address(new MockAggregatorV3()));

        // Use Real in ETH chain
        // ethPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function getEthPrice() public view returns (uint) {
        (, int price, , ,) = ethPriceFeed.latestRoundData();
        return uint(price);
    }

    function borrow(uint ratio) public payable {
        emit LogMsgValue(msg.value);
        // require(msg.value == 1000000000000000000, "eth collateral must greater than 0");
        require(ratio <= 75, "Ratio must less than equal 75%");

        uint collateral =  getEthPrice() * msg.value/10**18;
        uint dept = collateral * ratio / 100;
        deptCollateralRatios[msg.sender] = deptCollateralRatio(
            dept,
            collateral
        );

        _mint(_msgSender(), dept);

        emit Borrow(_msgSender(), dept, true);
    }

    function liquidate(address addr) public onlyOwner {
        require(deptCollateralRatios[addr].dept / (getEthPrice() * deptCollateralRatios[addr].collateral) * 100 >= 85, "currently dept to correteral ratio less than 85%");

        // TODO: sell ETH
        // ...
        
        uint liquidateEthAmount = deptCollateralRatios[addr].collateral;
        deptCollateralRatios[addr] = deptCollateralRatio(0, 0);

        emit Borrow(addr, liquidateEthAmount, true);
    }
    
}
