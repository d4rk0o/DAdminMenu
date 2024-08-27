ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("admin:requestGroup")
AddEventHandler("admin:requestGroup", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        local group = xPlayer.getGroup()
        TriggerClientEvent("admin:receiveGroup", _source, group)
    end
end)

ESX.RegisterServerCallback('adminmenu:getAllJobs', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM jobs', {},
                         function(result) cb(result) end)
end)

ESX.RegisterServerCallback('adminmenu:getJobGrades',
                           function(source, cb, jobName)
    MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @jobName',
                         {['@jobName'] = jobName},
                         function(result) cb(result) end)
end)

ESX.RegisterServerCallback('adminmenu:getAllCategories', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM vehicle_categories', {},
                         function(result) cb(result) end)
end)

ESX.RegisterServerCallback('admin:getAllCarCategories',
                           function(source, cb, category)
    MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE category = @category',
                         {['@category'] = category},
                         function(result) cb(result) end)
end)

ESX.RegisterServerCallback('admin:GetInfoCar', function(source, cb, car)
    MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE model = @model',
                         {['@model'] = car}, function(result) cb(result) end)
end)

ESX.RegisterServerCallback('admin:getAllPlayers', function(source, cb)
    local players = {}
    local xPlayers = ESX.GetPlayers()
    
    local onlinePlayers = {}
    for _, playerId in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            onlinePlayers[xPlayer.identifier] = playerId
        end
    end

    MySQL.Async.fetchAll('SELECT * FROM users', {}, function(result)
        for i = 1, #result, 1 do
            local player = result[i]
            player.isOnline = onlinePlayers[player.identifier] ~= nil
            player.source = onlinePlayers[player.identifier] or nil
            if player.source then
                player.username = GetPlayerName(player.source)
            end
            table.insert(players, player)
        end
        cb(players)
    end)
end)

RegisterNetEvent('admin:requestPlayerName')
AddEventHandler('admin:requestPlayerName', function(targetSource)
    local playerName = GetPlayerName(targetSource)
    TriggerClientEvent('admin:returnPlayerName', source, playerName)
end)

RegisterServerEvent('admin:updatePrice')
AddEventHandler('admin:updatePrice', function(model, price)
    MySQL.Async.execute(
        'UPDATE vehicles SET price = @price WHERE model = @model',
        {['@price'] = price, ['@model'] = model})
    TriggerClientEvent("admin:priceUpdated", source, model, price)
end)

local items<const> = exports.ox_inventory:Items()

RegisterNetEvent('ox:creativechest', function()
    local player<const> = Player(source).state
    exports.ox_inventory:RegisterStash('creativechest', "Inventaire Creative",
                                       1500, 500000000000000000, true)

    for _, item in pairs(items) do
        exports.ox_inventory:AddItem('creativechest', item.label, 50,
                                     item.data)
    end
end)

RegisterServerEvent('ox:admintrash')
AddEventHandler('ox:admintrash', function()
    local player = Player(source).state
    exports.ox_inventory:RegisterStash('admintrash', "Poubelle Administrative", 1500, 500000000000000000, true)
end)

RegisterNetEvent('admin:requestPlayerCoords')
AddEventHandler('admin:requestPlayerCoords', function(targetSource)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetSource)
    
    if xTarget then
        local targetPed = GetPlayerPed(targetSource)
        local targetCoords = GetEntityCoords(targetPed)
        TriggerClientEvent('admin:teleportToCoords', _source, targetCoords.x, targetCoords.y, targetCoords.z)
    end
end)

RegisterNetEvent('admin:bringPlayer')
AddEventHandler('admin:bringPlayer', function(targetSource, adminCoords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetSource)
    
    if xTarget then
        local targetPed = GetPlayerPed(targetSource)
        local targetCoords = GetEntityCoords(targetPed)
        TriggerClientEvent('admin:SaveCoords', _source, targetCoords)
        TriggerClientEvent('admin:forcedTeleport', targetSource, adminCoords.x, adminCoords.y, adminCoords.z)
    end
end)

RegisterNetEvent('admin:bringPlayerBack')
AddEventHandler('admin:bringPlayerBack', function(targetSource, coords)
    TriggerClientEvent('admin:bringPlayerBack', targetSource, coords.x, coords.y, coords.z)
end)

RegisterServerEvent('menu:inventaire:player')
AddEventHandler('menu:inventaire:player', function(targetServerId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetServerId)

    if xTarget then
        exports.ox_inventory:forceOpenInventory(xPlayer.source, 'player', xTarget.source)
    end
end)

RegisterServerEvent('menu:inventaire:delete')
AddEventHandler('menu:inventaire:delete', function(targetServerId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetServerId)

    if xTarget then
        exports.ox_inventory:ClearInventory(xTarget.source)
    end
end)

RegisterServerEvent('menu:soigner:joueur')
AddEventHandler('menu:soigner:joueur', function(targetServerId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetServerId)

    if xTarget then
        TriggerClientEvent('esx_status:set', xTarget.source, 'hunger', 1000000)
        TriggerClientEvent('esx_status:set', xTarget.source, 'thirst', 1000000)
        TriggerClientEvent('esx_status:set', xTarget.source, 'health', 200)
        TriggerClientEvent('esx_basicneeds:healPlayer', xTarget.source)
        TriggerClientEvent('adminmenu:notify', _source, "Soin", "Vous avez soigner " .. xTarget.getName())
    end
end)

RegisterServerEvent('menu:revive:joueur')
AddEventHandler('menu:revive:joueur', function(targetServerId, coords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(targetServerId)

    if xTarget then
        TriggerClientEvent('reanimatePlayerClient', xTarget.source, coords)
        TriggerClientEvent('adminmenu:notify', _source, "Reanimer", "Vous avez reanimer " .. xTarget.getName())
    end
end)

RegisterServerEvent('adminmenu:sendmessage')
AddEventHandler('adminmenu:sendmessage', function(target, message)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xTarget = ESX.GetPlayerFromId(target)

    if xTarget then
        TriggerClientEvent('adminmenu:receivemessage', xTarget.source, message)
    end
end)

ESX.RegisterServerCallback('getServerResources', function(source, cb)
    local resources = {}
    for i = 0, GetNumResources() - 1 do
        local resourceName = GetResourceByFindIndex(i)
        table.insert(resources, resourceName)
    end
    cb(resources)
end)

local resourceStates = {}

RegisterServerEvent('startResource')
AddEventHandler('startResource', function(resourceName)
    StartResource(resourceName)
    resourceStates[resourceName] = "started"
    TriggerClientEvent('sendResourceStatus', -1, resourceStates)
end)

RegisterServerEvent('restartResource')
AddEventHandler('restartResource', function(resourceName)
    StopResource(resourceName)
    StartResource(resourceName)
    resourceStates[resourceName] = "started"
    TriggerClientEvent('sendResourceStatus', -1, resourceStates)
end)

RegisterServerEvent('stopResource')
AddEventHandler('stopResource', function(resourceName)
    StopResource(resourceName)
    resourceStates[resourceName] = "stopped"
    TriggerClientEvent('sendResourceStatus', -1, resourceStates)
end)

AddEventHandler('onResourceStart', function(resourceName)
    resourceStates[resourceName] = GetResourceState(resourceName) == "started" and "started" or "stopped"
    TriggerClientEvent('sendResourceStatus', -1, resourceStates)
end)

RegisterServerEvent('getResourceStatus')
AddEventHandler('getResourceStatus', function()
    local resourcesStatus = {}

    for i = 0, GetNumResources() - 1 do
        local resourceName = GetResourceByFindIndex(i)
        local resourceState = GetResourceState(resourceName)
        resourcesStatus[resourceName] = resourceState
    end

    TriggerClientEvent('sendResourceStatus', source, resourcesStatus)
end)