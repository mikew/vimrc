local vimrc = require('vimrc')

local mod = {}

--- @type table<string, unknown>
local spec_data = {}

--- Base spec from Neovim with `src` as `[1]` since that's annoying.
--- @class VimPackSpec
--- Name of plugin. Will be used as directory name. Default: `src` repository name.
--- @field name? string
---
--- Version to use for install and updates. Can be:
--- - `nil` (no value, default) to use repository's default branch (usually `main` or `master`).
--- - String to use specific branch, tag, or commit hash.
--- - Output of |vim.version.range()| to install the greatest/last semver tag
---   inside the version constraint.
--- @field version? string|vim.VersionRange
---
--- @field data? any Arbitrary data associated with a plugin.

--- @class VimrcPackSpec: VimPackSpec
--- URI from which to install and pull updates. Any format supported by `git clone` is allowed.
--- @field [1] string
--- @field setup? fun()
--- @field lazy? boolean
--- @field pack_add_options? vim.pack.keyset.add

---@param specs VimrcPackSpec[]
function mod.add(specs, opts)
  --- @type vim.pack.Spec[]
  local vim_pack_specs = {}

  for _, spec in ipairs(specs) do
    local name = spec.name or vim.fn.fnamemodify(spec[1], ':t')

    spec_data[name] =
      vim.tbl_deep_extend('force', spec_data[name] or {}, spec.data or {})

    vim_pack_specs[#vim_pack_specs + 1] = {
      src = spec[1],
      name = name,
      version = spec.version,
      data = spec.data,
    }

    if spec.setup then
      if spec.lazy then
        mod.setup_plugin_lazy(spec.setup)
      else
        mod.setup_plugin(spec.setup)
      end
    end
  end

  vim.pack.add(vim_pack_specs, opts)
end

--- @param name string
function mod.get_data_for(name)
  return spec_data[name]
end

--- @type fun()[]
local _plugin_setup_fns = {}
local _did_run_plugin_setups = false

--- @param fn fun()
function mod.setup_plugin(fn)
  if _did_run_plugin_setups then
    vim.schedule(fn)
  else
    table.insert(_plugin_setup_fns, vim.schedule_wrap(fn))
  end
end

--- @type fun()[]
local _plugin_setup_lazy_fns = {}

--- @param fn fun()
function mod.setup_plugin_lazy(fn)
  if _did_run_plugin_setups then
    vim.schedule(fn)
  else
    table.insert(_plugin_setup_lazy_fns, vim.schedule_wrap(fn))
  end
end

function mod.run_plugin_setups()
  for _, fn in ipairs(_plugin_setup_fns) do
    pcall(fn)
  end

  _plugin_setup_fns = {}

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      for _, fn in ipairs(_plugin_setup_lazy_fns) do
        pcall(fn)
      end

      _plugin_setup_lazy_fns = {}
      spec_data = {}
    end,
  })

  _did_run_plugin_setups = true
end

--- @type table<string, boolean>
local _plugin_cache = {}

--- @param name string
function mod.has_plugin(name)
  if _plugin_cache[name] then
    return true
  end

  for _, plug in ipairs(vim.pack.get()) do
    if plug.spec.name == name then
      _plugin_cache[name] = true
      return true
    end
  end

  return false
end

return mod
