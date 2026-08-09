# Sorry We're Dead — Quick Start

## Open the project

1. Extract this package to a normal development folder such as `C:\Dev\sorry-were-dead`.
2. Import/open `project.godot` in Godot 4.7.1 Standard.
3. Let Godot reimport assets if requested.
4. Open `scenes/world/combat_lab.tscn`.
5. Run Current Scene.

## Combat Lab controls

- A / D or arrows — move.
- Shift — sprint.
- C — crouch/sneak.
- Space — jump.
- Left mouse — pistol.
- R — reload.
- E — reserved interaction.
- F — reserved melee.
- Q — reserved crafting/workbench.
- M — reserved map.
- Tab / I — reserved inventory.
- Escape — pause input.

## Combat Lab expected behavior

- The HUD begins around Day 1, 6:00 AM and time advances.
- Several zombies spawn at the beginning of the test.
- Day 1 normal-area target is about 8 active infected, with about 6 initially present.
- Killed zombies are gradually replaced up to the area's current cap.
- Crouching is quiet, walking medium, sprinting loud.
- The HUD noise meter changes green/yellow/red.
- Gunshots create a large noise radius and can attract infected.
- Four pistol hits kill the current prototype zombie at default tuning.
- Running out of magazine ammo requires R to reload from reserve ammo.
- Zombies can damage Sal into a downed state.

## Important prototype note

Everything visual is intentionally temporary. Do not spend time polishing rectangles before the gameplay loop is proven.
