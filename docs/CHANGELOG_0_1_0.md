# Foundation 0.1.0 — Package Notes

This package was rebuilt from the user's uploaded working project rather than from an older template.

## Preserved working systems

- Sal movement and health/downed logic.
- Zombie perception/attack/health/death.
- NoiseSystem.
- Pistol shooting, ammo, reload, damage, gunshot noise.
- Player HUD.
- Press Start 2P project font.
- WorldClock and clock HUD.
- Windows/Web export configuration.

## Added/organized in this package

- `ZombieDirector` autoload.
- `ZombieSpawner` area component.
- Combat Lab now starts with a multi-zombie population and replaces killed infected.
- Day-based infected pressure tuning.
- Future runner/special pressure hooks without prematurely implementing those zombie types.
- Zombie AI script moved from `scenes/characters/` to `scripts/characters/` for clean code organization.
- Expanded game design, architecture, roadmap, and quick-start documentation.
- Reserved data folders for zombie types, areas, events, and balance.

## Default prototype infected pressure

- Day 1 normal-area max alive: 8.
- Day 1 initial population: 6.
- Day 1 replacement interval: 3.5 seconds.
- Population grows gradually toward a cap rather than increasing without limit.
- Replacement interval gradually decreases to a safe minimum.

These values are deliberately centralized and easy to tune in `scripts/systems/zombie_director.gd`.
