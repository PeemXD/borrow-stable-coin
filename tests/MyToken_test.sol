// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "../contracts/PepoStablecoin.sol";

contract PepoStablecoinTest is PepoStablecoin {

    function testTokenInitialValues() public {
        Assert.equal(name(), "Pepo Stablecoin", "token name did not match");
        Assert.equal(symbol(), "USDP", "token symbol did not match");
        Assert.equal(decimals(), 18, "token decimals did not match");
        Assert.equal(totalSupply(), 0, "token supply should be zero");
    }
}