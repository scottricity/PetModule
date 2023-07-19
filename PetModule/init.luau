local api = {}

--to be used server sided only

local cache = {}

local function getPets(player: Player)
	if not cache[player] then
		cache[player] = {}
	end
	return cache[player]
end

local function appendPet(player: Player, pet: Model)
	local _cache = getPets(player)
	table.insert(_cache, pet)
	return table.find(_cache, pet)
end

local function deletePet(player: Player, pet: Model|number)
	local _cache = getPets(player)
	if typeof(pet) == "number" then
		if _cache[pet] then
			table.remove(_cache, pet)
		end
	else
		local identity = table.find(_cache, pet)
		if identity ~= nil then
			table.remove(_cache, identity)
		end
	end
end

local function reconcile(character :Model, pet: Model)
	local container = character:FindFirstChild("PetContainer")
	if not container then
		local folder = Instance.new("Folder")
		folder.Name = "PetContainer"
		folder.Parent = character
		container = folder
	end
	if typeof(pet) ~= "Instance" then error("pet must be a model") end
	if not pet:IsA("Model") then error("pet must be a model") end
	local MiddlePart = pet:FindFirstChild("_Middle")
	if not MiddlePart then
		local ModelCFrame, ModelSize = pet:GetBoundingBox()
		local MPart = Instance.new("Part")
		MPart.Name = "_Middle"
		MPart.CFrame = ModelCFrame
		MPart.Parent = pet
	end
	pet.PrimaryPart = MiddlePart
	local AlignOrientation = MiddlePart:FindFirstChildWhichIsA("AlignOrientation")
	local AlignPosition = MiddlePart:FindFirstChildWhichIsA("AlignPosition")
	local Attachment = MiddlePart:FindFirstChild("FocusA")
	if not Attachment then
		local FocusA = Instance.new("Attachment")
		FocusA.Name = "FocusA"
		FocusA.Parent = MiddlePart
		Attachment = FocusA
	end
	if not AlignOrientation then
		local newOrientation = Instance.new("AlignOrientation")
		newOrientation.Attachment0 = Attachment
		newOrientation.Responsiveness = 10
		newOrientation.Parent = MiddlePart
		AlignOrientation = newOrientation
	end
	if not AlignPosition then
		local newPosition = Instance.new("AlignPosition")
		newPosition.Attachment0 = Attachment
		newPosition.Responsiveness = 10
		newPosition.Parent = MiddlePart
		AlignPosition = newPosition
	end
	AlignOrientation.Attachment0 = Attachment
	AlignPosition.Attachment0 = Attachment
	return AlignOrientation, AlignPosition, container
end

local offsets = {
	[1] = Vector3.new(-2,0,2);
	[2] = Vector3.new(-2,2,2);
}

function api:attachToPlayer(player: Player, pet: Model)
	local character = player.Character
	local petClone = pet:Clone()
	local ao, ap, container = reconcile(character, petClone)
	petClone.Parent = character:FindFirstChild("PetContainer")
	local at1 = Instance.new("Attachment")
	at1.Parent = character.HumanoidRootPart
	local id = appendPet(player, pet)
	at1.Position = offsets[id]
	ao.Attachment1 = at1
	ap.Attachment1 = at1
	local Bobble = petClone:FindFirstChild("_Bobble")
	if Bobble then
		local human = petClone:FindFirstChildWhichIsA("Humanoid")
		local animator = human:FindFirstChild("Animator")
		if animator then
			local tr :AnimationTrack= animator:LoadAnimation(Bobble)
			tr.Priority = Enum.AnimationPriority.Action
			tr:Play(.1,10,0.25)
		end
	end
	for _,v in petClone:GetDescendants() do
		if v:IsA("BasePart") then
			v:SetNetworkOwner(player)
		end
	end
end

function api:getCache(player: Player?)
	return player and (cache[player] or {}) or cache
end

return api