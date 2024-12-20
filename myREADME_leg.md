# Quickstart guidelines

## TODOs

- General
- [x] conform format line add key
- [x] local leader not working
- [x] telescope mapping not work - wrong key need to be inside default
- [x] zoxide setup - work now mimic other plugins
- [ ] fix font in md show strange when in i mode
- [ ] Override lsp config mapping properly
- [~] CX : cmp mapping C-space and more mapping config behavior <TAB> in comment check nvchad d (C-e to end (cancel))
- Git
  - [ ] Diff view : https://github.com/sindrets/diffview.nvim?tab=readme-ov-file
- Telescopes
  - [x] fzf search alike
        x [~] Lazygit and dotfiles : use present
    - https://github.com/jesseduffield/lazygit/discussions/1201#discussioncomment-2546527
    - enable file : https://github.com/kdheepak/lazygit.nvim/issues/22#issuecomment-1815426074
- LSP
  - jsx comment not correct
  - [x] Omnisharp dotnet setup

Migration idea

- [x] lazygit install
  - [ ] check tmux working
        [ ] fzf style search file ?
- [x] disable hardtime ?
- [x] keymap import before (not to conflict)
- [ ] Fugitive setup + git root support
- [x] Session save and start page correct
- [x] neotree key settings change filter not to change when type
- [x] check keymap lazygit configure : https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
  - at the end config always read from $HOME/.config/config.yml regardless of XDG_HOME so just copy there
  - understand how it extends : https://github.com/LazyVim/LazyVim/blob/eb6c9fb5784a8001c876203de174cd79e96bb637/lua/lazyvim/util/lazygit.lua#L51
- [x] zoxide setup
- [x] table format - auto format already handled
      ( [ ]Optional)
- [ ] git open branch url telescope
      Key maps
- [x] gx open link (+ plugin) + sometimes work in tmux ?
- [x] Key maps
  - [x] resize Windows
  - [x] Sessions saved
  - [x] tab change ( or use gT ? )
  - [x] custom Cds , and copy file - or not ?

## Configurations

### Examples

#### JellyDN:

- References: https://github.com/jellydn/lazy-nvim-ide?tab=readme-ov-file#try-with-docker

```sh
VOLUME=$(pwd)

docker run -w /root -it --rm -v $VOLUME:/root/mount alpine:latest sh -uelic '
  apk add git nodejs npm neovim ripgrep build-base make musl-dev go --update
  go install github.com/jesseduffield/lazygit@latest
  git clone https://github.com/jellydn/lazy-nvim-ide ~/.config/nvim
  nvim
'
```

Features

- CMD LINE
- nice interface and terminal
- Native lazy leveration with extras folder to toggle by user
- Folding pairs guideline
- Cleaner settings on telescope help see
- Find with Telescope f cleaner
- Testing (l-t) ?? - how it works ?
- inline diagnostics
- Notificaiton

Packages use

- mason-lsp
- toggleterm
- neo-tree
- mini{pairs,comment}
- flash ( jump and select scope (S-f-F))

## Keymaps Summary

### General Guideliens

Main lazy setup for plugins :
<leader>-s + h(elp), b(uffers), t(odos), c(ommands), k(eymaps), f(replace)

- s(symbols) / <leader>o Symbols {W,E toggle fold}
- telescope which-key (i = C-\_ or C-/)

<leader>-f + f(iles), b(uffers),c(config)
<leader>-g + g(it), b(lame), c(ommit), s(tatus)

- h => stage, diff

- gs - surround : replace, delete

<leader>-w + windows, splits, delete, move
<leader>-TAB + create / move tabs
<leader>-d => debug

Understand each plugin more: https://www.youtube.com/watch?v=6pAG3BHurdM&ab_channel=JoseanMartinez

## Keymaps

🤩 try to search the keys should already be there

### Hidden settings / keymaps

- i mode: calculator <C-r>=
- q: is disabled by default

- C+/ toggle terminal
  - Esc Esc = normal mode in terminal

### LSP

- install formatters via Mason
- enable on config
- enable format from lazy = <leader>fm

| Key              | Description                                     |
| ---------------- | ----------------------------------------------- |
| K + K            | see documents params + move to the popup window |
| visual:<C-space> | expand selection                                |
| gd               | See references                                  |
| [d and ]d        | Diagnostics Jump                                |
| [e and ]e        | Errors Jump                                     |
| <leader>ca       | Code action - to help fix                       |
| <leader>cA       | bulk file actions                               |

### Windows

| Key              | Description                                                                       |
| ---------------- | --------------------------------------------------------------------------------- |
| Esc-hl           | Resize screen                                                                     |
| <leader>h/v      | Split                                                                             |
| C-\ + C-n        | Terminal Normal Mode                                                              |
| C+/              | Toggle terminal ( <leader>t+. open split but usaully cause hang , can try :term ) |
| leader + b/w + d | Delete buffer / window                                                            |

### Navigations

gx - custom function to go to links or directly to github page plugin link

- for LSP navigations see below LSP map

#### Help Pages

- C-] go to tags - section (highlighted in red)
- C-t to go back to previous location tag

| Key             | Description                           |
| --------------- | ------------------------------------- |
| zj / k          | Navigate fold (useful in diff split ) |
| FLASH           | -----------                           |
| f/F/s           | search 1-back / 2                     |
| S               | search visual block jump              |
| vmode: , ; (+f) | search Quotes block                   |

Neo Tree

- Fix

CDs

| Key            | Description               |
| -------------- | ------------------------- |
| <leader>c.     | Change dir zoxide plugins |
| <localleader>c | Change dir current file   |

Config file settings / debug

| Key         | Description                  |
| ----------- | ---------------------------- |
| <local>rl   | include lua (check test.lua) |
| <leader>sna | open noice (messages) log    |

### Editing

| Key         | Description                          |
| ----------- | ------------------------------------ |
| C-s         | Save                                 |
| <ll> w      | Save                                 |
| Y, YY       | copy to system clipboard             |
| <ll> q      | Quit                                 |
| za/A        | fold toggle cursor / All             |
| zd          | fold delete                          |
| <leader> fm | Format whole file                    |
| <leader> fF | Toggle Format on Save Buff(!)/Global |

### Files

Find other files

- <leader>fp : select project + file in project
- <leader>fr : find recent open

Neo Tree

<leader-e> 
- h = help

- Custom actions
  - Ff => fzf find in node
  - Fg => fzf grep in node
  - Tf/Tg => telescope
  - TC,Tc => telescope cd / cd

## Others

#### Coding

Overseer - task manangement (leader + o)

- support and read ./.vscode/tasks.json by default
- can extend by https://github.com/stevearc/overseer.nvim/blob/master/doc/guides.md#custom-tasks
- rerun last task with <leader>>or

Hurl - HTTP client runner (leader + h)

https://github.com/jellydn/hurl.nvim?tab=readme-ov-file#swappable-environment
Set env file by

- uses `vars.env` relative or recursively to root project, can change using :HurlSetEnvFile (support mult use ,)

#### Refactoring

1. Telescope select with tab + C+Q > send to quicklist
2. :copen to see the list
3. :cfdo %s/old/new/g | update (use c flag substitude to make sure its correct)

`Markdown` - manual enable on md files table mode auto format when type the  
Tables plugin (manual enabled)

'Notes' : Key works per buffer
| Key | Description |
| ----------- | -------------- |
| <leader> tm | Enable |
| <leader> tc | Delete column |

### Replacing

Use nvim spectre

- sometimes in config file not see need to toggle hidden (I)
- <leader>+sF search + replace current word

- no undo
  Guide: basic cdo + spectre : https://www.youtube.com/watch?v=YzVmdJ41Xkg&ab_channel=AndrewCourter

### Searching

`Telescope` is main searching tools using <leader>f

| Key               | Description            |
| ----------------- | ---------------------- |
| \_ft              | Find Telescope pickers |
| quick fix history | (C-q) retrieve again   |
| \_ff              | Find Files             |
| \_fh              | Help Pages             |
| \_fb              | Buffers                |

| <leader>+s+t | search todos |
| - s+c | search commands |
| - s + k | search keymaps |

### Git

Telescope
| Key | Description |
| -------------- | ----------- |
| C-A-j/k | Next Hunk |
| ]c, [c | Next Hunk |
| <leader>gbc | See files |
| - enter | apply commit change to file |
| - split | compare |

Fugitive

Status View

| Key        | Description          |
| ---------- | -------------------- |
| <leader>gz | see git status       |
| = / > \ <  | expand toggle diff   |
| J/K        | next hunk            |
| I          | patch mode           |
| X          | discard under cursor |
| G          | Git Status           |

Commit / Files View - TODO OLD fugitive

| Key                  | Description                |
| -------------------- | -------------------------- |
| :Gclog               | See clean commit message   |
| :Gclog -- %          | see commit of currnt file  |
| g?                   | help                       |
| gq                   | quit blame / menu          |
| <leader> gb          | Git Blame                  |
| - l                  | Blame Line                 |
| - c                  | Blame commit Telescope     |
| - L                  | see commit with blame info |
| C                    | go to commit of the file   |
| <enter> / o / go / O | open file / split          |

---

| auto tag add support |
| md : table on save format | not pretty line auto like TD mode |

Coding
| Key | Description |
| ----- | ------|
| Comment | gc<kjh> gcc |
| Format | <leader>-cf |

### AI

#### ChatGPT

plugin: https://www.youtube.com/watch?v=jrFjtwm-R94&ab_channel=NerdSignals

- Act as (persona)
- Docs
- Chat Grammar correct Bug fixes, Explain

#### CodeCompanion

Pros:

- Support Tools calling and run docker (but might not setup deps correctly)
- Diff pane (only show when use with quick chat) acceptable / rejectable
  - but a bit weird to edit code sometimes not correct

Cons:

- when Toggle with visual does not Add context of selected to the chat like copilot chat

| Key          | Description                       |
| ------------ | --------------------------------- |
| <leader>A    | toggle commands                   |
| + A          | add selected code to chat         |
| + q          | Chat with input (select/deselect) |
| gy           | copy code section using gy        |
| ga           | accept diff code                  |
| gr           | reject diff code                  |
| chat /       | slash commands                    |
| chat @       | tools                             |
| -- MODIFY -- |                                   |
| + Q          | Chat with input (select/deselect) |

# copy code section using gy

#

#### Copilot

https://github.com/CopilotC-Nvim/CopilotChat.nvim

Copilot Chat

| Key            | Description                                       |
| -------------- | ------------------------------------------------- |
| <leader>a      | toggle commands                                   |
| - m/M          | get commit message from current diff / staged     |
| C-t            | overriden auto complete since default not working |
| <input> / or @ | /prompts or @context                              |
| <enter>        | continue question enter chat                      |

Code companion

| Key        | Description     |
| ---------- | --------------- |
| <leader> A | toggle commands |

## Keyboards

### Views

| Key          | Description                             |
| ------------ | --------------------------------------- |
| <esc>        | toggle fold if exists else no highlight |
| VIM DEFAULTS | ----------                              |
| <C-g>        | Show current file path                  |

## Old section

#### Files

Nvim Tree - TODO: Delete
| Key | Description |
| --- | ----------- |
| <C-n> | Toggle NvimTree |
| y | Copy file name (with ext) |
| ge | copy base name (no ext) |
| ------------- |
| Option 1 | use fzf-telescope (on v mode ? )|
| Option 2| telescope (can try this : https://github.com/nvim-telescope/telescope-fzf-native.nvim)

CDs

Nvim Tree - TODO: Delete

| Key           | Description                                                                            |
| ------------- | -------------------------------------------------------------------------------------- |
| <C-n>         | Toggle NvimTree                                                                        |
| y             | Copy file name (with ext)                                                              |
| ge            | copy base name (no ext)                                                                |
| ------------- |
| Option 1      | use fzf-telescope (on v mode ? )                                                       |
| Option 2      | telescope (can try this : https://github.com/nvim-telescope/telescope-fzf-native.nvim) |
