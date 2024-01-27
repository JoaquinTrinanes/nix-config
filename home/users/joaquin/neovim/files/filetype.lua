vim.filetype.add({
	extension = {},
	filename = { ["flake.lock"] = "json", [".envrc"] = "sh" },
	pattern = {
		["%.env%.%a+"] = "sh",
	},
})
