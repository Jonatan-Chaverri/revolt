#[dojo::contract]
mod config_system {
    use revolt::store::{Store, StoreTrait};
    use revolt::utils::dungeon;

    fn dojo_init(world: @IWorldDispatcher) {
        let mut store: Store = StoreTrait::new(world);

        let available_dungeons = array![1_u32];
        let mut idx = 0_u8;
        loop {
            if idx.into() >= available_dungeons.len() {
                break;
            }
            let map_id = *available_dungeons.at(idx.into());
            let map = dungeon::create_dungeon(map_id);
            store.set_map(map);

            let dungeon_walls = dungeon::get_dungeon_walls(map_id);
            let mut wall_idx = 0;
            loop {
                if wall_idx >= dungeon_walls.len() {
                    break;
                }
                store.set_tile(*dungeon_walls[wall_idx]);
                wall_idx += 1;
            };
            idx += 1;
        };
    }
}
