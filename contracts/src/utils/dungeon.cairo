use revolt::models::tile::{Tile, TileValue};
use revolt::models::map::Map;

fn get_dungeon_1() -> Array<Array<u8>> {
    array![
        array![1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        array![1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        array![1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        array![1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        array![1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        array![1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ]
}

fn is_wall(map: @Array<Array<u8>>, x: u8, y: u8) -> bool {
    let rows = map.len();
    let cols = map[0].len();
    let result = if *map.at(y.into()).at(x.into()) == 1 {
        false
    } else if (x + 1).into() < cols && *map.at(y.into()).at((x + 1).into()) == 1 {
        true
    } else if x >= 1 && *map.at(y.into()).at((x - 1).into()) == 1 {
        true
    } else if (y + 1).into() < rows && *map.at((y + 1).into()).at(x.into()) == 1 {
        true
    } else if y >= 1 && *map.at((y - 1).into()).at(x.into()) == 1 {
        true
    } else {
        false
    };
    result
}

pub fn create_dungeon(map_id: u32) -> Map {
    assert(map_id == 1, 'Only map_id 1 is supported');
    let dungeon = get_dungeon_1();

    let rows = dungeon.len();
    let cols = dungeon[0].len();
    Map { id: map_id, rows: rows.try_into().unwrap(), cols: cols.try_into().unwrap(), }
}

pub fn get_dungeon_walls(map_id: u32) -> Array<Tile> {
    let mut result: Array<Tile> = array![];

    assert(map_id == 1, 'Only map_id 1 is supported');
    let dungeon = get_dungeon_1();

    let rows = dungeon.len();
    let cols = dungeon[0].len();

    let mut x = 0_u8;
    let mut y = 0_u8;
    loop {
        if y.into() >= rows {
            break;
        }
        loop {
            if x.into() >= cols {
                break;
            }
            if is_wall(@dungeon, x, y) {
                result.append(Tile { map_id: map_id, pos_x: x, pos_y: y, value: TileValue::Wall, });
            }
            x += 1;
        };
        x = 0;
        y += 1;
    };

    result
}
