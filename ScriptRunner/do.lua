local tArgs = {...}

if tArgs[1] == "help" then
  print([[allows for "do ... then ... then ... " shell command chains
    also for "do ... every <number of seconds>"
    "every" must be the last command if provided
    when combined with "then", will repeat all commands, going to the beginning or starting at the last "and"
    allowing "do x then y and then z and q every 500" (seconds), which will repeat z and q but not x and y
  ]])
  return
end

local recovery = dofile("/API/recovery.lua").recovery

local function new(_shell, _tArgs)

  if not _shell then error("missing shell dependency") end
  if not _tArgs then error("no arguments provided") end


  local commandList = {}
  local loopList = {}
  local waitDuration


  local hitAnd = false
  local expectThen = false
  local expectCommand = true
  local hitEvery = false
  local currentCommands = {}

  local function dumpLoop()
    if #loopList > 0 then
      for i, command in pairs(loopList) do
        table.insert(commandList, command)
      end
    end
    loopList = {}
  end
  local function dumpCurrentCommands()
    local target
    if hitAnd then target = loopList else target = commandList end
    if #currentCommands > 0 then
      table.insert(target, currentCommands)
    end
    currentCommands = {}
  end

  for i, arg in pairs(_tArgs) do
    if expectCommand and (arg == "and" or arg == "then" or arg == "every") then
      error "cannot follow an operator with another one"

    elseif arg == "and" then
      dumpCurrentCommands()
      dumpLoop()
      hitAnd = true
      expectThen = true

    elseif arg == "then" then
      dumpCurrentCommands()
      expectThen = false
      expectCommand = true

    elseif arg == "every" then hitEvery = true

    elseif hitEvery and not waitDuration then
      waitDuration = tonumber(arg)
      if not waitDuration then error "argument after 'every' is not a number" end

    elseif expectThen then error "did not follow 'and' with 'then'"

    elseif hitEvery then error "only one argument allowed after 'every'"

    else
      table.insert(currentCommands, arg)
      expectCommand = false
    end
  end

  if hitEvery and not waitDuration then error "must provide a duration after 'every'" end

  dumpCurrentCommands()

  if waitDuration and #loopList == 0 then
    loopList = commandList
    commandList = {}
  end

  local function run()
    for i, shellArgs in pairs(commandList) do
      _shell.run(table.unpack(shellArgs))
    end
    if waitDuration then
      
      local recoverCommand = "do"
      for i, commands in pairs(loopList) do
        for j, shellArg in pairs(commands) do
          recoverCommand = recoverCommand .. " " .. shellArg
        end

        if i < #loopList then
          recoverCommand = recoverCommand .. " then"
        else
          recoverCommand = recoverCommand .. " every " .. waitDuration
        end
      end

      recovery.generateRecoveryFile(recoverCommand)

      if recovery.checkInRecovery() then
        recovery.recoveryBlock(function() os.sleep(waitDuration) end)
      end
      while true do
        for i, shellArgs in pairs(loopList) do
          _shell.run(table.unpack(shellArgs))
        end
        recovery.recoveryBlock(function() os.sleep(waitDuration) end)
      end

    end
  end

  return {
    run = run
  }
end


--true if this is a top level exeuction, false in dofile() context
if shell then
  new(shell, tArgs).run()
end

return {
  new = new
}