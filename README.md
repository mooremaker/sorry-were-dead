# Sorry We're Dead — Foundation 0.1.0

This package is the current organized Godot foundation for **Sorry We're Dead**, rebuilt from the working project uploaded on August 8, 2026.

## Game direction

A 2D pixel-art side-scrolling zombie survival game set in a living fortified settlement outside New York City.

The first survivor, Sal, works at **Sal's Slices** while farms, grocery distribution, the armory, radio operations, the town stockpile, homes, survival needs, relationships, and dangerous scavenging routes create an interdependent settlement.

Solo play is intended to use AI-controlled persistent worker-survivors. Multiplayer will let humans take control of those same survivors and return control to AI when they leave.

## Current playable prototype

Open and run:

`scenes/world/combat_lab.tscn`

Working foundation includes:

- Sal walking, sprinting, crouching, jumping.
- Stealth/noise pulses.
- Zombie hearing, sight, investigation, chase, search, attacks.
- Player health/downed state.
- Zombie health/death.
- Pistol, ammo, reload, damage, gunshot noise.
- Pixel-font HUD with health, stance, green/yellow/red noise meter, ammo, reload and clock.
- WorldClock.
- ZombieDirector day-based pressure.
- Area ZombieSpawner with multiple starting infected and replacement spawning.

## Default Combat Lab pressure

Day 1 currently targets about **8 active zombies**, with **6 initially spawned**, then replacements over time after kills.

These are prototype balance values, centralized in:

`scripts/systems/zombie_director.gd`

## Technical direction

- Godot 4.7.1 Standard.
- GDScript.
- Compatibility renderer.
- 640×360 internal pixel-art canvas.
- 1280×720 development window override.
- Integer scaling / nearest filtering.
- Press Start 2P global UI font.
- Server-authoritative multiplayer architecture target.
- Browser + Windows first.
- Linux / Raspberry Pi ARM64 planned.
- Mobile landscape planned later.

## Read next

- `docs/QUICK_START.md`
- `docs/GAME_DESIGN.md`
- `docs/TECHNICAL_ARCHITECTURE.md`
- `docs/DEVELOPMENT_ROADMAP.md`
- `docs/CHANGELOG_0_1_0.md`

## Development rule

Do not begin by implementing every planned feature.

Our first real proof remains:

**Can one complete day in this apocalypse be fun?**
