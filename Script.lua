local Library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/KarwaBlox/UI-Library-Poland-Hub/main/Library.lua')))()
local lib = require(game:GetService("ReplicatedStorage").Framework.Library)

getgenv().AutoTakeDrops = false
getgenv().AutoFarm = false
getgenv().AutoEgg = false
getgenv().SelectedEgg = nil
getgenv().AutoDelete = false
getgenv().PetsToDelete = {}
getgenv().ExpRainbowPets = {}
getgenv().AutoExpRainbow = false

local gold = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Golden)
local Egg = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Eggs)



-- // Drops
function TakeAllDrops()
	if typeof(lib.Network.Invoke("get drops")) == "table" then
		for i, v in pairs(lib.Network.Invoke("get drops")) do
			if v then
				local Dropid = i
				for I, V in pairs(v.rewards) do
					if V then
						local DropNumber = v.rewards[I][3]
						if Dropid and DropNumber then
							lib.Network.Fire("take drop", Dropid, DropNumber)
						end
					end
				end
			end
		end
	end
end


spawn(function()
	while task.wait(0.5) do
		if getgenv().AutoTakeDrops then
			TakeAllDrops()
		end
	end
end)

--// Coins

function GetEquippedPets()
	local Equipped = {}
	for i, v in pairs(lib.Stats.Get().Pets) do
		if v.e then
			table.insert(Equipped, v.uid)
		end
	end
	return Equipped
end

function JoinCoin(CoinID, PetID)
	for i, v in pairs(PetID) do
		spawn(function()
			lib.Network.Invoke("join coin", CoinID, v)
		end)
	end
end

function FarmCoin(CoinID, PetID)
	lib.Network.Fire("farm coin", CoinID, PetID)
end

function KillTitanicChest()
	local coinid
	for i, v in pairs(lib.Network.Invoke("get coins")) do
		if v.n == "Titanic Chest" then
			coinid = i
		end
	end
	if coinid ~= nil and GetEquippedPets() ~= nil then
		JoinCoin(coinid, GetEquippedPets())
		for i = 1, 1000 do
			spawn(function()
				for I, V in pairs(GetEquippedPets()) do
					FarmCoin(coinid, V)
				end
			end)
		end
	end
end

spawn(function()
	local coinid
	getgenv().DamageMult = 25
	while task.wait(0.5) do
		if getgenv().AutoFarm then
			for i, v in pairs(lib.Network.Invoke("get coins")) do
				coinid = i
				if coinid ~= nil and GetEquippedPets() ~= nil then
					for i = 1, 3 do
						JoinCoin(coinid, GetEquippedPets())
						--print("Joined Coin "..coinid)
						for I, V in pairs(GetEquippedPets()) do
							spawn(function()
								FarmCoin(coinid, V)	
							--	print("Farming Coin "..coinid)
							end)
						end
					end
				end
				if not getgenv().AutoFarm then break end
			end
		end
	end
end)

function CalculateAvaiableEggs(Egg)
	local Statss = lib.Stats.Get()
	local EggCost = lib.Directory.Eggs[Egg].Cost 

	local Coins = Statss.Coins
	local AvailableEgg = math.ceil(Coins/EggCost)
	return AvailableEgg
end

local SelectedEggAmm = 50

function OpenEggs()
	if (CalculateAvaiableEggs(getgenv().SelectedEgg) +1) > SelectedEggAmm then
		print("You Can Buy that shit "..CalculateAvaiableEggs(getgenv().SelectedEgg).." Many Times")
		for i = 1, CalculateAvaiableEggs(getgenv().SelectedEgg) do
			spawn(function()
				lib.Network.Invoke("Buy Egg", getgenv().SelectedEgg)
			end)
		end
	end
end

spawn(function()
	while task.wait(0.5) do
		if getgenv().SelectedEgg and getgenv().AutoEgg then
			OpenEggs()
		end
	end
end)


function EggNameToId(name)
	local eggid
	for i, v in pairs(lib.Directory.Eggs)  do
		if v.DisplayName == name then
			eggid = i
		end
	end
	return eggid
end


function EggIDToName(id)
	if id ~= nil then
		local EggName = lib.Directory.Eggs[id].DisplayName
		return EggName
	end
end

function PetNameToId(name)
	local id
	if name ~= nil then
		for i, v in pairs(lib.Directory.Pets) do
			if v.name == name then
				id = i
			end
		end
		return id
	end
end

function PetIdToName(id)
	local name
	if id ~= nil then
		for i, v in pairs(lib.Directory.Pets) do
			if i == id then
				name = v.name
			end
		end
		return name
	end
end
spawn(function()
	while task.wait(0.6) do
		if getgenv().AutoDelete and getgenv().PetsToDelete then
			local PetsToDelete = {}
			for i, v in pairs(lib.Stats.Get().Pets) do
				if table.find(getgenv().PetsToDelete, PetIdToName(v.id)) then
					table.insert(PetsToDelete, v.uid)
				end
			end
			lib.Network.Invoke("delete several pets", PetsToDelete)
		end
	end
end)

spawn(function()
	while task.wait(0.6) do
		if getgenv().AutoExpRainbow and getgenv().ExpRainbowPets then
			for i, v in pairs(lib.Stats.Get().Pets) do
				if table.find(getgenv().ExpRainbowPets, PetIdToName(v.id)) then
					if not v.r and not v.g then
						lib.Network.Invoke("Use Rainbow Machine", {v.uid})
						break
					end
				end
			end
		end
	end
end)

local Window = Library:New({name = "Pet Simulator 2 | Karwa#1132"})

local FarmTab = Window:CreateTab({name = "Farming", icon = "rbxassetid://12000177181"})
local EggTab = Window:CreateTab({name = "Eggs", icon = "rbxassetid://12000263983"})

local FarmingSec = FarmTab:Section({name = "Farming"})

local FarmingToggle = FarmingSec:Toggle({name = "Auto Farm", callback = function(v) getgenv().AutoFarm = (v) end})
local KillTitanichChest = FarmingSec:Button({name = "Kill Titanic Chest", callback = function() KillTitanicChest() end})
local DropToggle = FarmingSec:Toggle({name = "Auto Take Drops", callback = function(v) getgenv().AutoTakeDrops = (v) end})
local UITab = Window:CreateTab({name = "UI"})
local DestroyUIBtn = UITab:Button({name = "Destroy UI", callback = function() Window:DestroyUI() end})

local EggSec = EggTab:Section({name = "Auto Eggs"})

local EggInfoSec = EggTab:Section({name = "Egg Info"})

local SelectedEgg = EggInfoSec:Label({name = "Selected Egg nil", centerText = true, icon = false})
local AvailableEgg = EggInfoSec:Label({name = "Available Eggs nil", centerText = true, icon = false})

local AutoOpenEggAtNum = EggSec:Toggle({name = "Auto Open Eggs At "..SelectedEggAmm.." Available", callback = function(v) getgenv().AutoEgg = v end})
local EggAmmount = EggSec:Slider({name = "Select Ammount", 
	callback = function(v) 
		SelectedEggAmm = v
		AutoOpenEggAtNum:SetText("Auto Open Eggs At "..SelectedEggAmm.." Available")
	end, 
	deafult = 222, 
	min = 1, 
	max = 445,
})
local SelectEgg = EggSec:Dropdown({name = "Select Egg", 
	callback = function(v)
		getgenv().SelectedEgg = EggNameToId(v) 
		SelectedEgg:SetText("Selected Egg "..EggIDToName(getgenv().SelectedEgg))
		AvailableEgg:SetText("Available Eggs "..CalculateAvaiableEggs(getgenv().SelectedEgg))
	end})
for i, v in pairs(lib.Directory.Eggs) do
	SelectEgg:Add(v.DisplayName)
end

spawn(function()
	while wait(0.1) do
		if getgenv().SelectedEgg then
			SelectedEgg:SetText("Selected Egg "..EggIDToName(getgenv().SelectedEgg))
			AvailableEgg:SetText("Available Eggs "..CalculateAvaiableEggs(getgenv().SelectedEgg))
		end
	end
end)

local DeleteTab = Window:CreateTab({name = "Delete"})

local DeleteSecton = DeleteTab:Section({name = "Auto Delete"})

local AutoDeleteToggle = DeleteSecton:Toggle({name = "Auto Delete", callback = function(v) getgenv().AutoDelete = v end})
local AutoDeletePets = DeleteSecton:MultiDropdown({name = "Select Pets To Delete", callback = function(v) getgenv().PetsToDelete = v end})
for i, v in pairs(lib.Directory.Pets) do
	AutoDeletePets:Add(v.name)
end

local MachinesTab = Window:CreateTab({name = "Machines", icon = "rbxassetid://12412304458"})

local ExperimentalRainbow = MachinesTab:Section({name = "Experimental Rainbow"})

local AutoExperimental = ExperimentalRainbow:Toggle({name = "Auto Experimental Rainbow", callback = function(v) getgenv().AutoExpRainbow = v end})
local SelectPetsToExp = ExperimentalRainbow:MultiDropdown({name = "Select Pets To Experimental Rainbow", callback = function(v) getgenv().ExpRainbowPets = v end})
for i, v in pairs(lib.Directory.Pets) do
	SelectPetsToExp:Add(v.name)
end
local InfoExp = ExperimentalRainbow:Label({name = "You can select every pet including legendarys but keep in mind its only 25%", icon = false, centerText = true})

local Misctab = Window:CreateTab({name = "Misc", icon = "rbxassetid://12000213750"})
local TeleportSection = Misctab:Section({name = "Teleport"})

local TeleportDrop = TeleportSection:Dropdown({name = "Teleport To", callback = function(v) lib.WorldCmds.Load(v) end})
for i, v in pairs(lib.Directory.Worlds) do
	TeleportDrop:Add(i)
end
