use dojo::world::{IWorld, IWorldDispatcher};

#[dojo::interface]
trait IGameSystem {
    fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32;
    fn join_game(ref world: IWorldDispatcher, player_name: felt252, game_id: u32) -> bool;
}

#[dojo::contract]
mod game_system {
    use super::IGameSystem;

    use revolt::store::{Store, StoreTrait};
    use revolt::models::game::Game;
    use starknet::get_caller_address;

    #[abi(embed_v0)]
    impl ActionsImpl of IGameSystem<ContractState> {
        fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32 {
            let mut store: Store = StoreTrait::new(world);
            
            let game_id = world.uuid();
            let mut game = Game {
                id: game_id,
                player_1_address: get_caller_address(),
                player_2_address: Zeroable::zero(),
                player_3_address: Zeroable::zero(),
                player_4_address: Zeroable::zero(),
                map_id: 1,
                state: true,
                winner: Zeroable::zero(),
            };
            store.set_game(game);

            game_id
        }

        fn join_game(ref world: IWorldDispatcher, player_name: felt252, game_id: u32) -> bool {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            assert(game.state, 'Game is not available');

            if game.player_2_address.is_zero() {
                game.player_2_address = get_caller_address();
            } else if game.player_3_address.is_zero() {
                game.player_3_address = get_caller_address();
            } else if game.player_4_address.is_zero() {
                game.player_4_address = get_caller_address();
            } else {
                assert(false, 'Game is full');
            }

            store.set_game(game);
            true
        }
    }
}
