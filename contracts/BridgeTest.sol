// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "./BridgeParams.sol";
import "./BridgeTestMessenger.sol";
import "./BridgeTestInterface.sol";
import "./union/apps/Base.sol";
import "./union/core/25-handler/IBCHandler.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BridgeTest
 * @notice This contract is only for testing purposes and does not represent the actual Bridge contract. Therefore, it is not advised to use it in production.
 */
contract BridgeTest is BridgeTestInterface, BridgeTestMessenger, Ownable, ReentrancyGuard {
    
    IWETH9 public immutable WETH;
    bytes32 public constant BRIDGE_TYPEHASH = keccak256(
        "Bridge(address sender,address receiver,address relayer,address inputToken,address outputToken,uint256 inputAmount,uint256 outputAmount,uint32 destinationChainId,uint256 nonce)"
    );
    bytes32 public immutable DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;

    uint256 public fee = 100; // 1%
    address public feeReceiver = 0xBdc3f1A02e56CD349d10bA8D2B038F774ae22731;

    mapping(uint256 intentId => bool exists) public doesIntentExist;

    constructor(
        IWETH9 _wrappedNativeToken,
        IBCHandler _ibcHandler,
        uint64 _timeout
    ) BridgeTestMessenger(_ibcHandler, _timeout) Ownable(msg.sender) {
        WETH = _wrappedNativeToken;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                BRIDGE_TYPEHASH,
                keccak256(bytes("BridgeWithPermit")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function bridge(
        address sender,
        address receiver,
        address relayer,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint32 destinationChainId
    ) external payable {
        uint256 id = uint256(
            keccak256(
                abi.encodePacked(
                    sender,
                    receiver,
                    relayer,
                    inputToken,
                    outputToken,
                    inputAmount,
                    outputAmount,
                    destinationChainId,
                    block.timestamp
                )
            )
        );

        Intent memory intent = Intent({
            sender: sender,
            receiver: receiver,
            relayer: relayer,
            inputToken: inputToken,
            outputToken: outputToken,
            inputAmount: inputAmount,
            outputAmount: outputAmount,
            id: id,
            originChainId: uint32(block.chainid),
            destinationChainId: destinationChainId,
            filledStatus: FilledStatus.NOT_FILLED
        });

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

        doesIntentExist[id] = true;

        emit IntentCreated(intent);
    }

    function bridgeWithPermit(
        BridgeParams calldata params
    ) external payable nonReentrant  {     
        uint256 currentNonce = nonces[params.sender];
        bytes32 structHash = keccak256(
            abi.encode(
                BRIDGE_TYPEHASH,
                params.sender,
                params.receiver,
                params.relayer,
                params.inputToken,
                params.outputToken,
                params.inputAmount,
                params.outputAmount,
                params.destinationChainId,
                currentNonce
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)); 

        require(SignatureChecker.isValidSignatureNow(params.sender, digest, params.signature),"Invalid signature");

        nonces[params.sender]++;

        uint256 id = uint256(
            keccak256(
                abi.encodePacked(
                    params.sender,
                    params.receiver,
                    params.relayer,
                    params.inputToken,
                    params.outputToken,
                    params.inputAmount,
                    params.outputAmount,
                    params.destinationChainId,
                    block.timestamp
                )
            )
        );

        Intent memory intent = Intent({
            sender: params.sender,
            receiver: params.receiver,
            relayer: params.relayer,
            inputToken: params.inputToken,
            outputToken: params.outputToken,
            inputAmount: params.inputAmount,
            outputAmount: params.outputAmount,
            id: id,
            originChainId: uint32(block.chainid),
            destinationChainId: params.destinationChainId,
            filledStatus: FilledStatus.NOT_FILLED
        });

        if (intent.inputToken == address(WETH) && msg.value > 0) {
            if (msg.value != intent.inputAmount) {
                revert MsgValueDoesNotMatchInputAmount();
            }
            // if the input token is WETH, deposit the amount to the contract
            WETH.deposit{value: msg.value}();
        } else {
            // if the input token is not WETH, transfer the amount from the sender to the contract (lock)
            IERC20(intent.inputToken).transferFrom(
                params.sender,
                address(this),
                intent.inputAmount
            );
        }

        doesIntentExist[id] = true;

        //emit IntentCreated(intent);
        emit IntentCreated(
            Intent({
                sender: params.sender,
                receiver: params.receiver,
                relayer: params.relayer,
                inputToken: params.inputToken,
                outputToken: params.outputToken,
                inputAmount: params.inputAmount,
                outputAmount: params.outputAmount,
                id: id,
                originChainId: uint32(block.chainid),
                destinationChainId: params.destinationChainId,
                filledStatus: FilledStatus.NOT_FILLED
            })
        );
    }

    function fulfill(Intent calldata intent) external payable nonReentrant  {
        if (intent.relayer != msg.sender) {
            revert UnauthorizedRelayer();
        }
        doesIntentExist[intent.id] = true;

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

        if (!doesIntentExist[pp.intent.id]) {
            return abi.encodePacked(BridgeMessengerLib.ACK_FAILURE);
        }

        _repay(pp.intent);

        // Return protocol specific successful acknowledgement
        return abi.encodePacked(BridgeMessengerLib.ACK_SUCCESS);
    }

    // ADMIN FUNCTIONS
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    function _repay(Intent memory intent) internal nonReentrant {
        // take fee
        uint256 feeAmount = (intent.inputAmount * fee) / 10000;
        uint256 repayAmount = intent.inputAmount - feeAmount;
        doesIntentExist[intent.id] = false; // delete the intent

        if (intent.inputToken == address(WETH)) {
            // if the input token is WETH, transfer the amount from the contract to the sender

            // unwrap if contract has WETH
            WETH.withdraw(repayAmount);
            payable(intent.relayer).transfer(repayAmount);
        } else {
            // if the input token is not WETH, transfer the amount from the contract to the sender
            IERC20(intent.inputToken).transfer(intent.relayer, repayAmount);
        }

        // transfer fee to fee receiver
        if (feeAmount > 0) {
            if (intent.inputToken == address(WETH)) {
                // if the input token is WETH, transfer the amount from the contract to the fee receiver

                // unwrap if contract has WETH
                WETH.withdraw(feeAmount);
                payable(feeReceiver).transfer(feeAmount);
            } else {
                // if the input token is not WETH, transfer the amount from the contract to the fee receiver
                IERC20(intent.inputToken).transfer(feeReceiver, feeAmount);
            }
        }

        emit IntentRepaid(intent);

    }

    receive() external payable {}
}