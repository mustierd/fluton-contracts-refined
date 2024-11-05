// ibc.rs
use crate::msg::IntentPacket;
use crate::state::{FilledStatus, INTENTS};
use crate::ContractError;
use cosmwasm_std::{
    attr, entry_point, Binary, DepsMut, Env, IbcBasicResponse, IbcChannel, IbcChannelCloseMsg,
    IbcChannelConnectMsg, IbcChannelOpenMsg, IbcOrder, IbcPacketAckMsg, IbcPacketReceiveMsg,
    IbcPacketTimeoutMsg, IbcReceiveResponse, Reply, Response, StdError, StdResult,
};

pub const PROTOCOL_VERSION: &str = "cosmwasm-bridge-1";
pub const PROTOCOL_ORDERING: IbcOrder = IbcOrder::Unordered;

fn ack_success() -> Binary {
    Binary::from(vec![1])
}

fn ack_fail() -> Binary {
    Binary::from(vec![0])
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn reply(_deps: DepsMut, _env: Env, _reply: Reply) -> Result<Response, ContractError> {
    Ok(Response::default())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn ibc_channel_open(
    _deps: DepsMut,
    _env: Env,
    msg: IbcChannelOpenMsg,
) -> Result<(), ContractError> {
    enforce_order_and_version(msg.channel(), msg.counterparty_version())?;
    Ok(())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn ibc_channel_connect(
    _deps: DepsMut,
    _env: Env,
    msg: IbcChannelConnectMsg,
) -> Result<IbcBasicResponse, ContractError> {
    enforce_order_and_version(msg.channel(), msg.counterparty_version())?;
    Ok(IbcBasicResponse::default())
}

fn enforce_order_and_version(
    channel: &IbcChannel,
    counterparty_version: Option<&str>,
) -> Result<(), ContractError> {
    if channel.version != PROTOCOL_VERSION {
        return Err(ContractError::InvalidIbcVersion {
            version: channel.version.clone(),
        });
    }
    if let Some(version) = counterparty_version {
        if version != PROTOCOL_VERSION {
            return Err(ContractError::InvalidIbcVersion {
                version: version.to_string(),
            });
        }
    }
    if channel.order != PROTOCOL_ORDERING {
        return Err(ContractError::OnlyOrderedChannel {});
    }
    Ok(())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn ibc_channel_close(
    _deps: DepsMut,
    _env: Env,
    _channel: IbcChannelCloseMsg,
) -> Result<IbcBasicResponse, ContractError> {
    Err(StdError::generic_err("The packet transport is infinite").into())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn ibc_packet_receive(
    deps: DepsMut,
    env: Env,
    msg: IbcPacketReceiveMsg,
) -> StdResult<IbcReceiveResponse> {
    let packet = msg.packet;
    let intent_packet =
        IntentPacket::decode(packet.data).map_err(|_| StdError::generic_err("decode failed"))?;

    // if the intent is not meant for this chain, forward it to the destination chain
    if intent_packet.intent.destination_chain_id != env.block.chain_id.parse::<u32>().unwrap() {
        intent_packet.forward(packet.dest.channel_id); // this is probably wrong
        return Ok(IbcReceiveResponse::new()
            .set_ack(ack_fail())
            .add_attributes(vec![
                attr("action", "receive_packet_failed"),
                attr("success", "false"),
                attr("error", "wrong destination chain"),
            ]));
    }

    let intent = INTENTS.load(deps.storage, intent_packet.intent.id).unwrap();

    if intent.filled_status == FilledStatus::Filled {
        return Ok(IbcReceiveResponse::new()
            .set_ack(ack_fail())
            .add_attributes(vec![
                attr("action", "receive_packet_failed"),
                attr("success", "false"),
                attr("error", "intent already fulfilled"),
            ]));
    }

    // Update intent status and process fulfillment
    INTENTS.update(
        deps.storage,
        intent_packet.intent.id,
        |intent| -> StdResult<_> {
            let mut intent = intent.unwrap();
            intent.filled_status = FilledStatus::Filled;
            Ok(intent)
        },
    )?;

    Ok(IbcReceiveResponse::new()
        .set_ack(ack_success())
        .add_attribute("action", "receive_packet")
        .add_attribute("intent_id", intent_packet.intent.id.to_string()))
}

#[entry_point]
pub fn ibc_packet_ack(
    _deps: DepsMut,
    _env: Env,
    _msg: IbcPacketAckMsg,
) -> StdResult<IbcBasicResponse> {
    let attributes = vec![attr("action", "acknowledge")];
    Ok(IbcBasicResponse::new().add_attributes(attributes))
}

#[entry_point]
pub fn ibc_packet_timeout(
    deps: DepsMut,
    _env: Env,
    msg: IbcPacketTimeoutMsg,
) -> StdResult<IbcBasicResponse> {
    let packet = msg.packet;
    let intent_packet =
        IntentPacket::decode(packet.data).map_err(|_| StdError::generic_err("decode failed"))?;
    let mut intent = INTENTS.load(deps.storage, intent_packet.intent.id)?;

    // Reset the intent status for reprocessing
    intent.filled_status = FilledStatus::NotFilled;
    INTENTS.save(deps.storage, intent_packet.intent.id, &intent)?;

    Ok(IbcBasicResponse::new()
        .add_attribute("action", "packet_timeout")
        .add_attribute("intent_id", intent_packet.intent.id.to_string()))
}
