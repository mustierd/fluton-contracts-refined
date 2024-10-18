pragma solidity ^0.8.27;

import './BridgeTestInterface.sol';

/**
 * @title BridgeTest
 * @notice This contract is only for testing purposes, nor represents the actual Bridge contract. Therefore, it is not advised to use it in production.
 */
contract BridgeTest is BridgeTestInterface {
  function bridge(Intent memory intent) external {
    // This function is empty on purpose
  }

  function fulfill(Intent calldata intent) external {
    // This function is empty on purpose
  }

  function _repay(Intent calldata intent) internal {
    // This function is empty on purpose
  }
}