// contract.rs
use crate::msg::{ExecuteMsg, InitMsg, IntentPacket};
use crate::state::{Config, FilledStatus, Intent, CONFIG, INTENTS};
use crate::ContractError;
use cosmwasm_std::{
    entry_point, Addr, DepsMut, Env, IbcMsg, IbcTimeout, MessageInfo, Response, StdResult,
    Timestamp, Uint128,
};

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: InitMsg,
) -> StdResult<Response> {
    let config = Config {
        fee: msg.fee,
        fee_receiver: msg.fee_receiver,
        timeout: msg.timeout,
    };
    CONFIG.save(deps.storage, &config)?;
    Ok(Response::default())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::Bridge {
            sender,
            receiver,
            relayer,
            input_token,
            output_token,
            input_amount,
            output_amount,
            destination_chain_id,
        } => try_bridge(
            deps,
            sender,
            receiver,
            relayer,
            input_token,
            output_token,
            input_amount,
            output_amount,
            _env.block.chain_id.parse().unwrap(),
            destination_chain_id,
        ),
        ExecuteMsg::Fulfill { intent, channel_id } => try_fulfill(deps, _info, intent, channel_id),
        ExecuteMsg::Initiate {
            channel_id: _,
            packet: _,
        } => {
            // let ibc_packet = packet.reverse(&config, env.block.time.nanos(), channel_id);
            Ok(Response::default())
        }
    }
}

pub fn try_bridge(
    deps: DepsMut,
    sender: Addr,
    receiver: Addr,
    relayer: Addr,
    input_token: Addr,
    output_token: Addr,
    input_amount: u128,
    output_amount: u128,
    origin_chain_id: u32,
    destination_chain_id: u32,
) -> Result<Response, ContractError> {
    let id = Uint128::new(input_amount + output_amount);
    let intent = Intent {
        sender,
        receiver,
        relayer,
        input_token,
        output_token,
        input_amount,
        output_amount,
        id: id.into(),
        origin_chain_id,
        destination_chain_id,
        filled_status: FilledStatus::NotFilled,
    };

    INTENTS.save(deps.storage, id.u128(), &intent)?;
    Ok(Response::new().add_attribute("action", "bridge"))
}

pub fn try_fulfill(
    deps: DepsMut,
    _info: MessageInfo,
    intent: Intent,
    channel_id: String,
) -> Result<Response, ContractError> {
    if intent.relayer != _info.sender {
        return Err(ContractError::UnauthorizedRelayer {});
    }

    // TODO: send tokens to the receiver

    // save intent
    INTENTS.save(deps.storage, intent.id, &intent)?;

    // send cross chain message to intent source chain, so that the relayer can be repaid
    let packet = IntentPacket {
        intent,
        counterparty_timeout_timestamp: 0,
    };

    IbcMsg::SendPacket {
        channel_id,
        data: packet.encode().into(),
        timeout: IbcTimeout::with_timestamp(Timestamp::from_nanos(
            packet.counterparty_timeout_timestamp,
        )),
    };

    Ok(Response::new().add_attribute("action", "fulfill"))
}
