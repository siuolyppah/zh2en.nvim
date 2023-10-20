# import by Lazy.nvim

```lua
local function translate() require("zh2en").translate_current_selection() end

return {
  "siuolyppah/zh2en.nvim",
  lazy = false,
  keys = {
    {
      "<leader>t",
      translate,
      mode = { "x" },
      desc = "test my plugin",
    },
  },
  dependencies = { "rcarriga/nvim-notify" },
}
```
