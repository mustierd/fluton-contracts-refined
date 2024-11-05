// msg.rs
use cosmwasm_schema::cw_serde;
use cosmwasm_std::{Addr, IbcMsg, IbcTimeout, Timestamp};
use ethabi::{ParamType, Token};

use crate::{
    state::{FilledStatus, Intent},
    ContractError,
};

#[cw_serde]
pub struct InitMsg {
    pub fee: u64,
    pub fee_receiver: Addr,
    pub timeout: u64,
}

#[cw_serde]
pub enum ExecuteMsg {
    Bridge {
        sender: Addr,
        receiver: Addr,
        relayer: Addr,
        input_token: Addr,
        output_token: Addr,
        input_amount: u128,
        output_amount: u128,
        destination_chain_id: u32,
    },
    Fulfill {
        intent: Intent,
        channel_id: String,
    },
    Initiate {
        channel_id: String,
        packet: IntentPacket,
    },
}

#[cw_serde]
pub struct IntentPacket {
    pub intent: Intent,
    pub counterparty_timeout_timestamp: u64,
}

impl IntentPacket {
    pub fn decode(bz: impl AsRef<[u8]>) -> Result<Self, ContractError> {
        let values = ethabi::decode(
            &[
                ParamType::Address,
                ParamType::Address,
                ParamType::Address,
                ParamType::Address,
                ParamType::Address,
                ParamType::Uint(256),
                ParamType::Uint(256),
                ParamType::Uint(256),
                ParamType::Uint(32),
                ParamType::Uint(32),
                ParamType::Uint(8),
                ParamType::Uint(64),
            ],
            bz.as_ref(),
        )
        .map_err(|_| ContractError::EthAbiDecoding)?;

        match &values[..] {
            &[Token::Address(sender), Token::Address(receiver), Token::Address(relayer), Token::Address(input_token), Token::Address(output_token), Token::Uint(input_amount), Token::Uint(output_amount), Token::Uint(id), Token::Uint(origin_chain_id), Token::Uint(destination_chain_id), Token::Uint(filled_status), Token::Uint(counterparty_timeout_timestamp)] => {
                Ok(IntentPacket {
                    intent: Intent {
                        sender: Addr::unchecked(sender.to_string()),
                        receiver: Addr::unchecked(receiver.to_string()),
                        relayer: Addr::unchecked(relayer.to_string()),
                        input_token: Addr::unchecked(input_token.to_string()),
                        output_token: Addr::unchecked(output_token.to_string()),
                        input_amount: input_amount.as_u128(),
                        output_amount: output_amount.as_u128(),
                        id: id.as_u128(),
                        origin_chain_id: origin_chain_id.as_u32(),
                        destination_chain_id: destination_chain_id.as_u32(),
                        filled_status: if filled_status.as_u64() == 0 {
                            FilledStatus::NotFilled
                        } else {
                            FilledStatus::Filled
                        },
                    },
                    counterparty_timeout_timestamp: counterparty_timeout_timestamp.as_u64(),
                })
            }
            _ => Err(ContractError::EthAbiDecoding),
        }
    }

    pub fn encode(&self) -> Vec<u8> {
        let filled_status = match self.intent.filled_status {
            FilledStatus::NotFilled => 0u64,
            FilledStatus::Filled => 1u64,
        };

        ethabi::encode(&[
            Token::Address(self.intent.sender.to_string().parse().unwrap()),
            Token::Address(self.intent.receiver.to_string().parse().unwrap()),
            Token::Address(self.intent.relayer.to_string().parse().unwrap()),
            Token::Address(self.intent.input_token.to_string().parse().unwrap()),
            Token::Address(self.intent.output_token.to_string().parse().unwrap()),
            Token::Uint(self.intent.input_amount.into()),
            Token::Uint(self.intent.output_amount.into()),
            Token::Uint(self.intent.id.into()),
            Token::Uint(self.intent.origin_chain_id.into()),
            Token::Uint(self.intent.destination_chain_id.into()),
            Token::Uint(filled_status.into()),
            // Encoding the additional counterparty_timeout field
            Token::Uint(self.counterparty_timeout_timestamp.into()),
        ])
    }
}

impl IntentPacket {
    pub fn forward(&self, channel_id: String) -> IbcMsg {
        IbcMsg::SendPacket {
            channel_id,
            data: self.encode().into(),
            timeout: IbcTimeout::with_timestamp(Timestamp::from_nanos(
                self.counterparty_timeout_timestamp,
            )),
        }
    }
}

#[cw_serde]
pub enum IbcMsgType {
    InitChannel,
    AckPacket,
    TimeoutPacket,
}
