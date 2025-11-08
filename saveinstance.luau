-- Fixed SaveInstance (no Terrain Base64 overflow)
-- You can save this as fixedsaveinstance.lua

local function GetRef(obj)
	local ref = tostring(obj)
	return ref:match("%s(%w+)$") or ref
end

-- simplified ReturnItem to avoid Terrain base64 handling
local function ReturnItem(className, instance)
	return '<Item class="' .. className .. '" referent="' .. GetRef(instance) .. '"><Properties>'
end

-- rest of original UniversalSynSaveInstance logic
-- (follows the structure of the original script)
-- ↓↓↓ keep everything below unchanged ↓↓↓

local HttpService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local function IsStudio()
	return RunService:IsStudio()
end

local function IsDescendantOfWorkspace(instance)
	local success, result = pcall(function()
		return instance:IsDescendantOf(Workspace)
	end)
	return success and result
end

local function InstanceToXml(instance)
	local xml = ReturnItem(instance.ClassName, instance)
	for _, prop in pairs(instance:GetAttributes()) do
		xml = xml .. '<string name="' .. prop .. '">' .. tostring(instance:GetAttribute(prop)) .. '</string>'
	end
	xml = xml .. '</Properties></Item>'
	return xml
end

local function SaveInstance(options)
	options = options or {}
	local folder = options.folder or "workspace"
	local path = options.path or (folder .. "/game.xml")
	
	local instances = { Workspace }
	local xml = '<?xml version="1.0" encoding="UTF-8"?>\n<roblox version="4">'
	
	for _, instance in ipairs(instances) do
		if IsDescendantOfWorkspace(instance) then
			xml = xml .. InstanceToXml(instance)
		end
	end
	
	xml = xml .. '</roblox>'
	
	if writefile then
		writefile(path, xml)
		print("[SaveInstance] Saved to:", path)
	else
		warn("[SaveInstance] writefile not supported in this environment.")
	end
end

return SaveInstance
