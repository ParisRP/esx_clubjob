ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local entryFee = 100

-- Vérifie si le joueur peut se permettre un paiement
ESX.RegisterServerCallback('esx:canAfford', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        cb(true)
    else
        cb(false)
    end
end)

-- Log des transactions
local function logTransaction(xPlayer, description, amount)
    print(string.format("[CLUB JOB] %s (%s) %s : $%d", xPlayer.getName(), xPlayer.identifier, description, amount))
end

-- Gestion du paiement à l'entrée
RegisterServerEvent('esx_clubjob:payEntryFee')
AddEventHandler('esx_clubjob:payEntryFee', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= entryFee then
        xPlayer.removeMoney(entryFee)
        TriggerClientEvent('esx:showNotification', source, "Vous avez payé $" .. entryFee .. " pour entrer dans le club.")
        logTransaction(xPlayer, "a payé l'entrée", entryFee)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent pour entrer dans le club.")
    end
end)

-- Achat de boissons au bar
RegisterServerEvent('esx_clubjob:buyDrink')
AddEventHandler('esx_clubjob:buyDrink', function(drinkName, price)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('esx:showNotification', source, "Vous avez acheté une " .. drinkName .. " pour $" .. price .. ".")
        logTransaction(xPlayer, "a acheté une " .. drinkName, price)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent pour acheter une " .. drinkName .. ".")
    end
end)
