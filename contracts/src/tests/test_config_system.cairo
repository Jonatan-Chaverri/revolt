mod test_config_system {
    use revolt::systems::config_system::config_system;
    use revolt::tests::setup::{
        setup, setup::OWNER, setup::IDojoInitDispatcher, setup::IDojoInitDispatcherTrait
    };
    use revolt::store::{Store, StoreTrait};
    use starknet::testing::set_contract_address;

    #[test]
    #[available_gas(300000000000)]
    fn test_create_map() {
        let (world, systems) = setup::spawn_game();
        let mut store: Store = StoreTrait::new(world);

        set_contract_address(world.contract_address);
        systems.config_system.dojo_init();
        set_contract_address(OWNER());

        // Check the map exists
        let map = store.get_map(1);
        assert(map.rows > 0, 'Map 1 does not exists');
    }
}
