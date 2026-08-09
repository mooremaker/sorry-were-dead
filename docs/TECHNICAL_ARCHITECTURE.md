# Sorry We're Dead — Technical Architecture

## Engine and presentation

- Godot 4.7.1 Standard.
- GDScript.
- Compatibility renderer.
- Internal viewport: 640×360.
- Window test override: 1280×720.
- Integer viewport scaling.
- Nearest texture filtering.
- Press Start 2P configured as the project custom font.

## Global/autoload systems currently active

### NoiseSystem

Broadcasts noise events containing position, radius, and source. Zombies listen and decide whether to investigate.

This system should remain generic so footsteps, guns, glass, alarms, generators, vehicles, thrown objects, and future world interactions all use the same interface.

### WorldClock

Owns authoritative game day/hour/minute state and emits minute/hour/day signals.

Current pacing target is 0.30 game minutes per real second, producing roughly 60 real minutes between 6:00 AM and midnight.

### ZombieDirector

Owns broad infected pressure tuning rather than individual zombie AI.

It currently calculates:

- Maximum active infected for a normal dangerous area.
- Initial population.
- Replacement spawn interval.
- Future runner/special pressure hooks.

Area spawners query the director and may apply local multipliers/overrides.

## Area spawning architecture

`ZombieSpawner` belongs to a world area/scene.

Responsibilities:

- Know spawn markers for that area.
- Ask ZombieDirector how much pressure the current day should have.
- Spawn the initial local population.
- Replace killed infected over time up to the current cap.
- Prefer spawn points away from the nearest survivor.

It should **not** decide global story difficulty or zombie AI behavior.

Future area examples can use different multipliers:

- Settlement interior: near zero under normal conditions.
- Suburbs: normal pressure.
- Downtown: high pressure.
- Special horde event: temporary override.

## Character structure

Character gameplay and visual presentation remain separated.

Example:

```
Sal (CharacterBody2D)
├── CollisionShape2D
├── Visuals
│   └── placeholder/final visual
├── WeaponSocket
│   └── equipped weapon
└── Camera2D
```

Final sprites should replace children under `Visuals` rather than rewriting movement/combat code.

## Weapon structure

Weapons are independent scenes attached to a survivor weapon socket.

Current pistol owns:

- Damage.
- Range.
- Magazine size.
- Reserve ammunition.
- Fire cooldown.
- Reload time.
- Hitscan RayCast2D.
- Gunshot NoiseSystem emission.

The character asks the equipped weapon to fire/reload. Future inventory/equipment systems should eventually remove the hard-coded pistol reference from Sal and HUD.

## HUD architecture

The HUD currently reads prototype survivor and pistol state directly. This is acceptable for the current single-player Combat Lab.

Before multiplayer, replace "first survivor in group" lookup with an explicit local-player/survivor reference so each client observes the correct character.

## Persistent survivor architecture target

A persistent survivor should eventually contain:

1. Character state/data.
2. A controller interface.
3. AI controller or human controller.

Multiplayer joining swaps control source instead of creating a different character identity.

## Server authority target

Clients request actions. Authority validates and commits them.

Examples:

- Fire weapon request → authority checks weapon, ammo, cooldown, survivor state → resolves hit → decrements ammo.
- Move item request → authority verifies container, ownership/access, quantity → performs transfer.
- Complete work task request → authority validates location/task/state → applies job progress.

Never accept persistent values such as health/ammo/money/inventory directly from an untrusted client.

## Data-driven direction

The `data/` folders are reserved for definitions and balance data as systems mature:

- items
- jobs
- recipes
- survivors
- weapons
- zombie_types
- areas
- events
- balance

Do not create a giant data framework before concrete gameplay requires it. Introduce Resources or JSON-style data incrementally as systems prove themselves.

## Naming conventions

Files: lowercase snake_case.

Examples:

- `player_hud.tscn`
- `zombie_ai.gd`
- `world_clock.gd`

Scene node names: readable PascalCase.

Examples:

- `PlayerHud`
- `StatusPanel`
- `ZombieSpawner`

This avoids Windows/Web/Linux case-sensitivity problems.
