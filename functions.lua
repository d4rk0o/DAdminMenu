local noclipSpeed = 1.0
local noclipSpeedLevels = {1.0, 3.0, 6.0, 10.0}
local currentSpeedLevel = 1

-- Fonction pour formater le prix avec des virgules
function sp(price)
    local formatted = tostring(price)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Fonction pour formater le temps
function formatDate(timestamp)
    if type(timestamp) ~= "number" then
        return "Format de date invalide"
    end

    local seconds = math.floor(timestamp / 1000)
    
    local epochAdjustment = 1577836800
    seconds = seconds - epochAdjustment

    local daysPerMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local year = 2020
    local month = 1
    local day = 1
    local hour = 0
    local min = 0
    local sec = 0

    local function isLeapYear(y)
        return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
    end

    while seconds >= 86400 do
        local daysInYear = isLeapYear(year) and 366 or 365
        if seconds >= daysInYear * 86400 then
            seconds = seconds - daysInYear * 86400
            year = year + 1
        else
            break
        end
    end

    daysPerMonth[2] = isLeapYear(year) and 29 or 28

    local days = math.floor(seconds / 86400)
    for i = 1, 12 do
        if days >= daysPerMonth[i] then
            days = days - daysPerMonth[i]
            month = month + 1
        else
            break
        end
    end

    day = day + days
    local remainingSecs = seconds % 86400
    hour = math.floor(remainingSecs / 3600)
    min = math.floor((remainingSecs % 3600) / 60)
    sec = remainingSecs % 60

    -- Ajouter 2 heures pour le fuseau horaire
    hour = hour + 2
    if hour >= 24 then
        hour = hour - 24
        day = day + 1
        if day > daysPerMonth[month] then
            day = 1
            month = month + 1
            if month > 12 then
                month = 1
                year = year + 1
            end
        end
    end

    return string.format("%02d/%02d/%04d %02d:%02d:%02d", day, month, year, day, hour, min, sec)
end

-- Fonction pour faire une notification
function notify(message)
    -- Paramètres pour l'icône
    -- iconType = 1 pour la gauche, 2 pour la droite, etc.
    -- iconImage est l'image à utiliser pour l'icône (e.g., CHAR_DEFAULT)

    -- Charger la texture de l'icône
    RequestStreamedTextureDict("CHAR_DEFAULT", true)
    while not HasStreamedTextureDictLoaded("CHAR_DEFAULT") do
        Wait(10)
    end

    -- Créer la notification
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentString(message)

    -- Définir le titre et l'icône
    EndTextCommandThefeedPostMessagetext("CHAR_DEFAULT", "CHAR_DEFAULT", false, 1, "Administration", "")
    EndTextCommandThefeedPostTicker(false, false)
end

-- NoClip
function ToggleNoclip()
    noclipActive = not noclipActive
    local ped = PlayerPedId()

    notify(noclipActive and 'Noclip ~g~actif' or 'Noclip ~r~inactif')
    
    if noclipActive then
        SetEntityInvincible(ped, true)
        SetEntityVisible(ped, false, false)
    else
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
    end
end

function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()

    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)

    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end

    return x, y, z
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if noclipActive then
            local ped = PlayerPedId()
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local dx, dy, dz = GetCamDirection()

            SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)

            if IsControlPressed(0, 32) then -- W
                x = x + (noclipSpeed * dx)
                y = y + (noclipSpeed * dy)
                z = z + (noclipSpeed * dz)
            end

            if IsControlPressed(0, 269) then -- S
                x = x - (noclipSpeed * dx)
                y = y - (noclipSpeed * dy)
                z = z - (noclipSpeed * dz)
            end

            if IsControlJustPressed(0, 21) then -- SHIFT
                currentSpeedLevel = (currentSpeedLevel % #noclipSpeedLevels) + 1
                noclipSpeed = noclipSpeedLevels[currentSpeedLevel]
                notify("Vitesse de noclip : " .. noclipSpeed)
            end

            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
        end
    end
end)

-- DrawTexts
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function DrawText2D(text, x, y, scale, font)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end


-- Event pour les notification
RegisterNetEvent('adminmenu:notify')
AddEventHandler('adminmenu:notify', function(message)
    notify(message)
end)