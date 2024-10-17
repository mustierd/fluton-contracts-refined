pragma solidity ^0.8.27;

/**
 * @title BridgeTest
 * @notice This contract is only for testing purposes, nor represents the actual Bridge contract. Therefore, it is not advised to use it in production.
 */
contract BridgeTest {
  struct Intent {
    address sender;
    address receiver;
    address relayer;
    address inputToken;
    address outputToken;
    uint256 inputAmount;
    uint256 outputAmount;
    uint256 id;
    uint32 originChainId;
    uint32 destinationChainId;
  }

  function bridge(Intent memory intent) external {
    // This function is empty on purpose
  }
}