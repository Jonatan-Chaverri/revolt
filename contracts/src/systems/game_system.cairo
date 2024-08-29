use dojo::world::{IWorld, IWorldDispatcher};

use revolt::models::player::Direction;

#[dojo::interface]
trait IGameSystem {
    fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32;
    fn join_game(ref world: IWorldDispatcher, player_name: felt252, game_id: u32) -> bool;
    fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction);
    fn attack(ref world: IWorldDispatcher, game_id: u32);
}

#[dojo::contract]
mod game_system {
    use super::IGameSystem;
    use super::Direction;

    use revolt::store::{Store, StoreTrait};
    use revolt::models::game::Game;
    use revolt::models::tile::TileValue;
    use revolt::models::player::Player;
    use starknet::{get_caller_address, ContractAddress};

    #[abi(embed_v0)]
    impl ActionsImpl of IGameSystem<ContractState> {
        fn create_game(ref world: IWorldDispatcher, player_name: felt252) -> u32 {
            let mut store: Store = StoreTrait::new(world);

            let game_id = world.uuid() + 1;
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

            let player = Player {
                game_id: game_id,
                player_address: get_caller_address(),
                score: 0,
                state: true,
                pos_x: 3,
                pos_y: 3,
                freeze: 0,
                health: 100,
            };
            store.set_player(player);

            game_id
        }

        fn join_game(ref world: IWorldDispatcher, player_name: felt252, game_id: u32) -> bool {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            assert(game.state, 'Game is not available');

            let mut pos_x = 0;
            let mut pos_y = 0;
            if game.player_2_address.is_zero() {
                game.player_2_address = get_caller_address();
                pos_x = 2;
                pos_y = 17;
            } else if game.player_3_address.is_zero() {
                game.player_3_address = get_caller_address();
                pos_x = 31;
                pos_y = 6;
            } else if game.player_4_address.is_zero() {
                game.player_4_address = get_caller_address();
                pos_x = 23;
                pos_y = 16;
            } else {
                assert(false, 'Game is full');
            }
            store.set_game(game);

            let player = Player {
                game_id: game_id,
                player_address: get_caller_address(),
                score: 0,
                state: true,
                pos_x: pos_x,
                pos_y: pos_y,
                freeze: 0,
                health: 100,
            };
            store.set_player(player);

            true
        }

        fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            assert(game.state, 'Game is not available');

            let mut player = store.get_player(game_id, get_caller_address());
            assert(player.state, 'Player is not available');

            match direction {
                Direction::Up => { if player.pos_y > 0 {
                    player.pos_y -= 1;
                } },
                Direction::Down => { player.pos_y += 1; },
                Direction::Left => { if player.pos_x > 0 {
                    player.pos_x -= 1;
                } },
                Direction::Right => { player.pos_x += 1; },
                _ => { assert(false, 'Invalid direction'); }
            }
            if player.freeze > 0 {
                player.freeze -= 1;
            }

            let is_valid_mov = self
                .is_movement_valid(
                    ref store, @game, player.pos_x, player.pos_y, get_caller_address()
                );
            if is_valid_mov {
                store.set_player(player);
            }
        }

        fn attack(ref world: IWorldDispatcher, game_id: u32) {
            let mut store: Store = StoreTrait::new(world);

            let mut game = store.get_game(game_id);
            assert(game.state, 'Game is not available');

            let mut player = store.get_player(game_id, get_caller_address());
            assert(player.state, 'Player is not available');

            assert(player.freeze == 0, 'Player is frozen');
            
            self.attack_player(ref store, game_id, ref player, game.player_1_address);
            self.attack_player(ref store, game_id, ref player, game.player_2_address);
            self.attack_player(ref store, game_id, ref player, game.player_3_address);
            self.attack_player(ref store, game_id, ref player, game.player_4_address);

            let mut player_after = store.get_player(game_id, get_caller_address());
            player_after.freeze += 5;
            store.set_player(player_after);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn is_movement_valid(
            self: @ContractState,
            ref store: Store,
            game: @Game,
            pos_x: u8,
            pos_y: u8,
            caller: ContractAddress
        ) -> bool {
            let mut tile = store.get_tile(*game.map_id, pos_x, pos_y);
            let is_wall = tile.value == TileValue::Wall;

            // let (p1_pos_x, p1_pos_y) = self
            //     .get_player_position(ref store, *game.id, *game.player_1_address);
            // let (p2_pos_x, p2_pos_y) = self
            //     .get_player_position(ref store, *game.id, *game.player_2_address);
            // let (p3_pos_x, p3_pos_y) = self
            //     .get_player_position(ref store, *game.id, *game.player_3_address);
            // let (p4_pos_x, p4_pos_y) = self
            //     .get_player_position(ref store, *game.id, *game.player_4_address);

            // let result = if is_wall {
            //     false
            // } else if *game.player_1_address != caller && p1_pos_x == pos_x && p1_pos_y == pos_y {
            //     false
            // } else if *game.player_2_address != caller && p2_pos_x == pos_x && p2_pos_y == pos_y {
            //     false
            // } else if *game.player_3_address != caller && p3_pos_x == pos_x && p3_pos_y == pos_y {
            //     false
            // } else if *game.player_4_address != caller && p4_pos_x == pos_x && p4_pos_y == pos_y {
            //     false
            // } else {
            //     true
            // };

            let result = if is_wall {
                     false
            } else {
                true
            };
            result
        }

        fn get_player_position(
            self: @ContractState, ref store: Store, game_id: u32, player_address: ContractAddress
        ) -> (u8, u8) {
            let player = store.get_player(game_id, player_address);
            (player.pos_x, player.pos_y)
        }

        fn attack_player(
            self: @ContractState, ref store: Store, game_id: u32, ref current_player: Player, player_address: ContractAddress
        ) {
            let mut player = store.get_player(game_id, player_address);
            
            if current_player.player_address != player_address && player.state &&
                self.player_in_attack_range(current_player.pos_x, current_player.pos_y, player.pos_x, player.pos_y)
            {
                if player.health <= 20 {
                    player.state = false;
                    player.health = 0;
                } else {
                    player.health -= 20;
                }
                current_player.score += 10;
                store.set_player(player);
                store.set_player(current_player);
            }
        }

        fn player_in_attack_range(
            self: @ContractState, attacker_x: u8, attacker_y: u8, player_x: u8, player_y: u8
        ) -> bool {
            let mut result_x = false;
            let mut result_y = false;

            if attacker_x >= player_x {
                result_x = attacker_x - player_x <= 1;
            } else {
                result_x = player_x - attacker_x <= 1;
            }

            if attacker_y >= player_y {
                result_y = attacker_y - player_y <= 1;
            } else {
                result_y = player_y - attacker_y <= 1;
            }

            result_x && result_y
        }
    }
}
