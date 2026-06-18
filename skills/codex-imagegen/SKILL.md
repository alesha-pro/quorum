---
name: codex-imagegen
description: Generate images using Codex CLI's built-in image generation. Use when the user wants to create visual assets (sprites, icons, illustrations, mockups, game assets, UI elements) via the terminal. Wraps `codex exec` to delegate image generation to Codex, which has native access to the imagegen system skill.
---

# codex-imagegen — image generation via Codex

Delegate image generation to the **Codex CLI**, which has a native `imagegen` system skill (the `image_gen` tool) and can write bitmap assets — sprites, icons, illustrations, game assets, transparent PNGs — directly to disk. Useful when the host agent has no image-generation tool of its own.

> Supplementary skill. It depends entirely on Codex's own imagegen capability, so it lives alongside the core review skills rather than being one of them.

## When to use
- The user asks to generate/create an image, sprite, icon, illustration, or visual asset.
- Pixel art, game assets, UI mockups, transparent backgrounds.
- Image generation is wanted but no native `image_gen` tool is available in the current environment.

## When NOT to use
- A native image-generation tool is already available.
- The asset is better as code (SVG, HTML/CSS).
- The task is editing existing local images.

## Prerequisites
- `codex` CLI installed and authenticated (`codex --version`).

## Usage

```bash
codex exec "Generate <description> and save it to <path>"
```

Always specify an **exact save path**. Example:

```bash
codex exec "Generate a pixel art health potion sprite (32x32, transparent background) and save it to ./assets/potion.png"
```

### Useful flags
- `-o result.txt` — capture Codex's final message (the image is still written to the path named in the prompt).
- `-i ref.png` — attach a reference image for style consistency (repeatable).
- `-C <dir>` — set the working directory; `--skip-git-repo-check` — run outside a git repo.
- `-m <model>` — pick a model for higher-quality work.
- Background it (`... &`, or in Claude Code `run_in_background: true`) for batches; check the log or just verify the files exist.

### Good prompt structure
Be specific about size, style, format, palette, and the exact save path:

```bash
codex exec "Generate a game asset:
- Type: magic scroll item sprite
- Style: pixel art, 16-bit
- Size: 32x32, transparent background, PNG
- Palette: limited 16 colors
- Save to: ./assets/items/scroll-magic.png"
```

### Batch / sets
```bash
codex exec "Generate 5 pixel-art item sprites (sword, shield, potion, coin, key), 32x32, transparent PNG, and save them to ./assets/items/ as sword.png, shield.png, etc."
```

## Validate the output
After generation, verify the files:

```bash
ls -lh ./assets/sprite.png                              # exists?
file ./assets/sprite.png                                # valid PNG?
sips -g pixelWidth -g pixelHeight ./assets/sprite.png   # dimensions (macOS)
```

## Troubleshooting
- **Fails:** confirm Codex is installed/authenticated (`codex --version`); ensure the target dir exists (`mkdir -p`); try a simpler prompt; add `--json` to see structured errors.
- **Poor quality:** be more specific (style, size, detail), provide a reference with `-i`, or try a stronger model with `-m`.

## References
- Codex imagegen system skill: `~/.codex/skills/.system/imagegen/SKILL.md`
- `codex exec --help`
