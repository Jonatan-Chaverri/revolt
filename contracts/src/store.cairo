use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use revolt::models::tile::Tile;
use revolt::models::map::Map;
use revolt::models::game::Game;
use revolt::models::player::Player;

use starknet::ContractAddress;

#[derive(Drop)]
struct Store {
    world: IWorldDispatcher
}

#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    fn get_tile(ref self: Store, map_id: u32, pos_x: u8, pos_y: u8) -> Tile {
        get!(self.world, (map_id, pos_x, pos_y), (Tile))
    }

    fn set_tile(ref self: Store, tile: Tile) {
        set!(self.world, (tile));
    }

    fn get_map(ref self: Store, id: u32) -> Map {
        get!(self.world, (id), (Map))
    }

    fn set_map(ref self: Store, map: Map) {
        set!(self.world, (map));
    }

    fn get_game(ref self: Store, id: u32) -> Game {
        get!(self.world, (id), (Game))
    }

    fn set_game(ref self: Store, game: Game) {
        set!(self.world, (game));
    }

    fn get_player(ref self: Store, game_id: u32, player_address: ContractAddress) -> Player {
        get!(self.world, (game_id, player_address), (Player))
    }

    fn set_player(ref self: Store, player: Player) {
        set!(self.world, (player));
    }
}
