pragma solidity ^0.8.27;

import {Intent} from "./BridgeTestInterface.sol";
import "./union/apps/Base.sol";
import "./union/core/25-handler/IBCHandler.sol";

struct IntentPacket {
    Intent intent;
    uint64 counterpartyTimeout;
}

library BridgeMessengerLib {
    bytes1 public constant ACK_SUCCESS = 0x01;

    error ErrOnlyOneChannel();
    error ErrInvalidAck();
    error ErrNoChannel();
    error ErrInfinitePacket();

    event TimedOut();
    event Acknowledged();

    function encode(
        IntentPacket memory packet
    ) internal pure returns (bytes memory) {
        return abi.encode(packet.intent, packet.counterpartyTimeout);
    }

    function decode(
        bytes memory packet
    ) internal pure returns (IntentPacket memory) {
        (Intent memory intent, uint64 counterpartyTimeout) = abi.decode(
            packet,
            (Intent, uint64)
        );
        return
            IntentPacket({
                intent: intent,
                counterpartyTimeout: counterpartyTimeout
            });
    }
}

contract BridgeTestMessenger is IBCAppBase {
    using BridgeMessengerLib for *;

    IBCHandler private ibcHandler;
    uint32 private srcChannelId;
    uint64 internal timeout;

    constructor(IBCHandler _ibcHandler, uint64 _timeout) {
        ibcHandler = _ibcHandler;
        timeout = _timeout;
    }

    function ibcAddress() public view virtual override returns (address) {
        return address(ibcHandler);
    }

    function initiate(
        IntentPacket memory packet,
        uint64 localTimeout
    ) internal {
        if (srcChannelId == 0) {
            revert BridgeMessengerLib.ErrNoChannel();
        }
        ibcHandler.sendPacket(
            srcChannelId,
            // No height timeout
            0,
            // Timestamp timeout
            localTimeout,
            // Raw protocol packet
            packet.encode()
        );
    }

    // must override and apply onlyIBC modifier
    function onRecvPacket(
        IBCPacket calldata packet,
        address,
        bytes calldata
    ) external virtual override returns (bytes memory acknowledgement) {}

    function onAcknowledgementPacket(
        IBCPacket calldata,
        bytes calldata acknowledgement,
        address
    ) external virtual override onlyIBC {
        /*
            In practice, a more sophisticated protocol would check
            and execute code depending on the counterparty outcome (refund etc...).
            In our case, the acknowledgement will always be ACK_SUCCESS
        */
        if (
            keccak256(acknowledgement) !=
            keccak256(abi.encodePacked(BridgeMessengerLib.ACK_SUCCESS))
        ) {
            revert BridgeMessengerLib.ErrInvalidAck();
        }
        emit BridgeMessengerLib.Acknowledged();
    }

    function onTimeoutPacket(
        IBCPacket calldata,
        address
    ) external virtual override onlyIBC {
        /*
            Similarly to the onAcknowledgementPacket function, this indicates a failure to deliver the packet in expected time.
            A sophisticated protocol would revert the action done before sending this packet.
        */
        emit BridgeMessengerLib.TimedOut();
    }

    function onChanOpenInit(
        IBCChannelOrder,
        uint32,
        uint32,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // This protocol is only accepting a single counterparty.
        if (srcChannelId != 0) {
            revert BridgeMessengerLib.ErrOnlyOneChannel();
        }
    }

    function onChanOpenTry(
        IBCChannelOrder,
        uint32,
        uint32,
        uint32,
        string calldata,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // Symmetric to onChanOpenInit
        if (srcChannelId != 0) {
            revert BridgeMessengerLib.ErrOnlyOneChannel();
        }
    }

    function onChanOpenAck(
        uint32 channelId,
        uint32,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // Store the port/channel needed to send packets.
        srcChannelId = channelId;
    }

    function onChanOpenConfirm(
        uint32 channelId,
        address
    ) external virtual override onlyIBC {
        // Symmetric to onChanOpenAck
        srcChannelId = channelId;
    }

    function onChanCloseInit(
        uint32,
        address
    ) external virtual override onlyIBC {
        // The ping-pong is infinite, closing the channel is disallowed.
        revert BridgeMessengerLib.ErrInfinitePacket();
    }

    function onChanCloseConfirm(
        uint32,
        address
    ) external virtual override onlyIBC {
        // Symmetric to onChanCloseInit
        revert BridgeMessengerLib.ErrInfinitePacket();
    }
}
