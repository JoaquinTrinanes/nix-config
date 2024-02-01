local dotenv_type = "sh"

vim.filetype.add({
  extension = {
    env = dotenv_type,
    lock = "json",
  },
  filename = {
    [".envrc"] = "sh",
    [".env"] = dotenv_type,
    ["env"] = dotenv_type,
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = dotenv_type,
  },
})
