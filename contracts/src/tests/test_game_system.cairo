mod test_config_system {
    use revolt::systems::config_system::config_system;
    use revolt::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use revolt::systems::game_system::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use revolt::store::{Store, StoreTrait};
    use revolt::models::player::Direction;
    use starknet::testing::set_contract_address;

    #[test]
    #[available_gas(300000000000)]
    fn test_create_game() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);

        set_contract_address(world.contract_address);
        systems.config_system.dojo_init();
        set_contract_address(OWNER());

        let game_id = systems.game_system.create_game('player1');
        assert(game_id == 1, 'Game ID should be 1');

        let mut game = store.get_game(game_id);
        assert(game.player_1_address == OWNER(), 'Address should be the OWNER');
        assert(game.state, 'Game should be available');

        let player = store.get_player(game_id, game.player_1_address);
        assert(player.state, 'Player should be available');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_join_game() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);

        set_contract_address(world.contract_address);
        systems.config_system.dojo_init();
        set_contract_address(OWNER());

        let game_id = systems.game_system.create_game('player1');
        let mut game = store.get_game(game_id);
        assert(game.player_2_address.is_zero(), 'player 2 address not zero');

        let player_2_address = starknet::contract_address_const::<'ANYONE'>();
        set_contract_address(player_2_address);
        let result = systems.game_system.join_game('player2', game_id);
        assert(result, 'Should be able to join the game');

        let mut game_after = store.get_game(game_id);
        assert(game_after.player_2_address == player_2_address, 'player 2 address not set');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_move() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);

        set_contract_address(world.contract_address);
        systems.config_system.dojo_init();
        set_contract_address(OWNER());

        let game_id = systems.game_system.create_game('player1');
        let mut game = store.get_game(game_id);

        let player = store.get_player(game_id, game.player_1_address);
        let initial_x = player.pos_x;
        let initial_y = player.pos_y;

        systems.game_system.move(game_id, Direction::Up);

        let player_after = store.get_player(game_id, game.player_1_address);
        let final_x = player_after.pos_x;
        let final_y = player_after.pos_y;

        assert(final_x == initial_x, 'X should not change');
        assert(final_y == initial_y - 1, 'Y should decrease by 1');
    }

    #[test]
    #[available_gas(300000000000)]
    fn test_attack() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);

        set_contract_address(world.contract_address);
        systems.config_system.dojo_init();
        set_contract_address(OWNER());

        let game_id = systems.game_system.create_game('player1');
        let mut game = store.get_game(game_id);
        assert(game.player_2_address.is_zero(), 'player 2 address not zero');

        let player_2_address = starknet::contract_address_const::<'ANYONE'>();
        set_contract_address(player_2_address);
        let result = systems.game_system.join_game('player2', game_id);
        assert(result, 'Should be able to join the game');

        game = store.get_game(game_id);
        assert(game.player_2_address == player_2_address, 'player 2 address not set');

        let mut player_1 = store.get_player(game_id, game.player_1_address);
        let mut player_2 = store.get_player(game_id, game.player_2_address);
        let initial_health = player_2.health;
        player_2.pos_x = player_1.pos_x + 1;
        player_2.pos_y = player_1.pos_y;

        set_contract_address(OWNER());
        store.set_player(player_2);

        // Attack player 2 from player 1
        systems.game_system.attack(game_id);

        let mut player_2_after = store.get_player(game_id, game.player_2_address);
        let mut player_1_after = store.get_player(game_id, game.player_1_address);
        assert(player_1_after.score > 0, 'Score should increase');
        assert(player_2_after.health < initial_health, 'Health should decrease');
    }
}
