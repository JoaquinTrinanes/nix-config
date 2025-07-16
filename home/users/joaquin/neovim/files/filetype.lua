vim.filetype.add({
  filename = {
    direnvrc = "bash",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
  },
})
