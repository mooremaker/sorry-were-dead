# Sorry We're Dead — Architecture Rules

These rules exist so future features can be added without rewriting the entire game.

## Core principle

The **settlement simulation is authoritative**. A human player is one possible controller for a survivor; AI is another. The survivor itself should not care whether its decisions came from a keyboard, controller, mobile UI, or NPC brain.

## Systems we are planning around

- `NeedsSystem` — health, hunger, thirst, hygiene.
- `JobSystem` — shifts, work tasks, completion, town consequences.
- `InventorySystem` — personal, business, household, and town stockpile inventories.
- `EconomySystem` — farms → grocery → businesses → survivors.
- `CombatSystem` — firearms, melee, improvised weapons, damage, knockdowns.
- `RelationshipSystem` — friendship, hostility, romance, marriage later.
- `NPCScheduleSystem` — work, home, social routines.
- `EventDirector` — hordes, airdrops, shortages, emergencies.
- `WorldClock` — day pacing and schedules.
- `SaveSystem` — frequent autosaves and restore points.
- `NetworkAuthority` — validates multiplayer actions and owns simulation truth.
- Future modules: vehicles, weather, electricity, pets, disease depth, skills.

## Dependency rule

Gameplay scenes should not directly manipulate unrelated systems.

Example:
- Sal's Slices does **not** directly change farm crop variables.
- It requests ingredients from inventory/economy systems.
- Economy consequences propagate through shared data.

That keeps businesses modular.

## Multiplayer rule

Clients request actions.
The server validates and applies them.

Examples:
- Client: "I fired weapon X toward Y."
- Server: checks ammo/cooldown/state and resolves the shot.
- Client: "I put 3 pizzas into town stockpile."
- Server: validates ownership/location/items and updates the stockpile.

We do not trust the client to declare health, ammo, money, inventory, crop yield, relationship score, or completed work.

## Playable survivor rule

A survivor has:
1. Persistent character state.
2. A controller interface.
3. Either an AI controller or player controller.

Joining multiplayer should replace the AI controller — not replace the character.

## NPC categories

**Worker-survivors**
- Can be controlled by AI or human players.
- Hold jobs that materially affect settlement systems.

**Resident NPCs**
- Primarily social/story/service characters.
- Can have relationships, romance, marriage, quests, schedules.
- Do not need to be selectable multiplayer avatars.

Some characters may eventually support both roles.

## Save/death rule

No campaign permadeath by default.

Multiplayer:
- Knocked-down survivors can be revived.
- If recovery fails, use an injury/rescue consequence rather than deleting the character.

Solo:
- A fatal state may show the `SORRY WE'RE DEAD` failure screen.
- Reload a recent autosave/checkpoint.
- Autosaves should be frequent enough to make challenge meaningful without wasting huge amounts of time.

## Pacing targets

Initial tuning target:
- Approximate waking day: 60 real minutes.
- Required work shift: approximately 20 real minutes.
- Remaining time: personal needs, relationships, house work, shopping, crafting, farming/garden, missions, and emergencies.

These are data/tuning values and must not be hard-coded throughout gameplay code.
