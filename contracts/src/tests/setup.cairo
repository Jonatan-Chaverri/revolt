mod setup {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    use revolt::systems::config_system::config_system;
    use revolt::models::tile::tile;
    use revolt::models::map::map;
    use revolt::models::game::game;
    use revolt::models::player::player;
    use revolt::systems::game_system::{game_system, IGameSystemDispatcher};

    use starknet::ContractAddress;
    use starknet::testing::set_contract_address;

    fn OWNER() -> ContractAddress {
        starknet::contract_address_const::<0x0>()
    }

    #[starknet::interface]
    trait IDojoInit<ContractState> {
        fn dojo_init(self: @ContractState);
    }

    #[derive(Drop)]
    struct Systems {
        config_system: IDojoInitDispatcher,
        game_system: IGameSystemDispatcher
    }

    fn spawn_game() -> (IWorldDispatcher, Systems) {
        let mut models = array![
            game::TEST_CLASS_HASH,
            tile::TEST_CLASS_HASH,
            map::TEST_CLASS_HASH,
            player::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(["revolt"].span(), models.span());
        let systems = Systems {
            config_system: IDojoInitDispatcher {
                contract_address: world
                    .deploy_contract('config_system', config_system::TEST_CLASS_HASH.try_into().unwrap(),)
            },
            game_system: IGameSystemDispatcher {
                contract_address: world
                    .deploy_contract('game_system', game_system::TEST_CLASS_HASH.try_into().unwrap(),)
            }
        };
        world.grant_writer(dojo::utils::bytearray_hash(@"revolt"), systems.config_system.contract_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"revolt"), systems.game_system.contract_address);
        set_contract_address(OWNER());
        (world, systems)
    }
}
