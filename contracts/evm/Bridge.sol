// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "hardhat/console.sol";

/**
 * @title Bridge
 * @dev Using ERC-7683 for cross-chain intents. For reference, please check: https://www.erc7683.org/
 * This contract is meant to be deployed on both the origin and destination chains.
 * It is used to facilitate the cross-chain swap of tokens between two chains.
 */
contract Bridge {
  struct CrossChainOrder {
    /// @dev The contract address that the order is meant to be settled by.
	  /// Fillers send this order to this contract address on the origin chain
	  address settlementContract;
	  /// @dev The address of the user who is initiating the swap,
	  /// whose input tokens will be taken and escrowed
	  address swapper;
    /// @dev Nonce to be used as replay protection for the order
	  uint256 nonce;
	  /// @dev The chainId of the origin chain
	  uint32 originChainId;
    /// @dev The timestamp by which the order must be initiated
	  uint32 initiateDeadline;
	  /// @dev The timestamp by which the order must be filled on the destination chain
	  uint32 fillDeadline;
    /// @dev Arbitrary implementation-specific data
	  /// Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
	  /// or any other order-type specific information
	  CrossChainOrderData orderData;
  }

  struct CrossChainOrderData {
    /// @dev The address of the token contract on the origin chain
    address originToken;
    /// @dev The address of the token contract on the destination chain
    address destinationToken;
    /// @dev The address of the user who will receive the tokens on the destination chain
    address receiverAddress;
    /// @dev The amount of tokens to be swapped
    uint256 amount;
    /// @dev The chainId of the destination chain
	  uint32 destinationChainId;
  }

  function bridge(CrossChainOrder memory order) external {
    
  }
}