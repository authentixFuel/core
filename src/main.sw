contract;

use std::{
    auth::{
        msg_sender,
    },
    call_frames::{
        msg_asset_id,
    },
    asset::{
        transfer,
    },
    contract_id::ContractId,
    context::{
        balance_of,
        msg_amount,
    },
    hash::Hash,
};

abi Authentix {
    #[payable]
    #[storage(read, write)]
    fn deposit();
    #[storage(read, write)]
    fn withdraw(amount: u64);
    #[storage(read)]
    fn show_treasury() -> (u64, u64);
    #[storage(read, write)]
    fn get_status() -> bool;
}

storage {
    treasury: Address = Address::from(0x19a0cef7d3e389890590bd41ddca75e834a267a15a8ea5ac03f4e45006378200),
    total_transferred: u64 = 0,
    total_withdrawn: u64 = 0,
    statuses: StorageMap<Identity, bool> = StorageMap{},
}

impl Authentix for Contract {
    #[payable]
    #[storage(read, write)]
    fn deposit() {
        let cur_stat = storage.statuses.get(msg_sender().unwrap()).try_read().unwrap_or(false);
        require(cur_stat == false, "you already paid the premium");
        require(msg_asset_id() == AssetId::base(), "not base asset");
        require(msg_amount() > 0, "amount = 0");
        storage.statuses.insert(msg_sender().unwrap(), true);
        let current_amt = storage.total_transferred.try_read().unwrap_or(0);
        storage.total_transferred.write(current_amt + msg_amount());
    }
    
    #[storage(read, write)]
    fn withdraw(amount: u64) {
        let tsry = storage.treasury.try_read().unwrap();
        require(tsry == Address::from(0x19a0cef7d3e389890590bd41ddca75e834a267a15a8ea5ac03f4e45006378200), "treasury undefined");
        require(msg_sender().unwrap() == Identity::Address(tsry), "only treasury can call");
        transfer(msg_sender().unwrap(), AssetId::base(), amount);
        let current_wtd = storage.total_withdrawn.try_read().unwrap_or(0);
        storage.total_withdrawn.write(current_wtd + amount);
    }
    
    #[storage(read)]
    fn show_treasury() -> (u64, u64) {
        let tt = storage.total_transferred.try_read().unwrap_or(0);
        let tw = storage.total_withdrawn.try_read().unwrap_or(0);
        return (tt, tw);
    }
 
    #[storage(read, write)]
    fn get_status() -> bool {
        let val = storage.statuses.get(msg_sender().unwrap()).try_read().unwrap_or(false);
        return val;
    }
}

