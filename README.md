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
| A / D (or ← / →) | Stand up at the start — after that you keep running right on your own |
| **Shift** | Switch space. Every switch sends items crashing down around you |
| E | Hand the item you are carrying to the person blocking the way |

## What is in the build

- A single office floor shown as a facade cross-section, and 28 floors to get through.
- You run right automatically. A colleague stands in the way and wants one specific thing —
  the bubble over their head shows which.
- Switching space costs resentment and drops three items: boxing gloves, playing cards, work
  documents. You pick up whatever lands within reach, so you may have to switch again to re-roll.
- Hand over the right item and they step aside; reach the far end of the floor and you drop to the
  next one. Floor 28 down to floor 1.
- Resentment still drives the light: pale blue / pink / green early on, deepening towards black.
  Past a threshold the watch starts showing a percentage.

## Assets

The room backdrop is `assets/art/room.png`, downscaled from the reference illustration to 1280×720.
The floor band, the sliver of the floor above and the ceiling lights of the floor below all come from
that image.

Character art is currently placeholder and will be redrawn. Spec: [docs/character-art.md](docs/character-art.md).

The older placeholder sheets can be regenerated from Aseprite by a Lua script:

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
