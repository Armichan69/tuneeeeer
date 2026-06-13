-- =================================================================
-- CONTROL PANEL: TUNER (PRO EDITION)
-- DEVELOPED & CUSTOMIZED BY: Arman
-- =================================================================

local VenyxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua"))()
-- Menü başlığına Arman watermark'ı eklendi
local Venyx = VenyxLibrary.new("Tuner | by Arman", 5013109572)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Varsayılan Menü Açma/Kapatma Tuşu ( ']' )
local menuToggleKey = Enum.KeyCode.RightBracket

-- Premium Pro Tema (Karanlık Safir & Agresif Kırmızı)
local Theme = {
	Background = Color3.fromRGB(15, 15, 20), 
	Glow = Color3.fromRGB(255, 30, 30), 
	Accent = Color3.fromRGB(30, 30, 35), 
	LightContrast = Color3.fromRGB(40, 40, 45), 
	DarkContrast = Color3.fromRGB(12, 12, 15),  
	TextColor = Color3.fromRGB(255, 255, 255)
}

for index, value in pairs(Theme) do
	pcall(Venyx.setTheme, Venyx, index, value)
end

local function GetVehicleFromDescendant(Descendant)
	return
		Descendant:FindFirstAncestor(LocalPlayer.Name .. "\'s Car") or
		(Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) or
		(Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent) or
		Descendant:FindFirstAncestorWhichIsA("Model")
end

-- MENÜ SAYFASI
local vehiclePage = Venyx:addPage("Araç Kontrolü", 8356815386)

-- WATERMARK SEKMESİ (Menü içinde görünür)
local creditSection = vehiclePage:addSection("Lisans & Yapımcı")
creditSection:addButton("Tuner Status: PRO MODE ACTIVE", function() end)
creditSection:addButton("Authorized Edition: by Arman", function() end)

-- 1. GENEL AYARLAR
local usageSection = vehiclePage:addSection("Genel Ayarlar")
local velocityEnabled = true
usageSection:addToggle("Hile Fonksiyonları", velocityEnabled, function(v) velocityEnabled = v end)

usageSection:addKeybind("Menü Kısayol Tuşu", menuToggleKey, function()
    Venyx:toggle()
end, function(v)
    menuToggleKey = v.KeyCode
end)


-- 2. MOTOR GÜCÜ (PRO ADDITIVE TORQUE)
local speedSection = vehiclePage:addSection("Motor Gücü (Tork & Beygir)")
local velocityMult = 10 -- Yeni toplamsal güç birimi

speedSection:addSlider("Tork İvme Gücü", 10, 0, 100, function(v) velocityMult = v end)

local velocityEnabledKeyCode = Enum.KeyCode.W
speedSection:addKeybind("Gaza Basma Tuşu", velocityEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(velocityEnabledKeyCode) do
		task.wait(0)
		local Character = LocalPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid and Humanoid.SeatPart and Humanoid.SeatPart:IsA("VehicleSeat") then
				local SeatPart = Humanoid.SeatPart
				-- BUG FIX: Çarpmak yerine arabanın baktığı yöne (LookVector) temiz ekstra kuvvet ekleniyor.
				SeatPart.AssemblyLinearVelocity = SeatPart.AssemblyLinearVelocity + (SeatPart.CFrame.LookVector * (velocityMult * 0.25))
			end
		end
		if not velocityEnabled then break end
	end
end, function(v) velocityEnabledKeyCode = v.KeyCode end)


-- 3. BUGSIZ HANDLING & AKILLI DOWNFORCE
local handlingSection = vehiclePage:addSection("Yol Tutuş & Downforce")
local downforceMult = 0
local handlingMult = 0

handlingSection:addSlider("Downforce (Yere Basma)", 0, 0, 100, function(v) downforceMult = v end)
handlingSection:addSlider("Handling (Dönüş Keskinliği)", 0, 0, 100, function(v) handlingMult = v end)


-- 4. GELİŞMİŞ FREN SİSTEMİ
local decelerateSelection = vehiclePage:addSection("Fren Sistemi")
local qbEnabledKeyCode = Enum.KeyCode.S
local brakePower = 0.15

decelerateSelection:addSlider("Fren Gücü", 150, 0, 500, function(v) brakePower = v / 1000 end)

decelerateSelection:addKeybind("Fren Tuşu", qbEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(qbEnabledKeyCode) do
		task.wait(0)
		local Character = LocalPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid and Humanoid.SeatPart and Humanoid.SeatPart:IsA("VehicleSeat") then
				local SeatPart = Humanoid.SeatPart
				-- Fren yaparken sadece ileri/geri eksenini yavaşlat, zıplama fiziğini bozma
				local localVel = SeatPart.CFrame:VectorToObjectSpace(SeatPart.AssemblyLinearVelocity)
				localVel = Vector3.new(localVel.X, localVel.Y, localVel.Z * (1 - brakePower))
				SeatPart.AssemblyLinearVelocity = SeatPart.CFrame:VectorToWorldSpace(localVel)
			end
		end
		if not velocityEnabled then break end
	end
end, function(v) qbEnabledKeyCode = v.KeyCode end)

decelerateSelection:addKeybind("El Freni (Anında Çak)", Enum.KeyCode.P, function()
	if not velocityEnabled then return end
	local Character = LocalPlayer.Character
	if Character then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if Humanoid and Humanoid.SeatPart and Humanoid.SeatPart:IsA("VehicleSeat") then
			Humanoid.SeatPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Humanoid.SeatPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
		end
	end
end)


-- 5. UÇMA MODU & KUSURSUZ ANLIK FİZİK DÖNGÜSÜ
local flightSection = vehiclePage:addSection("Uçma Modu (Fly)")
local flightEnabled = false
local flightSpeed = 1

flightSection:addToggle("Uçmayı Aç", false, function(v) flightEnabled = v end)
flightSection:addSlider("Uçuş Hızı", 100, 0, 800, function(v) flightSpeed = v / 100 end)

local defaultCharacterParent 
RunService.Stepped:Connect(function()
	local Character = LocalPlayer.Character
	if flightEnabled == true then
		if Character and typeof(Character) == "Instance" then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid and typeof(Humanoid) == "Instance" then
				local SeatPart = Humanoid.SeatPart
				if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
					local Vehicle = GetVehicleFromDescendant(SeatPart)
					if Vehicle and Vehicle:IsA("Model") then
						Character.Parent = Vehicle
						if not Vehicle.PrimaryPart then
							if SeatPart.Parent == Vehicle then
								Vehicle.PrimaryPart = SeatPart
							else
								Vehicle.PrimaryPart = Vehicle:FindFirstChildWhichIsA("BasePart")
							end
						end
						local PrimaryPartCFrame = Vehicle:GetPrimaryPartCFrame()
						Vehicle:SetPrimaryPartCFrame(CFrame.new(PrimaryPartCFrame.Position, PrimaryPartCFrame.Position + workspace.CurrentCamera.CFrame.LookVector) * (UserInputService:GetFocusedTextBox() and CFrame.new(0, 0, 0) or CFrame.new((UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -flightSpeed) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed / 2) or (UserInputService:IsKeyDown(Enum.KeyCode.Q) and -flightSpeed / 2) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -flightSpeed) or 0)))
						SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
				end
			end
		end
	else
		-- ARMAN PRO MODE: GÜVENLİ VE BUGSIZ VİRAJ/DOWNFORCE FİZİĞİ
		if Character and typeof(Character) == "Instance" then
			Character.Parent = defaultCharacterParent or Character.Parent
			defaultCharacterParent = Character.Parent
			
			if velocityEnabled then
				local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
				if Humanoid and typeof(Humanoid) == "Instance" then
					local SeatPart = Humanoid.SeatPart
					if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
						
						-- PRO DOWNFORCE: Sadece dünya ekseninde aşağı doğru dengeli bir baskı uygular. 
						-- Asla sarsıntı yaratmaz, tekerleri yere kilitler.
						if downforceMult > 0 then
							SeatPart.AssemblyLinearVelocity = SeatPart.AssemblyLinearVelocity + Vector3.new(0, -downforceMult * 0.4, 0)
						end
						
						-- ANTI-FLIP & STABILIZER: Arabanın sağa sola yatarak takla atmasını ve uçmasını engeller.
						-- X ve Z dönme hızlarını sönümler, araba daima düz kalır.
						local currentAng = SeatPart.AssemblyAngularVelocity
						SeatPart.AssemblyAngularVelocity = Vector3.new(currentAng.X * 0.1, currentAng.Y, currentAng.Z * 0.1)
						
						-- PRO HANDLING: Tuşa basıldığı sürece sarsıntısız, yumuşak dönme torku ekler.
						if handlingMult > 0 then
							if UserInputService:IsKeyDown(Enum.KeyCode.A) then
								SeatPart.AssemblyAngularVelocity = SeatPart.AssemblyAngularVelocity + Vector3.new(0, handlingMult * 0.05, 0)
							elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
								SeatPart.AssemblyAngularVelocity = SeatPart.AssemblyAngularVelocity + Vector3.new(0, -handlingMult * 0.05, 0)
							end
							
							-- Dönüş hızının sonsuza gidip arabayı fırlatmaması için sınır (Clamp) koyduk
							local maxTurn = (handlingMult * 0.1) + 2
							local rot = SeatPart.AssemblyAngularVelocity
							SeatPart.AssemblyAngularVelocity = Vector3.new(rot.X, math.clamp(rot.Y, -maxTurn, maxTurn), rot.Z)
						end
						
					end
				end
			end
		end
	end
end)

-- MENÜ AÇMA / KAPATMA
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == menuToggleKey then
        Venyx:toggle()
    end
end)

print("[PRO MODE]:  Tuner by Arman successfully loaded!")
