# Character Item Level

A tiny World of Warcraft addon that shows the item level in the top-left corner of each equipped item on your character screen, coloured by item quality. It does that and nothing else.

Built for the World of Warcraft Forever client (interface version `16001`).

## Features

- Item level shown on every equipped slot in the character frame (shirt and tabard are skipped, as they have no meaningful item level)
- Text coloured by item quality
- Updates when you change gear, and when item data finishes loading
- On/off checkbox in the AddOns settings page
- `/cil` slash command to toggle from chat
- Your choice is saved between sessions
- Errors are caught quietly, so a client mismatch won't spam you with popups

## Installation

1. Download this repository (green **Code** button, then **Download ZIP**) or clone it.
2. Make sure the folder is named exactly `CharacterItemLevel` (GitHub ZIPs usually add a suffix such as `-main`, so rename it if needed). It should contain `CharacterItemLevel.toc` and `CharacterItemLevel.lua`.
3. Place the folder in your client's AddOns directory:
   ```
   World of Warcraft/<client folder>/Interface/AddOns/CharacterItemLevel/
   ```
4. Start the game, or type `/reload` if it's already running.
5. Open your character panel (`C`) to see the item levels.

## Usage

| Action | How |
| --- | --- |
| Turn the labels on or off | Options, then AddOns, then **Character Item Level**, and tick or untick the checkbox |
| Toggle from chat | `/cil` |

## Troubleshooting

**The addon is listed as "out of date" or won't load.**
Your client's interface version may differ from the one in the `.toc` file. In-game, run:
```
/dump (select(4, GetBuildInfo()))
```
Then change the number on the `## Interface:` line in `CharacterItemLevel.toc` to match, and `/reload`. You can also tick **Load out of date AddOns** on the character select screen.

**An item level is missing on a slot.**
Hover the slot and run `/fstack` to see its frame name. If it isn't one of the standard `Character...Slot` names, open an issue and include the name.

**I see Lua errors.**
Enable error display with `/console scriptErrors 1` and include the error text in an issue.

**I want it off.**
Untick the checkbox in the settings page, use `/cil`, or disable the addon from the AddOns list on the character select screen.

## Contributing

Issues and pull requests are welcome. The addon is deliberately minimal, so changes that keep it small and focused are the best fit.

## License

Released under the [MIT License](LICENSE).
