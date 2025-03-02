// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

struct BridgeParams {
    address sender;
    address receiver;
    address relayer;
    address inputToken;
    address outputToken;
    uint256 inputAmount;
    uint256 outputAmount;
    uint32 destinationChainId;
    uint8 v;
    bytes32 r;
    bytes32 s;
}
