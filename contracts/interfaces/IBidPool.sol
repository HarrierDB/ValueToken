// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

interface IBidPool {

    function bid(Offer memory offer) external returns (bool);



}
