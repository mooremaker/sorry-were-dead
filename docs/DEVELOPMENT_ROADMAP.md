# Sorry We're Dead — Development Roadmap

## Current foundation — working now

- Godot 4.7.1 / GDScript / Compatibility renderer.
- 640×360 internal resolution with integer scaling.
- Press Start 2P global UI font.
- Sal movement: walk, sprint, crouch/sneak, jump.
- NoiseSystem and movement noise pulses.
- Zombie vision, hearing, investigate, chase, search, attacks.
- Player health and downed state.
- Zombie health and death.
- Pistol with ammo, reserve ammo, reload, damage, gunshot noise.
- HUD with health, stance, color-changing noise meter, ammo/reload, downed state.
- WorldClock and day/time HUD.
- ZombieDirector day-pressure foundation.
- Combat Lab area spawner with Day 1 population and replacement spawning.

## Milestone 1 — Combat sandbox

Goal: prove stealth and combat choices are fun.

- Test multi-zombie hearing behavior.
- Add visual/audio pistol feedback.
- Add muzzle flash and hit feedback.
- Add Pizza Cutter Glaive melee weapon.
- Add melee stamina/recovery tuning if needed.
- Add brief zombie visual memory to prevent sight flicker.
- Add knockdown/revive prototype.
- Add basic loot drops only if useful for testing.

## Milestone 2 — Inventory and interaction

Goal: give combat/scavenging a reason to exist.

- Interaction component (`E`).
- Item definitions.
- Personal inventory.
- Containers/storage.
- Pickup/drop/use.
- Basic crafting table (`Q`).
- A few prototype resources and recipes.

## Milestone 3 — First settlement block

Goal: stop living only in Combat Lab.

- Player home.
- Sal's Slices exterior/interior.
- Grocery store.
- Armory.
- Town stockpile.
- Small resident population.
- Connected side-scrolling sections.
- Basic map (`M`).

## Milestone 4 — One complete workday

Goal: prove the central game loop.

- JobSystem foundation.
- Sal's Slices shift.
- Customer/work tasks.
- Ingredient usage.
- Food output to customers/stockpile.
- Shift success/failure consequences.
- NPC schedules tied to WorldClock.
- Sleep and next-day transition.

## Milestone 5 — Survival needs

- Hunger.
- Thirst.
- Hygiene.
- Healing/recovery.
- Home food storage.
- Grocery purchases/distribution.
- Needs tuned to create choices without constant chores.

## Milestone 6 — First outside scavenging route

- Settlement exit.
- Gas station.
- Suburban section.
- Recoverable supplies.
- Increasing area danger.
- Airdrop prototype.
- Return/delivery to town systems.

## Milestone 7 — Living settlement simulation

- Community farms.
- Farm → grocery/business supply flow.
- Armory supply flow.
- Radio operator.
- Resident schedules.
- Relationships/friendship.
- Town shortages and gradual consequences.

## Milestone 8 — Multiplayer authority proof

Before broad multiplayer content:

- Host authoritative movement/actions where practical.
- Human takeover of persistent survivor.
- AI resumes when player leaves.
- Authoritative ammo/health/inventory test.
- Revive/downed multiplayer flow.
- Browser-compatible multiplayer transport research/prototype.

## Later expansions — intentionally deferred

- More professions.
- Advanced relationships, romance, marriage.
- Complex diseases.
- Vehicles.
- Weather/crops.
- Electricity.
- Pets.
- Large skill system.
- Advanced crafting.
- Procedural map systems.
- PvP.
- Larger multiplayer counts.

## Development rule

Do not implement a later expansion because it sounds cool if the current vertical slice is not fun yet.

**Priority question:** Does this make one day in the apocalypse more interesting?
