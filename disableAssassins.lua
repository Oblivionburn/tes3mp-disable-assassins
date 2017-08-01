local Methods = {}
local found = 0
local Assassins = {}

-- Add [ disableAssassins = require("disableAssassins") ] to the top of server.lua
-- Find "OnObjectSpawn" inside server.lua then put [ disableAssassins.OnObjectSpawn(pid, cellDescription) ] at the end

Methods.OnObjectSpawn = function(pid, cellDescription)

	tes3mp.ReadLastEvent() -- Server doesnt save objects to memory so we only get access to the current packet sent which was "OnObjectSpawn"

	for i = 0, tes3mp.GetObjectChangesSize() - 1 do -- Loop through all objects sent in packet
		local refId = tes3mp.GetObjectRefId(i)
		if string.match(refId, "db_assassin") ~= nil then
			Assassins[found] = tes3mp.GetObjectMpNum(i) -- This is how we get the MP num for actors
			found = found + 1
		end
	end
		
	if found > 0 then
		local isMainComplete = false
	
		for i, player in pairs(Players) do -- Do this for each player online
			for i = 0, tes3mp.GetJournalChangesSize(player.pid) - 1 do  -- Loop through all quests for the player
				local quest = tes3mp.GetJournalItemQuest(player.pid, i) -- get quest code
				local index = tes3mp.GetJournalItemIndex(player.pid, i) -- get quest index
				if quest == "c3_destroydagoth" and index >= 50 then
					isMainComplete = true -- Main Quest has been completed
					break
				end
			end

			if isMainComplete == false then
				for index, a in pairs(Assassins) do -- Sometimes more than one assassin spawns
					tes3mp.InitializeEvent(player.pid)
					tes3mp.SetEventCell(cellDescription)
					tes3mp.SetObjectRefNumIndex(0)
					tes3mp.SetObjectMpNum(a) 
					tes3mp.AddWorldObject() -- Add actor to packet
					tes3mp.SendObjectDelete() -- Send Delete
				end
			end
		end
	end
end

return Methods