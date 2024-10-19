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
    bytes1 public constant ACK_FAILURE = 0x02;

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
    string public channelId;
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
        if (bytes(channelId).length == 0) {
            revert BridgeMessengerLib.ErrNoChannel();
        }
        ibcHandler.sendPacket(
            channelId,
            // No height timeout
            IbcCoreClientV1Height.Data({
                revision_number: 0,
                revision_height: 0
            }),
            // Timestamp timeout
            localTimeout,
            // Raw protocol packet
            packet.encode()
        );
    }

    // must override and apply onlyIBC modifier
    function onRecvPacket(
        IbcCoreChannelV1Packet.Data calldata packet,
        address
    ) external virtual override returns (bytes memory acknowledgement) {}

    function onAcknowledgementPacket(
        IbcCoreChannelV1Packet.Data calldata,
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
        IbcCoreChannelV1Packet.Data calldata,
        address
    ) external virtual override onlyIBC {
        /*
            Similarly to the onAcknowledgementPacket function, this indicates a failure to deliver the packet in expected time.
            A sophisticated protocol would revert the action done before sending this packet.
        */
        emit BridgeMessengerLib.TimedOut();
    }

    function onChanOpenInit(
        IbcCoreChannelV1GlobalEnums.Order,
        string[] calldata,
        string calldata,
        string calldata,
        IbcCoreChannelV1Counterparty.Data calldata,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // This protocol is only accepting a single counterparty.
        if (bytes(channelId).length != 0) {
            revert BridgeMessengerLib.ErrOnlyOneChannel();
        }
    }

    function onChanOpenTry(
        IbcCoreChannelV1GlobalEnums.Order,
        string[] calldata,
        string calldata,
        string calldata,
        IbcCoreChannelV1Counterparty.Data calldata,
        string calldata,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // Symmetric to onChanOpenInit
        if (bytes(channelId).length != 0) {
            revert BridgeMessengerLib.ErrOnlyOneChannel();
        }
    }

    function onChanOpenAck(
        string calldata,
        string calldata _channelId,
        string calldata,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // Store the port/channel needed to send packets.
        channelId = _channelId;
    }

    function onChanOpenConfirm(
        string calldata,
        string calldata _channelId,
        address
    ) external virtual override onlyIBC {
        // Symmetric to onChanOpenAck
        channelId = _channelId;
    }

    function onChanCloseInit(
        string calldata,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // The ping-pong is infinite, closing the channel is disallowed.
        revert BridgeMessengerLib.ErrInfinitePacket();
    }

    function onChanCloseConfirm(
        string calldata,
        string calldata,
        address
    ) external virtual override onlyIBC {
        // Symmetric to onChanCloseInit
        revert BridgeMessengerLib.ErrInfinitePacket();
    }
}
