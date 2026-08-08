# Step 1 Checklist — Foundation 0.0.2

## First boot
1. Use Godot 4.7.1 Standard.
2. Import this project's `project.godot`.
3. Confirm the editor opens.
4. Run the boot scene.

## Why 0.0.2
The first package tried to pre-populate too many editor settings directly in
`project.godot`. This revision keeps that file intentionally minimal and lets
Godot save those settings itself.

## After the first successful boot
We will configure, from inside Godot:
- Compatibility renderer confirmation
- 640x360 internal resolution
- stretch settings
- pixel texture filtering
- keyboard/mouse Input Map
- controller Input Map
- Windows export
- Web export
- Git

This is safer than trying to serialize all of those editor-owned settings before
the project has ever been opened.
