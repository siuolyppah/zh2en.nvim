local bin_path = "zh2en-translate"
local rust_job_id = nil

--- start rust job. should be called when neovim start.
local function rpc_init()
  if rust_job_id ~= nil then
    return rust_job_id
  else
    local return_job_id = vim.fn.jobstart({ bin_path }, { rpc = true })
    if return_job_id == 0 then
      require("zh2en.notify").error("invalid job arguments")
    elseif return_job_id == -1 then
      require("zh2en.notify").error(bin_path .. " is not executable")
    else
      rust_job_id = return_job_id
    end
  end
end

--- send rpc to translate.
--- @param origin string  chinese string to be translated into english
local function rpc_translate(origin)
  if rust_job_id == nil then
    require("zh2en.notify").error("translator initialize failed")
    return
  end

  -- require("zh2en.notify").info(tostring(rust_job_id))
  local translated = vim.fn.rpcrequest(rust_job_id, origin)

  require("zh2en.notify").info(translated)

  return translated
end

local M = {}

M = {
  rpc_init = rpc_init,
  rpc_translate = rpc_translate,
}

return M
