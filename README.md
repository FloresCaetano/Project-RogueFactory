# AeroFactory

A 3D logistics/automation sandbox built in Godot 4, in the spirit of Factorio-style base-builders: place conveyor belts, ovens, turrets and other machines on a grid, and watch items flow between them — all while the base itself is being assembled and flown as a spaceship.

## Core Systems

- **Grid-based building** — a dedicated `SpaceshipBuildingCamera` free-fly mode lets the player place parts on a `GridMap`, previewing valid/invalid placement with distinct materials (`valid_build.tres` / `invalid_build.tres`) before confirming.
- **Self-connecting conveyor belts** — `straight_belt.gd` / `curve_belt.gd` use raycasts on each side of a belt to detect neighboring belts and validate the connection direction (`front-back`, `left-right`, etc.) automatically, so belts snap into a working line without manual wiring.
- **Machines** — ovens, turrets and a building terminal are implemented as specialized subclasses of a shared `machines.gd` base, each exposing its own `check_behavior()` for how it reacts to being targeted for building/interaction.
- **Item flow** — items (e.g. `coal_test`) ride belts as physics bodies (`RigidBody3D`) moved along `PathFollow3D` curves rather than being teleported between slots, so belt speed and curve shape directly affect movement.
- **Persistence** — a global save system (`GLOBAL.gd`) serializes player position and placed buildings to a user save file on exit, and restores them on load.
- **Interaction handling** — a shared `InteractionHandler` / mouse raycast pipeline separates "what am I looking at" from "what can I do with it," reused across building and machine interaction.

## Requirements

- Engine: Godot 4.x
- Open the project root from the Godot Project Manager.
