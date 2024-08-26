use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub game_id: u32,
    #[key]
    pub player_address: ContractAddress,
    pub score: u16,
    pub state: bool,
    pub pos_x: u8,
    pub pos_y: u8,
    pub freeze: u8,
    pub health: u8,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum Direction {
    None,
    Up,
    Down,
    Left,
    Right
}
