-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
if vim.env.TMUX and vim.env.TERM ~= "screen-256color" then vim.env.TERM = "screen-256color" end

-- Prepend conda env to PATH before any plugin loads (Mason captures PATH at
-- module load time, and the system python3 lacks venv/ensurepip on Ubuntu)
local conda_bin = "/opt/conda/envs/prod/bin"
if vim.fn.isdirectory(conda_bin) == 1 then vim.env.PATH = conda_bin .. ":" .. vim.env.PATH end

local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
