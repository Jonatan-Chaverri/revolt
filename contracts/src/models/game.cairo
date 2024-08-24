use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub id: u32,
    pub player_1_address: ContractAddress,
    pub player_2_address: ContractAddress,
    pub player_3_address: ContractAddress,
    pub player_4_address: ContractAddress,
    pub map_id: u32,
    pub state: bool,
    pub winner: ContractAddress,
}
