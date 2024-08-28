use revolt::models::tile::{Tile, TileValue};
use revolt::models::map::Map;

#[derive(Copy, Drop)]
struct MapEntry {
    value: u8,
    reps: u8
}

fn map_entry(value: u8, reps: u8) -> MapEntry {
    MapEntry { value: value, reps: reps }
}

fn get_dungeon_1() -> (Array<Array<MapEntry>>, u8, u8) {
    (
        array![
            array![map_entry(1, 35)],
            array![
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
            ],
            array![
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
                map_entry(0, 1),
                map_entry(1, 1),
            ],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 33), map_entry(1, 1)],
            // array![map_entry(1, 1), map_entry(0, 30), map_entry(1, 4)],
            // array![map_entry(1, 1), map_entry(0, 30), map_entry(1, 4)],
            // array![map_entry(1, 1), map_entry(0, 30), map_entry(1, 4)],
            array![map_entry(1, 35)],
        ],
        21,
        35
    )
}


pub fn create_dungeon(map_id: u32) -> Map {
    assert(map_id == 1, 'Only map_id 1 is supported');
    let (_, cols, rows) = get_dungeon_1();

    Map { id: map_id, rows: rows.try_into().unwrap(), cols: cols.try_into().unwrap(), }
}

pub fn get_dungeon_walls(map_id: u32) -> Array<Tile> {
    let mut result: Array<Tile> = array![];

    assert(map_id == 1, 'Only map_id 1 is supported');
    let (dungeon, _, _) = get_dungeon_1();

    // This just tracks the real mapEntry data inside the dungeon array
    let mut x = 0_u8;
    let mut y = 0_u8;

    // This is to track the position of the tile in the result array
    let mut col_index = 0_u8;
    loop {
        if y.into() >= dungeon.len() {
            break;
        }
        loop {
            if x.into() >= dungeon.at(y.into()).len() {
                break;
            }
            let map_entry = *dungeon.at(y.into()).at(x.into());
            if map_entry.value == 1 {
                let mut inserted_tiles = 0;
                loop {
                    if inserted_tiles == map_entry.reps {
                        break;
                    }
                    result
                        .append(
                            Tile {
                                map_id: map_id, pos_x: col_index, pos_y: y, value: TileValue::Wall,
                            }
                        );
                    inserted_tiles += 1;
                    col_index += 1;
                };
            } else {
                col_index += map_entry.reps;
            }
            x += 1;
        };
        col_index = 0;
        x = 0;
        y += 1;
    };

    result
}
