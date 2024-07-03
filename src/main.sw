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
    #[storage(read)]
    fn withdraw(amount: u64);
    #[storage(read, write)]
    fn get_status() -> bool;
}

storage {
    treasury: Address = Address::from(0x19a0cef7d3e389890590bd41ddca75e834a267a15a8ea5ac03f4e45006378200),
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
    }
    
    #[storage(read)]
    fn withdraw(amount: u64) {
        let tsry = storage.treasury.try_read().unwrap();
        require(tsry == Address::from(0x19a0cef7d3e389890590bd41ddca75e834a267a15a8ea5ac03f4e45006378200), "treasury undefined");
        require(msg_sender().unwrap() == Identity::Address(tsry), "only treasury can call");
        transfer(msg_sender().unwrap(), AssetId::base(), amount);
    }
 
    #[storage(read, write)]
    fn get_status() -> bool {
        let val = storage.statuses.get(msg_sender().unwrap()).try_read().unwrap_or(false);
        return val;
    }
}

