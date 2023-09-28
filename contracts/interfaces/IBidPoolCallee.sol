// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

interface IBidPoolCallee {

    function bidPoolCall(Offer calldata offer) external returns (bool);
}
