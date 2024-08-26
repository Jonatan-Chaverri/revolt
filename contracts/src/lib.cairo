mod systems {
    mod game_system;
    mod config_system;
}

mod models {
    mod tile;
    mod map;
    mod game;
    mod player;
}

mod utils {
    mod dungeon;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_config_system;
    mod test_game_system;
}

mod store;