# Sorry We're Dead — Game Design Foundation

## High concept

**Sorry We're Dead** is a 2D pixel-art side-scrolling zombie survival game about keeping a small fortified settlement alive outside New York City.

The apocalypse is not only a combat problem. The town has jobs, food, stores, farms, homes, social relationships, schedules, limited supplies, and people who depend on one another. The player is one survivor inside that system, not a detached hero standing above it.

The first playable survivor is **Sal**, who works at and helps operate **Sal's Slices**, the settlement pizzeria.

The design goal is simple:

> Make one complete day in the apocalypse fun before making the world enormous.

## Core player fantasy

A good day should force competing priorities:

- Show up for work because the town needs food.
- Eat, drink, stay clean, and recover from injuries.
- Decide whether to spend money or supplies now or save them.
- Maintain a home and personal stockpile.
- Help friends and build relationships.
- Scavenge outside the walls for things the settlement cannot produce.
- Choose quiet, risky combat or loud, safer combat.
- Get home before the world becomes more dangerous.

The player should regularly think, "I do not have enough time to do everything today. What matters most?"

## Day rhythm

Initial pacing target:

- Wake around 6:00 AM.
- One waking day is roughly 60 real minutes from morning to midnight.
- A six-hour work shift is roughly 20 real minutes.
- The rest of the day belongs to survival, relationships, errands, exploration, crafting, and emergencies.

The WorldClock is the shared authority for schedules and day progression.

### Example day

- 6:00 AM — wake, eat, check supplies.
- Morning — errands, gardening, social time, preparation.
- 9:00 AM to 3:00 PM — Sal's Slices shift.
- Afternoon — shopping, home tasks, crafting, settlement work.
- Evening — scavenging, missions, friendships, repairs.
- Night — greater danger and pressure.
- Sleep — advance to the next day.

The exact schedule remains tunable. No major system should hard-code a particular hour unless the data for that job/event requires it.

## Settlement simulation

The settlement is an interdependent economy rather than a collection of decorative shops.

### Important locations and jobs

**Sal's Slices**
- Serves residents.
- Uses ingredients supplied through the town economy.
- Produces food for customers and potentially the communal stockpile.
- Work performance affects town food security and morale.

**Community farms**
- Produce serious settlement-scale food.
- Feed the grocery and food businesses.
- Can be affected later by weather, labor, water, disease, and damage.

**Grocery store**
- Distributes farm production and recovered food.
- Supplies households and businesses.

**Armory**
- Stores and sells firearms, ammunition, and defensive equipment.
- Receives rare supplies from scavenging and airdrops.

**Radio station/operator**
- Detects, requests, or coordinates airdrops.
- Can provide warnings and mission information.

**Town stockpile**
- Shared strategic reserve.
- Food, medicine, ammunition, building materials, and emergency supplies can flow into it.
- Shortages should create gradual consequences, not instantly destroy a save.

### Personal vs communal resources

Survivors should have both:

- Personal food/items stored at home or carried.
- Shared settlement supplies.

This creates useful tension between self-preservation and community survival.

## Needs

The planned core needs are:

- Health
- Hunger
- Thirst
- Hygiene

Hygiene should have meaningful but non-tedious consequences:

- NPC reactions and social effects.
- Increased infection risk from wounds when filthy.
- Reduced morale.
- Visual grime/flies at severe levels.
- Slower healing or other recovery penalties.

Needs should create decisions, not constant meter babysitting.

## Combat and stealth

Combat should reward avoiding unnecessary fights.

### Noise

The existing NoiseSystem is a foundational mechanic.

Examples of escalating noise sources:

- Crouch movement — quiet.
- Walking — moderate.
- Sprinting — loud.
- Melee impacts — localized.
- Doors, broken glass, thrown objects — situational.
- Firearms — very loud.
- Alarms, generators, vehicles — potentially massive.

Zombies investigate the *location of the sound*. They should not magically know the player's exact location unless they see the survivor.

### Vision

Zombie perception combines:

- Facing/head direction.
- Distance.
- Vertical limits.
- Raycast line-of-sight.
- Close-range awareness.

Future additions may include lighting and visibility modifiers.

### Weapons

Current prototype:

- Pistol
- Magazine and reserve ammunition
- Reloading
- Hitscan raycast
- Gunshot noise

Near-term planned weapon:

**Pizza Cutter Glaive** — an improvised pizza cutter mounted on a pole. It provides a quieter melee alternative and reinforces the game's identity.

The intended combat question is often:

> Do I risk getting close quietly, or use a gun and attract more infected?

## Zombie pressure and progression

The game should begin with meaningful zombie presence. Day 1 is not a tutorial world with only one or two infected.

Current normal dangerous-area prototype target:

- Day 1 max alive: about 8.
- Day 1 starting population: about 6.
- Killed infected are gradually replaced.
- Later days increase simultaneous population and replacement pressure.

The new `ZombieDirector` centralizes this scaling.

Difficulty should not come mainly from giant health bars. Progression should come from:

- More simultaneous infected.
- Faster replacement pressure.
- Larger groups.
- Dangerous nighttime modifiers.
- New zombie behaviors/types.
- Special events and hordes.

Future type progression can include:

- Standard shamblers.
- Tough infected.
- Runners.
- Crawlers.
- Armored variants.
- Rare special infected.

The director already exposes future runner/special pressure hooks, but only the standard zombie is implemented today.

## World structure

The world is a network of connected 2D side-scrolling districts rather than one giant seamless plane.

Example progression:

Settlement → gas station → suburbs → highway/woods → shopping center/farm road → downtown

Side exits may connect to different destinations.

The map (`M`) should eventually show:

- Known locations.
- Route connections.
- Danger zones.
- Objectives and airdrops.
- Unknown/unexplored areas.
- Blocked routes.

Safer areas should physically connect to increasingly dangerous areas so travel itself matters.

## Airdrops and scavenging

Airdrops are dangerous recovery opportunities, not free loot menus.

Possible flow:

Radio operator detects or requests a drop → map marks the area → survivors travel outside the walls → fight/avoid infected → recover supplies → deliver them to the appropriate town system.

Recovered goods can support grocery, armory, medicine, construction, or town stockpiles.

## Homes and personal life

Every persistent survivor should have a home.

Homes can eventually support:

- Personal food/items.
- Decoration/customization.
- Sleep.
- Hygiene.
- Crafting/storage.
- Relationships and social visits.
- Backyard gardens for personal self-sufficiency.

Backyard gardens should supplement personal needs, while community farms remain the serious settlement-scale food source.

## Relationships and residents

Two broad character categories are planned.

### Worker-survivors

- Hold jobs that affect settlement systems.
- Persistent characters.
- AI controlled in solo play.
- Can be taken over by human players in multiplayer.

### Resident NPCs

- Social, story, or service characters.
- Have schedules and relationships.
- May support friendship, romance, and marriage later.
- Do not all need to become playable multiplayer characters.

Human multiplayer should take control of an existing persistent worker-survivor rather than spawning a disconnected avatar. When the player leaves, AI resumes control.

## Death and failure

No default campaign permadeath.

**Multiplayer**
- Survivors enter a downed state.
- Teammates can eventually revive them.
- Failure can lead to injury/rescue consequences instead of deleting the character.

**Solo**
- A fatal state can show `SORRY WE'RE DEAD`.
- Reload a recent autosave/checkpoint.

Failure should hurt, but not routinely erase hours of progress.

## Multiplayer direction

Initial target: 1–4 players, with architecture that does not rule out more later.

The simulation is intended to be server-authoritative:

- Clients request actions.
- Server validates state and resources.
- Server applies authoritative results.

Do not trust clients to declare health, ammo, inventory, money, job completion, crop yields, or other persistent state.

Browser and Windows are first targets. Linux/Raspberry Pi ARM64 and mobile landscape are later targets.

## Art direction

Current visuals are intentionally placeholders.

Rules:

- Pixel-art presentation.
- 640×360 internal canvas.
- Integer scaling.
- Nearest texture filtering.
- Press Start 2P is the current UI font.
- Gameplay nodes and visuals remain separated so final sprites can replace prototype rectangles without rewriting logic.

## First vertical slice

The first meaningful vertical slice should prove a complete day:

1. Wake at home.
2. Manage basic needs.
3. Travel through the settlement.
4. Complete a Sal's Slices work shift.
5. Interact with at least a few residents.
6. Choose an optional scavenging objective.
7. Fight or sneak around infected.
8. Bring resources home/town.
9. Make at least one meaningful personal vs community resource decision.
10. Sleep and advance to the next day.

Only after this loop is fun should the game aggressively expand into vehicles, advanced disease, huge crafting trees, weather, electricity, pets, procedural content, or other large systems.
