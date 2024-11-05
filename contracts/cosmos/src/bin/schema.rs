use cosmwasm_schema::write_api;

use cosmwasm_test::msg::{ExecuteMsg, InitMsg};

fn main() {
    write_api! {
        instantiate: InitMsg,
        execute: ExecuteMsg,
    }
}
