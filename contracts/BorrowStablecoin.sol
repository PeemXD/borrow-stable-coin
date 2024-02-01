// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BorrowStablecoin {
    struct deptCollateralRatio {
        uint dept;
        uint collateral;
    }

    mapping(address => deptCollateralRatio) deptCollateralRatios;

}