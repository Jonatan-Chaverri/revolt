#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Tile {
    #[key]
    pub map_id: u32,
    #[key]
    pub pos_x: u8,
    #[key]
    pub pos_y: u8,
    pub value: TileValue,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum TileValue {
    None,
    Wall,
    Path
}
