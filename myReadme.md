# Notes

## Todo

- [ ] Move common mappings outside and import before loading plugins (will help get base mappings before something might fail + extend to vanilla vim)
- [ ] Neotree auto cd wrong dir https://github.com/LazyVim/LazyVim/discussions/952#discussioncomment-6249577
- [ ] Avante add file context is nv2lzy instead of currrent dir

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

### 2025 13 Mar

🎊 Major

- **Snacks** - search replacement, git browse open, search windows actions : edit on search
- Blink - cmp relplacement
- LSPSaga - keymap changes
- snacks instead of fzf-lua (Help key with ?)
  - support filter with file:.lua
  - file EXPLORER
    - open terminal C-T
    - grep inner scope when CD (c-c) + grep with <space> /
- move myeditor override after extra plugins
- tab UI changes

🔧 Adjustment

- bakup keys s,f,g,e -> S,F,G (Fzf) ,E (neotree)
- add overriden extras to be on top of snacks : fzf-lua, neotree, toggleterm

⌨️ Keys
C\_ - toggle term
ft - snacks term
sr - resume from fzf - fr
fp - open new project dir not file in that project anymore
snacks panel

- a-w : switch window can edit in preview

🚫 Not supported, Dropped Features

- Snacks: git bcommits
  - search in buffers (Sb)
  - terminal - lack prior custom shortcut to send visual
  - explorer snacks copy no autocomplete and require manual type (neotree more convenient + support custom cmd in search within dir)

🔥 Issues

- [ ] Lazygit not load profile + open in vscode instead of vim
- [ ] Toggleterm also toggle snacks and override snacks terminal
- [x] Git browse
  - open git (file open only works in github , custom domain only open proj)
- someimtes toggleterm load before / fater snacks (since its lazy it will activate after some keys)
- error cursor autocommands and textchanged : disable blink
- error import touble esnacks : disable line
- why fzf override snacks ?
  - cannot have nil or empty {} obj inside key settings
  - add enabled extras plugin for fzf-lua after also override the key for snacks

🐛 Debugging

- see lazy Debug (which key is pending lazy) - sometimes toggleterm not appear here even put it as enabled plugin at last

> sample issue key not shown for fzf

```lua
 -- NOT WORKING
 -- this made key in fzf not available
{
      not isSnackEnabled and {
        "<C-e>",
        function()
          local root_dir = require("utils.root").get()
          require("fzf-lua").files({
            cwd = root_dir,
            cwd_prompt = false,
          })
        end,
        desc = "Find Files at project directory",
      } or {},
},
 -- Working
{
  not isSnackEnabled and "<C-e>" or "<localleader><C-e>",
}

```

Resolved

- fix keymap jk escape

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
