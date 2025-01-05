local ESX = nil
local isInsideClub = false
local clubEntryFee = 100

local drinks = {
    {label = 'Bière', value = 'beer', price = 50, anim = 'WORLD_HUMAN_DRINKING'},
    {label = 'Vodka', value = 'vodka', price = 100, anim = 'PROP_HUMAN_BUM_BIN'},
    {label = 'Whiskey', value = 'whiskey', price = 150, anim = 'WORLD_HUMAN_PARTYING'}
}

local clubZones = {
    entrance = vector3(128.0, -1284.0, 29.0),
    bar = vector3(132.0, -1287.0, 29.0),
    danceFloor = vector3(135.0, -1289.0, 29.0)
}

-- Initialisation d'ESX
CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(10)
    end
end)

-- Fonction pour dessiner un texte 3D
local function DrawText3D(coords, text, scale)
    local x, y, z = table.unpack(coords)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Entrée dans le club
CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - clubZones.entrance)

        if distance < 10.0 then
            DrawMarker(1, clubZones.entrance.x, clubZones.entrance.y, clubZones.entrance.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)

            if distance < 2.0 and not isInsideClub then
                DrawText3D(clubZones.entrance, "[E] Entrer dans le club ($" .. clubEntryFee .. ")", 0.35)

                if IsControlJustReleased(0, 38) then -- Touche E
                    ESX.TriggerServerCallback('esx:canAfford', function(canAfford)
                        if canAfford then
                            ESX.ShowNotification('Bienvenue dans le club !')
                            isInsideClub = true
                        else
                            ESX.ShowNotification('Vous n\'avez pas assez d\'argent.')
                        end
                    end, clubEntryFee)
                end
            end
        end

        Wait(0)
    end
end)

-- Service au bar
CreateThread(function()
    while true do
        if isInsideClub then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - clubZones.bar)

            if distance < 10.0 then
                DrawMarker(1, clubZones.bar.x, clubZones.bar.y, clubZones.bar.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, nil, nil, false)

                if distance < 2.0 then
                    DrawText3D(clubZones.bar, "[E] Servir une boisson", 0.35)

                    if IsControlJustReleased(0, 38) then -- Touche E
                        OpenBarMenu()
                    end
                end
            end
        end

        Wait(0)
    end
end)

-- Menu du bar
function OpenBarMenu()
    local elements = {}

    for _, drink in ipairs(drinks) do
        table.insert(elements, {label = drink.label .. " ($" .. drink.price .. ")", value = drink.value, anim = drink.anim, price = drink.price})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bar_menu', {
        title = "Menu du Bar",
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local drink = data.current

        ESX.TriggerServerCallback('esx:canAfford', function(canAfford)
            if canAfford then
                ESX.ShowNotification("Vous avez servi une " .. drink.label .. " pour $" .. drink.price)
                TaskStartScenarioInPlace(PlayerPedId(), drink.anim, 0, true)
                Wait(5000)
                ClearPedTasks(PlayerPedId())
            else
                ESX.ShowNotification("Vous n'avez pas assez d'argent pour cette boisson.")
            end
        end, drink.price)
    end, function(data, menu)
        menu.close()
    end)
end

-- Danse sur la piste
CreateThread(function()
    while true do
        if isInsideClub then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - clubZones.danceFloor)

            if distance < 10.0 then
                DrawMarker(1, clubZones.danceFloor.x, clubZones.danceFloor.y, clubZones.danceFloor.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 255, 100, false, true, 2, nil, nil, false)

                if distance < 2.0 then
                    DrawText3D(clubZones.danceFloor, "[E] Danser sur la piste", 0.35)

                    if IsControlJustReleased(0, 38) then -- Touche E
                        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_PARTYING", 0, true)
                    end
                end
            end
        end

        Wait(0)
    end
end)
