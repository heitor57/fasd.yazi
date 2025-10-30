fasd.yazi
=======================

A [**Yazi**](https://github.com/sxyazi/yazi) plugin that integrates with [**fasd**](https://github.com/clvv/fasd), allowing you to **open or navigate files and directories based on frequency and recency** — right from within Yazi.

This plugin contains mainly two actions:

*   **`open`** – Adds the current hovered file or directory to `fasd`'s database and opens it.
*   **`fzf`** – Opens a searchable `fzf` picker listing your most-used files and directories tracked by `fasd`.


⚙️ Installation
---------------

1.  Make sure you have both **fasd** and **fzf** installed:
    ```bash
    sudo apt install fasd fzf
    # or
    brew install fasd fzf
    ```
2.  Add this plugin to your Yazi plugin directory:
    ```bash
     ya pkg add heitor57/fasd
    ```


How It Works
---------------

*   Every time you open a file or enter a directory using this plugin, its path is added to `fasd`’s database via:
    ```bash
    fasd -A <path>
    ```
*   You can then recall frequently or recently visited items using an interactive **fzf** picker.


Usage
--------

Add keybindings in your Yazi `keymap.toml`:

```lua
{ on = "ç",        run = "plugin fasd fzf",  desc = "Search and open from Fasd using fzf" },
{ on = "<Enter>",  run = "plugin fasd open", desc = "Add to Fasd and open hovered item" },
{ on = "<Right>",  run = "plugin fasd open", desc = "Add to Fasd and open hovered item" },
{ on = "l",  run = "plugin fasd open", desc = "Add to Fasd and open hovered item" },
```

### Modes

| Mode | Command | Description |
| --- | --- | --- |
| `open` | `plugin fasd open` | Adds the hovered item to Fasd and opens it (directory or file). |
| `fzf` | `plugin fasd fzf` | Opens an FZF picker listing your most frequently/recently used items. |

