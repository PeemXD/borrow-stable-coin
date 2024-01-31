// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyToken is ERC20, ERC20Permit{
    address _owner;

    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "unauthorized");
        _;
    }

    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }

    function burn(address account, uint256 value) public onlyOwner {
        _burn(account, value);
    }
    
}
