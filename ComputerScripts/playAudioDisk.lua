local tArgs = {...}

local diskSide = tArgs[1] or "left"

local monitor = peripheral.find("monitor") or term

if disk.hasAudio(diskSide) then
  disk.playAudio(diskSide)

  local title = disk.getAudioTitle(diskSide)

  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("playing disk: ")
  monitor.setCursorPos(1, 2)
  monitor.write(title)

else
  print "audio disk missing"
end