local notify = require("notify").notify

local title = "zh2en"

local function info(msg)
  notify(msg, "info", {
    title = title,
  })
end

local function error(msg)
  notify(msg, "error", {
    title = title,
  })
end

local M = {
  info = info,
  error = error,
}

return M
