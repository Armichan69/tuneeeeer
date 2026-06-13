-- =================================================================
-- CONTROL PANEL: TUNER (PRO & ANTI-FLING EDITION)
-- DEVELOPED & CUSTOMIZED BY: Arman
-- =================================================================

local VenyxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua"))()
local Venyx = VenyxLibrary.new("Tuner | by Arman", 5013109572)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Menü Açma/Kapatma Tuşu (SAĞ CTRL)
local menuToggleKey = Enum.KeyCode.RightControl

-- Karanlık ve Kırmızı Modern Tema
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

local vehiclePage = Venyx:addPage("Araç Kontrolü", 8356815386)

local creditSection = vehiclePage:addSection("Sistem Bilgisi")
creditSection:addButton("System Status: ANTI-FLING SAFE MODE", function() end)
creditSection:addButton("Authorized Edition: by Arman", function() end)

-- Tüm bağlantıları burada topla, kapatma butonu için
local AllConnections = {}

-- 1. GENEL AYARLAR & ÖZEL TUŞ ATAMA
local usageSection = vehiclePage:addSection("Genel Ayarlar")
local velocityEnabled = true
usageSection:addToggle("Hileleri Aktif Et", velocityEnabled, function(v) velocityEnabled = v end)

usageSection:addKeybind("Menü Aç/Kapat Tuşu", menuToggleKey, function()
    Venyx:toggle()
end, function(v)
    menuToggleKey = v.KeyCode
    print("Yeni menü kısayolu atandı: " .. tostring(menuToggleKey))
end)

-- HİLEYİ TAMAMEN KAPATMA BUTONU (X)
usageSection:addButton("MENÜYÜ TAMAMEN KAPAT [X]", function()
	-- Tüm bağlantıları temizle
	for _, conn in ipairs(AllConnections) do
		pcall(function() conn:Disconnect() end)
	end
	-- Venyx UI'yi yok et
	pcall(function() Venyx:destroy() end)
	-- Eğer GUI kaldıysa direkt temizle
	for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and gui.Name:find("Venyx") then
			gui:Destroy()
		end
	end
end)


-- 2. MOTOR GÜCÜ (BUG-FREE ADDITIVE TORK)
local speedSection = vehiclePage:addSection("Motor Gücü (Tork)")
local velocityMult = 5 

speedSection:addSlider("Tork İvme Gücü", 25, 0, 100, function(v) velocityMult = v / 2 end)

local velocityEnabledKeyCode = Enum.KeyCode.W
speedSection:addKeybind("Gaza Basma Tuşu", velocityEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(velocityEnabledKeyCode) do
		task.wait(0)
		local Character = LocalPlayer.Character
		if Character and typeof(Character) == "Instance" then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid and typeof(Humanoid) == "Instance" then
				local SeatPart = Humanoid.SeatPart
				if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
					SeatPart.AssemblyLinearVelocity = SeatPart.AssemblyLinearVelocity + (SeatPart.CFrame.LookVector * velocityMult)
				end
			end
		end
		if not velocityEnabled then break end
	end
end, function(v) velocityEnabledKeyCode = v.KeyCode end)


-- 3. YOL TUTUŞ & DOWNFORCE
local handlingSection = vehiclePage:addSection("Yol Tutuş & Downforce")
local downforceMult = 0
local handlingMult = 0

handlingSection:addSlider("Downforce (Yere Yapışma Gücü)", 0, 0, 100, function(v) downforceMult = v * 3 end)
handlingSection:addSlider("Handling (Dönüş Hassasiyeti)", 0, 0, 100, function(v) handlingMult = v * 0.2 end)


-- 4. VİRAJ TUTUŞ SİSTEMİ (ANTI-DRIFT) - EĞİMLİ ZEMİN DESTEKLİ
local gripSection = vehiclePage:addSection("Viraj Tutusu (Anti-Kayma)")
local gripEnabled = false
local gripStrength = 0.5 

gripSection:addToggle("Viraj Tutusunu Aktif Et", false, function(v) gripEnabled = v end)
gripSection:addSlider("Tutuş Gucu (0=Normal, 100=Tam Tutus)", 50, 0, 100, function(v) gripStrength = v / 100 end)


-- 5. FREN SİSTEMİ (LOKAL GÜVENLİ FREN)
local decelerateSelection = vehiclePage:addSection("Fren Sistemi")
local qbEnabledKeyCode = Enum.KeyCode.S
local brakePower = 0.15

decelerateSelection:addSlider("Fren Gücü", 150, 0, 500, function(v) brakePower = v / 1000 end)

decelerateSelection:addKeybind("Fren Tuşu", qbEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(qbEnabledKeyCode) do
		task.wait(0)
		local Character = LocalPlayer.Character
		if Character and typeof(Character) == "Instance" then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid and typeof(Humanoid) == "Instance" then
				local SeatPart = Humanoid.SeatPart
				if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
					local localVel = SeatPart.CFrame:VectorToObjectSpace(SeatPart.AssemblyLinearVelocity)
					localVel = Vector3.new(localVel.X * (1 - brakePower), localVel.Y, localVel.Z * (1 - brakePower))
					SeatPart.AssemblyLinearVelocity = SeatPart.CFrame:VectorToWorldSpace(localVel)
				end
			end
		end
		if not velocityEnabled then break end
	end
end, function(v) qbEnabledKeyCode = v.KeyCode end)

decelerateSelection:addKeybind("El Freni (Anında Dur)", Enum.KeyCode.P, function(v)
	if not velocityEnabled then return end
	local Character = LocalPlayer.Character
	if Character and typeof(Character) == "Instance" then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if Humanoid and typeof(Humanoid) == "Instance" then
			local SeatPart = Humanoid.SeatPart
			if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
				SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
	end
end)


-- 6. UÇMA MODU & ANLIK FİZİK DÖNGÜSÜ
local flightSection = vehiclePage:addSection("Uçma Modu (Fly)")
local flightEnabled = false
local flightSpeed = 1

flightSection:addToggle("Uçmayı Aç", false, function(v) flightEnabled = v end)
flightSection:addSlider("Uçuş Hızı", 100, 0, 800, function(v) flightSpeed = v / 100 end)

local defaultCharacterParent 
local steppedConn = RunService.Stepped:Connect(function()
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
		if Character and typeof(Character) == "Instance" then
			Character.Parent = defaultCharacterParent or Character.Parent
			defaultCharacterParent = Character.Parent
			
			if velocityEnabled then
				local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
				if Humanoid and typeof(Humanoid) == "Instance" then
					local SeatPart = Humanoid.SeatPart
					if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
						
						local currentVel = SeatPart.AssemblyLinearVelocity
						
						-- =================================================================
						-- VİRAJ TUTUŞ SİSTEMİ (ANTI-DRIFT) - EĞİMLİ ZEMİN DESTEKLİ
						-- Düzlem projeksiyonu yerine LOCAL koordinat sistemi kullanılır.
						-- Böylece yokuş yukarı/bayır aşağı momentumu korunur,
						-- sadece yanal (sağ/sol) kayma azaltılır.
						-- =================================================================
						if gripEnabled and gripStrength > 0 then
							-- Hız vektörünü arabanın yerel (local) uzayına çevir
							local localVel = SeatPart.CFrame:VectorToObjectSpace(currentVel)
							
							-- Sadece yanal (local X) kaymayı azalt.
							-- Local Y (yokuş/bayır) ve Local Z (ileri/geri) DOKUNULMAZ.
							local correctedLocalVel = Vector3.new(
								localVel.X * (1 - gripStrength * 0.2),
								localVel.Y,
								localVel.Z
							)
							
							-- Düzeltme sonucunu tekrar dünya koordinatlarına çevir
							SeatPart.AssemblyLinearVelocity = SeatPart.CFrame:VectorToWorldSpace(correctedLocalVel)
						end
						
						-- DOWNFORCE: Arabanın altına doğru, eğime uygun kuvvet
						if downforceMult > 0 then
							SeatPart:ApplyImpulse(-SeatPart.CFrame.UpVector * downforceMult * (SeatPart.AssemblyMass * 0.05))
						end
						
						-- HANDLING: Daha kontrollü dönüş, sonsuz spin engeli
						if handlingMult > 0 then
							SeatPart.AssemblyAngularVelocity = SeatPart.AssemblyAngularVelocity * 0.95
							
							if UserInputService:IsKeyDown(Enum.KeyCode.A) then
								SeatPart:ApplyAngularImpulse(Vector3.new(0, handlingMult * SeatPart.AssemblyMass, 0))
							elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
								SeatPart:ApplyAngularImpulse(Vector3.new(0, -handlingMult * SeatPart.AssemblyMass, 0))
							end
						end
						
					end
				end
			end
		end
	end
end)
table.insert(AllConnections, steppedConn)

local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == menuToggleKey then
        Venyx:toggle()
    end
end)
table.insert(AllConnections, inputConn)
