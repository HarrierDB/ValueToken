// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/structs.sol";

library Utils {
    function getMaxOffer(Offer[] memory offerGroup) pure internal returns (Offer memory) {
        require(offerGroup.length > 0, "Array must not be empty");

        Offer memory maxOffer = offerGroup[0];
        for (uint256 i = 1; i < offerGroup.length; i++) {
            if (offerGroup[i].bidAmount > maxOffer.bidAmount) {
                maxOffer = offerGroup[i];
            }
        }
        return maxOffer;
    }
}

