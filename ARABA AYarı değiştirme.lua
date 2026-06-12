local VenyxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua"))()
local Venyx = VenyxLibrary.new("Drive World Tuner Pro", 5013109572)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Menü Açma/Kapatma Tuşu (SAĞ CTRL)
local menuToggleKey = Enum.KeyCode.RightControl

-- Karanlık ve Kırmızı Modern Tema
local Theme = {
	Background = Color3.fromRGB(25, 25, 30), 
	Glow = Color3.fromRGB(200, 50, 50), 
	Accent = Color3.fromRGB(35, 35, 40), 
	LightContrast = Color3.fromRGB(45, 45, 50), 
	DarkContrast = Color3.fromRGB(20, 20, 25),  
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

-- YENİ: HİLEYİ TAMAMEN KAPATMA BUTONU (X)
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


-- 2. MOTOR GÜCÜ (TORK & BEYGİR)
local speedSection = vehiclePage:addSection("Motor Gücü (Tork & Beygir)")
local velocityMult = 0.025

speedSection:addSlider("Tork Çarpanı (İvmelenme)", 25, 0, 100, function(v) velocityMult = v / 1000 end)

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
					SeatPart.AssemblyLinearVelocity *= Vector3.new(1 + velocityMult, 1, 1 + velocityMult)
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

handlingSection:addSlider("Downforce (Yere Yapışma Gücü)", 0, 0, 100, function(v) downforceMult = v * 50 end)
handlingSection:addSlider("Handling (Dönüş Hassasiyeti)", 0, 0, 100, function(v) handlingMult = v * 0.5 end)


-- 4. VİRAJ TUTUŞ SİSTEMİ (ANTI-DRIFT) - YENİDEN YAZILDI
local gripSection = vehiclePage:addSection("Viraj Tutusu (Anti-Kayma)")
local gripEnabled = false
local gripStrength = 0.5 -- 0.0 ile 1.0 arası

gripSection:addToggle("Viraj Tutusunu Aktif Et", false, function(v) gripEnabled = v end)
gripSection:addSlider("Tutuş Gucu (0=Normal, 100=Tam Tutus)", 50, 0, 100, function(v) gripStrength = v / 100 end)


-- 5. FREN SİSTEMİ
local decelerateSelection = vehiclePage:addSection("Fren Sistemi")
local qbEnabledKeyCode = Enum.KeyCode.S
local velocityMult2 = 150e-3

decelerateSelection:addSlider("Fren Gücü", velocityMult2*1e3, 0, 500, function(v) velocityMult2 = v / 1000 end)

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
					SeatPart.AssemblyLinearVelocity *= Vector3.new(1 - velocityMult2, 1, 1 - velocityMult2)
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
				SeatPart.AssemblyLinearVelocity *= Vector3.new(0, 0, 0)
				SeatPart.AssemblyAngularVelocity *= Vector3.new(0, 0, 0)
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

-- Tüm bağlantıları burada topla, kapatma butonu için
local AllConnections = {}

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
						local vehicleCFrame = SeatPart.CFrame
						
						-- ============================================
						-- VİRAJ TUTUŞ SİSTEMİ (ANTI-DRIFT) - DÜZELTİLDİ
						-- Arabayı uçurmuyor, sadece yavaşça düzeltiyor
						-- ============================================
						if gripEnabled and gripStrength > 0 then
							-- Sadece yatay düzlemde (Y=0) çalış, Y eksenine asla dokunma
							local flatLook = Vector3.new(vehicleCFrame.LookVector.X, 0, vehicleCFrame.LookVector.Z).Unit
							local flatRight = Vector3.new(vehicleCFrame.RightVector.X, 0, vehicleCFrame.RightVector.Z).Unit
							
							-- Mevcut hızın yatay bileşenleri
							local flatVel = Vector3.new(currentVel.X, 0, currentVel.Z)
							
							-- İleri ve yanal hızları hesapla
							local forwardSpeed = flatVel:Dot(flatLook)
							local lateralSpeed = flatVel:Dot(flatRight)
							
							-- Yanal kaymayı gripStrength oranında azalt (ani değil, kademeli)
							local correctedLateral = lateralSpeed * (1 - gripStrength * 0.15)
							
							-- Yeni yatay hız vektörü oluştur
							local newFlatVel = (flatLook * forwardSpeed) + (flatRight * correctedLateral)
							
							-- Y eksenini ASLA değiştirme, sadece X ve Z'yi güncelle
							SeatPart.AssemblyLinearVelocity = Vector3.new(newFlatVel.X, currentVel.Y, newFlatVel.Z)
						end
						
						-- DOWNFORCE (Aracı Yere Bastırma)
						if downforceMult > 0 then
							SeatPart:ApplyImpulse(Vector3.new(0, -downforceMult, 0))
							
							if math.abs(currentVel.Y) > 5 then
								SeatPart.AssemblyLinearVelocity = Vector3.new(
									SeatPart.AssemblyLinearVelocity.X, 
									SeatPart.AssemblyLinearVelocity.Y * 0.95, 
									SeatPart.AssemblyLinearVelocity.Z
								)
							end
						end
						
						-- HANDLING (Dönüş Hızını Arttırma)
						if handlingMult > 0 then
							if UserInputService:IsKeyDown(Enum.KeyCode.A) then
								SeatPart:ApplyAngularImpulse(Vector3.new(0, handlingMult * SeatPart.AssemblyMass * 0.1, 0))
							elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
								SeatPart:ApplyAngularImpulse(Vector3.new(0, -handlingMult * SeatPart.AssemblyMass * 0.1, 0))
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

