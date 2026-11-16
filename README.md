# hardwork

A game made for [GitHub Game Off 2026](https://itch.io/jam/game-off-2026), theme: **SHIFT**.

You are an office worker on the 28th-floor payroll of a building that does not want to let you go.
Your watch has one button. Press it and the floor empties out — the lights go blue, pink, green, and
something else starts walking the aisles.

Design notes: [docs/design.md](docs/design.md)

## Status

Playable single-floor prototype. No win condition yet — the loop is work, shift, survive, repeat.

## Run from source

1. Install [Godot 4.7](https://godotengine.org/download) (standard build, no C# needed).
2. Open `project.godot` in the editor, or from a terminal:

   ```sh
   godot --path .
   ```

## Controls

| Input | Action |
|---|---|
| Arrow keys / WASD | Choose a direction — you keep walking until you pick another one, get blocked, or crouch |
| **Shift** | Switch space (day ⇄ night) |
| Ctrl / C (hold) | Crouch: stops you and keeps the supervisor from noticing you |
| E | Interact (work at your desk, splash water on your face) |

The game opens with you sitting at your desk, staring at nothing. Press A or D to stand up and start.

## What is in the build

- One floor: cubicles, aisles, a corner, a sink, your own desk (the white one).
- Opening beat: seated, spaced out — the watch clicks on its own and the floor flickers into the night
  space once before you get control.
- Auto-walk movement, crouch, and a drone-style camera that trails you with a slight sway.
- Corner camera: turn 90° and the drone swings a little around the building — the floor tilts, pulls
  back, and settles flat again. Outside the floor is the building's dark exterior.
- **Resentment** is never shown as a number at first. You read it from the light: pale blue / pink /
  green early on, deepening as it climbs, black at the top. Past a threshold the watch starts showing a
  percentage. The number of monsters follows the same scale.
- Shift swaps the world: coworkers and the supervisor vanish, monsters appear.
- Supervisor patrols with a vision cone. Get seen walking and he scolds you — workload goes up.
- Three tasks per day at your desk, day space only. Finishing them gives you `WORKING DONE`.
- Washing your face at the sink lowers resentment, with a cooldown.
- Getting touched by a monster drags you back to your desk and costs resentment.

## Assets

Character art is generated from Aseprite by a Lua script:

```sh
aseprite -b --script tools/gen_sprites.lua
```

It writes `assets/art/player.png`, `coworker.png` and `supervisor.png` — each a 144×240 sheet of
48×48 cells: four directions × (idle, walk1, walk2) plus a seated row. Edit the palettes or the shape
functions in the script and re-run; the game picks the sheets up by name.

The office itself (desks, walls, floor) is still drawn at runtime from primitives in `scripts/level.gd`.
Audio is not implemented yet.

## AI usage

AI assistance was used for code scaffolding and layout of this prototype. Final art, audio and design
decisions are human-made. See the itch.io submission for the full disclosure.

## License

TBD.
