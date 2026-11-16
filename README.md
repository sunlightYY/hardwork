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
- **Resentment** is never shown as a number at first. You read it from the light: pale blue / pink /
  green early on, deepening as it climbs, black at the top. Past a threshold the watch starts showing a
  percentage. The number of monsters follows the same scale.
- Shift swaps the world: coworkers and the supervisor vanish, monsters appear.
- Supervisor patrols with a vision cone. Get seen walking and he scolds you — workload goes up.
- Three tasks per day at your desk, day space only. Finishing them gives you `WORKING DONE`.
- Washing your face at the sink lowers resentment, with a cooldown.
- Getting touched by a monster drags you back to your desk and costs resentment.

## Assets

All visuals are drawn at runtime from primitives in `scripts/` — this is placeholder art, no external
asset files. Audio is not implemented yet.
If a build ever ships without redistributable assets, this section will list them.

## AI usage

AI assistance was used for code scaffolding and layout of this prototype. Final art, audio and design
decisions are human-made. See the itch.io submission for the full disclosure.

## License

TBD.
