# Foundation 0.2.0 package notes

This package is built from the user's working August 8, 2026 Godot project and keeps the existing Combat Lab, ZombieDirector, WorldClock, HUD, crosshair, pistol, Pizza Cutter Glaive, and Press Start 2P theme reference.

## First test

1. Copy `PressStart2P-vaV7.ttf` from the existing working project into `art/ui/fonts/` before opening this clean package.
2. Open `project.godot` in Godot 4.7.x.
3. Open `scenes/world/combat_lab.tscn`.
4. Run Current Scene.
5. Confirm:
   - eight zombies are present initially;
   - crosshair and 360-degree pistol aim work;
   - shots show a tracer/muzzle flash;
   - damaged zombies flash/stagger/knock back;
   - F swings the Pizza Cutter Glaive and shows a temporary swing arc;
   - killed zombies fall/fade before being removed;
   - replacement zombies continue to spawn;
   - when Sal reaches 0 HP, the `SORRY WE'RE DEAD` screen appears;
   - `LOAD FROM LAST SAVE` restores the entry checkpoint;
   - `QUIT` exits the desktop build.

## Save-system scope

The current save is intentionally a checkpoint prototype, not the final persistent-world save format. It proves the failure/reload loop now while keeping the save architecture modular for inventory, needs, relationships, settlement state, jobs, world districts, containers, and multiplayer-owned survivors later.
