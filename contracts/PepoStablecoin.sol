// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract PepoStablecoin is ERC20, ERC20Permit, Ownable{

    constructor() ERC20("Pepo Stablecoin", "USDP") ERC20Permit("USDP") Ownable(_msgSender()) {
    }


    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }

    function burn(address account, uint256 value) public onlyOwner {
        _burn(account, value);
    }
    
    function getRatio(address borrower) public view returns (uint256) {
        if (deptCollateralRatios[borrower].collateral == 0) {
            return 0;
        }
        return (deptCollateralRatios[borrower].dept * 100) / deptCollateralRatios[borrower].collateral;
    }
}
