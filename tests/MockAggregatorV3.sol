// SPDX-License-Identifier: MIT
// MockAggregatorV3.sol
// This is a simple mock for testing purposes
// In a real environment, you might implement a more sophisticated mock
// or use Hardhat Network features to simulate price feeds.

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

contract MockAggregatorV3 is AggregatorV3Interface {
    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        // Return sample data for testing
        return (0, 2234, block.timestamp, 0, 0);
    }
}