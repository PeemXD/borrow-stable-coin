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
    event PayBack(address indexed owner, uint deptAmount, bool isUSDP);
    event ReturnCollateralAssets(address indexed owner, uint value, bool isETH);
    event Liquidate(address indexed owner, uint amount, bool isETH);



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
        require(ratio <= 75, "ratio must less than equal 75%");

        uint collateral =  msg.value;
        uint dept = collateral / 10**18 * getEthPrice() * ratio / 100;
        deptCollateralRatios[msg.sender] = deptCollateralRatio(
            dept,
            collateral
        );

        _mint(_msgSender(), dept);

        emit Borrow(_msgSender(), dept, true);
    }

    function payBack(uint256 payBackAmount) public onlyOwner {
        require(payBackAmount <= deptCollateralRatios[_msgSender()].dept, "the payBack amount must less than equal your dept");

        _burn(_msgSender(), payBackAmount);
        deptCollateralRatios[_msgSender()].dept = deptCollateralRatios[_msgSender()].dept - payBackAmount;

        emit PayBack(_msgSender(), payBackAmount, true);

        if (deptCollateralRatios[_msgSender()].dept == 0) {
            uint collateralAsset = deptCollateralRatios[_msgSender()].collateral;
            payable(_msgSender()).transfer(collateralAsset);
            deptCollateralRatios[_msgSender()].collateral = 0;
            
            emit ReturnCollateralAssets(_msgSender(), collateralAsset, true);
        }        
    }

    function liquidate(address addr) public onlyOwner {
        require((deptCollateralRatios[addr].dept * 100) / (deptCollateralRatios[addr].collateral * getEthPrice())  >= 85, "currently dept to correteral ratio less than 85%");

        // TODO: sell ETH
        // ...
        
        uint liquidateEthAmount = deptCollateralRatios[addr].collateral;
        deptCollateralRatios[addr] = deptCollateralRatio(0, 0);

        emit Borrow(addr, liquidateEthAmount, true);
    }

    function getDept(address addr) public view returns (uint ratio) {
        return deptCollateralRatios[addr].dept;
    }

    function getCollateral(address addr) public view returns (uint ratio) {
        return deptCollateralRatios[addr].collateral / 10**18 * getEthPrice();
    }

    function getRatio(address addr) public view returns (uint ratio) {
        return (deptCollateralRatios[addr].dept * 100) / (deptCollateralRatios[addr].collateral / 10**18 * getEthPrice());
    }
    
}
