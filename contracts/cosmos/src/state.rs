// state.rs
use cosmwasm_schema::cw_serde;
use cosmwasm_std::Addr;
use cw_storage_plus::{Item, Map};

#[cw_serde]
pub enum FilledStatus {
    NotFilled,
    Filled,
}

#[cw_serde]
pub struct Intent {
    pub sender: Addr,
    pub receiver: Addr,
    pub relayer: Addr,
    pub input_token: Addr,
    pub output_token: Addr,
    pub input_amount: u128,
    pub output_amount: u128,
    pub id: u128,
    pub origin_chain_id: u32,
    pub destination_chain_id: u32,
    pub filled_status: FilledStatus,
}

#[cw_serde]
pub struct Config {
    pub fee: u64,
    pub fee_receiver: Addr,
    pub timeout: u64,
}

pub const CONFIG: Item<Config> = Item::new("config");
pub const INTENTS: Map<u128, Intent> = Map::new("intents");
