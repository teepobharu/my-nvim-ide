# Notes

## Todo

- [ ] Move common mappings outside and import before loading plugins (will help get base mappings before something might fail + extend to vanilla vim)

# Migrations

## TO Patch

Telescope-Lazy : Not work well when open root / git root

- separate mapping for non overlap telescope (use both telescope and fzf for now)
  Neotree: does not auto change dir of opened files

- see this https://github.com/LazyVim/LazyVim/discussions/2150
- [x] Lazygit : when press e on file does not open vim but open vscode

Some interesting changes

- fzf-lua instead of telescope
- use oil buffer-style file explorer
- Remove usage of LazyVim.nvim - extract out some utils into utils folder but still use Lazy.nvim

Features

- \_cp / \_cr (select) = open code pad (not work with lua - vim and require)

2024 ...

- disabled some plugins with disabled
- add custom script to add buffers and editable in copiot-chat

2024 Sep 22

- New Plugin
  - codecompanion - leader A
    - ? for help
    - type / for slash commands , @ to use tools
    - inline : ga gr
    - chat : ga (change model ollama worked with model selection default)
    - tools : execute in docker and auto resilent msg auto prompt fill
    - https://github.com/olimorris/codecompanion.nvim/blob/e7d931ae027f9fdca2bd7c53aa0a8d3f8d620256/doc/AGENTS.md
- Consolidated custom override into one file
- Added custom override project level and setup create keymap using ,rsn keymap
- Extras is disabled by default and

## Some issues

- [ ] Toggleterm size cannot be changes even persistence is set to false override on myEditor but nothing changes ?
