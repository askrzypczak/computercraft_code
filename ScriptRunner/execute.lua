--reads a config file and executes the commands in the file


local function new(_shell, ops)

  local silent = ops and ops.silent
  local filename = ops and ops.filename or "/Config/config.lua"

  if not _shell then error("missing shell dependency") end

  local function run()
    local config = dofile(filename)

    if config == nil then
      error("config file returned nil")
    end
    if type(config) ~= "table" then
      error("config file did not return table")
    end

    local shellCommands = config.commands
    if shellCommands == nil and not silent then print "no commands" end

    for i, command in pairs(shellCommands) do
      if type(command) == "string" then
        _shell.run(command)
      else
        error("command must be a string, to be passed into shell.run()")
      end
    end
  end

  return {
    run = run
  }
end

--true if this is a top level execution, false in dofile() context
if shell then
  new(shell).run()
end

return {
  new = new
}