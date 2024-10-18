pragma solidity ^0.8.27;

import "@uniswap/universal-router/contracts/interfaces/external/IWETH9.sol";

import "./BridgeTestMessenger.sol";
import "./BridgeTestInterface.sol";
import "./union/apps/Base.sol";
import "./union/core/25-handler/IBCHandler.sol";

/**
 * @title BridgeTest
 * @notice This contract is only for testing purposes and does not represent the actual Bridge contract. Therefore, it is not advised to use it in production.
 */
contract BridgeTest is BridgeTestInterface, BridgeTestMessenger {
    IWETH9 public immutable WETH;

    constructor(
        IWETH9 _wrappedNativeToken,
        IBCHandler _ibcHandler,
        uint64 _timeout
    ) BridgeTestMessenger(_ibcHandler, _timeout) {
        WETH = _wrappedNativeToken;
    }

    function bridge(Intent calldata intent) external payable {
        if (intent.inputToken == address(WETH) && msg.value > 0) {
            if (msg.value != intent.inputAmount) {
                revert MsgValueDoesNotMatchInputAmount();
            }
            // if the input token is WETH, deposit the amount to the contract
            WETH.deposit{value: msg.value}();
        } else {
            // if the input token is not WETH, transfer the amount from the sender to the contract (lock)
            IERC20(intent.inputToken).transferFrom(
                msg.sender,
                address(this),
                intent.inputAmount
            );
        }

        emit IntentCreated(intent);
    }

    function fulfill(Intent calldata intent) external payable {
        if (intent.outputToken == address(WETH) && msg.value > 0) {
            // if the output token is WETH, transfer the amount from the contract to the receiver
            payable(address(this)).transfer(intent.outputAmount);
            // transfer the amount to the receiver
            payable(intent.receiver).transfer(intent.outputAmount);
        } else {
            // if the input token is not WETH, transfer the amount from the contract to the receiver
            IERC20(intent.outputToken).transfer(
                intent.receiver,
                intent.outputAmount
            );
        }

        emit IntentFulfilled(intent);

        // send cross chain message to settle the intent
        uint64 counterpartyTimeout = uint64(block.timestamp * 1e9) + timeout;
        IntentPacket memory packet = IntentPacket({
            intent: intent,
            counterpartyTimeout: counterpartyTimeout
        });

        initiate(packet, counterpartyTimeout);
    }

    function onRecvPacket(
        IBCPacket calldata packet,
        address,
        bytes calldata
    ) external virtual override onlyIBC returns (bytes memory acknowledgement) {
        IntentPacket memory pp = BridgeMessengerLib.decode(packet.data);

        _repay(pp.intent);
        emit IntentRepaid(pp.intent);

        // Return protocol specific successful acknowledgement
        return abi.encodePacked(BridgeMessengerLib.ACK_SUCCESS);
    }

    function _repay(Intent memory intent) internal {
        // This function is empty on purpose
    }

    receive() external payable {}
}
