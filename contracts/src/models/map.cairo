#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Map {
    #[key]
    pub id: u32,
    pub rows: u8,
    pub cols: u8,
}
