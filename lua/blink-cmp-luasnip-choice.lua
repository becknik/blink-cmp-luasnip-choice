local defaults = {}

--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

function source.new(opts)
	-- vim.validate("your-source.opts.some_option", opts.some_option, { "string" })
	-- vim.validate("your-source.opts.optional_option", opts.optional_option, { "string" }, true)

	opts = vim.tbl_extend("keep", opts or {}, defaults)
	local self = setmetatable({}, { __index = source })
	self.opts = opts

	vim.api.nvim_create_autocmd("User", {
		pattern = "LuasnipChoiceNodeEnter",
		callback = function()
			vim.schedule(function()
				require("blink-cmp").show({
					providers = { self.opts.name or "choice" },
				})
			end)
		end,
	})
	return self
end

function source:enabled()
	-- return true
	return require("luasnip").choice_active()
end

function source:get_completions(ctx, callback)
	--- @type lsp.CompletionItem[]
	local items = {}

	local keyword = ctx:get_keyword()

	local choice_docstrings = require("luasnip").get_current_choices()

	for i, choice_docstring in ipairs(choice_docstrings) do
		--- @type lsp.CompletionItem
		local item = {
			label = choice_docstring,
			kind = require("blink.cmp.types").CompletionItemKind.Snippet,
			index = i,
			filterText = keyword,
			insertText = "",
		}

		table.insert(items, item)
	end

	callback({ items = items, is_incomplete_backward = false, is_incomplete_forward = false })

	return function()
		-- nothing to cancel
	end
end

function source:execute(ctx, item, callback, default_implementation)
	require("luasnip").set_choice(item.index)
	callback(item)
end

return source
