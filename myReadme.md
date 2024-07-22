# Notes

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

- _cp / _cr (select) = open code pad (not work with lua - vim and require)

