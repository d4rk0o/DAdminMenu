ESX = exports["es_extended"]:getSharedObject()
local flechesmenuversladroite = "→"
local inventory = exports.ox_inventory


local Keys = {
    ["ESC"] = 322,["F1"] = 288,["F2"] = 289,["F3"] = 170,["F5"] = 166,["F6"] = 167,["F7"] = 168,["F8"] = 169,["F9"] = 56,["F10"] = 57,
    ["~"] = 243,["1"] = 157,["2"] = 158,["3"] = 160,["4"] = 164,["5"] = 165,["6"] = 159,["7"] = 161,["8"] = 162,["9"] = 163,["-"] = 84,["="] = 83,["BACKSPACE"] = 177,
    ["TAB"] = 37,["Q"] = 44,["W"] = 32,["E"] = 38,["R"] = 45,["T"] = 245,["Y"] = 246,["U"] = 303,["P"] = 199,["["] = 39,["]"] = 40,["ENTER"] = 18,["CAPS"] = 137,
    ["A"] = 34,["S"] = 8,["D"] = 9,["F"] = 23,["G"] = 47,["H"] = 74,["K"] = 311,["L"] = 182,
    ["LEFTSHIFT"] = 21,["Z"] = 20,["X"] = 73,["C"] = 26,["V"] = 0,["B"] = 29,["N"] = 249,["M"] = 244,[","] = 82,["."] = 81,
    ["LEFTCTRL"] = 36,["LEFTALT"] = 19,["SPACE"] = 22,["RIGHTCTRL"] = 70,
    ["HOME"] = 213,["PAGEUP"] = 10,["PAGEDOWN"] = 11,["DELETE"] = 178,["LEFT"] = 174,["RIGHT"] = 175,["TOP"] = 27,["DOWN"] = 173,["NENTER"] = 201,
    ["N4"] = 108,["N5"] = 60,["N6"] = 107,["N+"] = 96,["N-"] = 97,["N7"] = 117,["N8"] = 61,["N9"] = 118
}

local PlayerData = {}
local group = nil
local menuVisible = false
local staffMode = false
local CheckBoxName = false
local CheckBoxInvincible = false
local CheckBoxNoclip = false
local noclipActive = false
local CheckBoxCoords = false
local jobsFetched = false
local CategoriesFetched = false
local CheckBoxInfiniteStamina = false
local allJobs = {}
local allGrades = {}
local currentJob = nil
local currentCategories = nil
local currentcar = nil
local allCategories = {}
local boosterIndex = 1
local coordsIndex = 1
local playersFilter = 1
local currentIdentifier = nil
local currentPlayer = nil
local isPlayerIsOnline = false
local TeleportationIndex = 1
local LastCoordsForBringBack = nil
local ResourcesFetched = false
local ressourcess = {}
local currentRessource = nil
local actions = {"START", "RESTART", "STOP"}
local resourceIndexes = {}
local resourceStates = {}

local playersData = nil
local dataRequested = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    TriggerServerEvent("admin:requestGroup")
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job) PlayerData.job = job end)

-- Création du menu
local Menu = RageUI.CreateMenu(nil, "Administration")
local MenuPersonnel = RageUI.CreateSubMenu(Menu, nil, nil)
local MenuPersonnelOptions = RageUI.CreateSubMenu(MenuPersonnel, nil, nil)
local MenuPersonnelServer = RageUI.CreateSubMenu(MenuPersonnel, nil, nil)
local MenuPersonnelServerJobs = RageUI.CreateSubMenu(MenuPersonnelServer, nil, nil)
local MenuPersonnelServerGrades = RageUI.CreateSubMenu(MenuPersonnelServerJobs, nil, nil)
local MenuPersonnelServerCategories = RageUI.CreateSubMenu(MenuPersonnelServer, nil, nil)
local MenuPersonnelServerCategoriesCar = RageUI.CreateSubMenu(MenuPersonnelServerCategories, nil, nil)
local MenuPersonnelServerCategoriesCarOptions = RageUI.CreateSubMenu(MenuPersonnelServerCategoriesCar, nil, nil)
local MenuPersonnelVehicules = RageUI.CreateSubMenu(MenuPersonnel, nil, nil)
local MenuPersonnelDeveloppement = RageUI.CreateSubMenu(MenuPersonnel, nil, nil)
local MenuPersonnelDeveloppementInfo = RageUI.CreateSubMenu(MenuPersonnelDeveloppement, nil, nil)
local MenuPersonnelDeveloppementInfoCoords = RageUI.CreateSubMenu(MenuPersonnelDeveloppementInfo, nil, "Coordonnées")
local MenuPersonnelServerResources = RageUI.CreateSubMenu(MenuPersonnelServer, nil, nil)
local MenuPersonnelServerResourcesOptions = RageUI.CreateSubMenu(MenuPersonnelServerResources, nil, nil)

-- Gestion Players
local MenuGestionJoueurs = RageUI.CreateSubMenu(Menu, nil, nil)
local MenuGestionJoueursOptions = RageUI.CreateSubMenu(MenuGestionJoueurs, nil, nil)
local MenuGestionJoueursOptionsGestion = RageUI.CreateSubMenu(MenuGestionJoueursOptions, nil, nil)
local MenuGestionJoueursOptionsGestionTeleportation = RageUI.CreateSubMenu(MenuGestionJoueursOptionsGestion, nil, nil)
local MenuGestionJoueursOptionsGestionInventaire = RageUI.CreateSubMenu(MenuGestionJoueursOptionsGestion, nil, nil)
local MenuGestionJoueursOptionsGestionAutre = RageUI.CreateSubMenu(MenuGestionJoueursOptionsGestion, nil, nil)

function ToggleMenu2()
    if not menuVisible then
        menuVisible = true
        RageUI.Visible(Menu, true)
    else
        menuVisible = false
        RageUI.CloseAll()
        ToggleMenu2()
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        ESX.TriggerServerCallback('admin:getAllPlayers', function(players)
            playersData = players
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if menuVisible then
            RageUI.IsVisible(Menu, function()
                RageUI.Checkbox("Mode Staff", nil, staffMode, {}, {
                    onChecked = function()
                        staffMode = true
                    end,
                    onUnChecked = function()
                        staffMode = false
                    end,
                    onSelected = function(index)
                        staffMode = index
                    end
                })

                if staffMode then
                    RageUI.Separator("[ ~p~" .. GetPlayerServerId(PlayerId()) .. "~w~ ] - " .. GetPlayerName(PlayerId()))
                    RageUI.Button("Actions Personnelles", nil, {RightLabel = "⚙️"}, true, {}, MenuPersonnel)
                    RageUI.Button("Gestion des joueurs ( ~g~" .. #ESX.Game.GetPlayers() .. "~s~ )", nil, {RightLabel = "👥"}, true, {}, MenuGestionJoueurs)
                end
            end)
            
            RageUI.IsVisible(MenuGestionJoueurs, function()
                if playersData then
                    local onlineCount = 0
                    local offlineCount = 0
                    for _, player in ipairs(playersData) do
                        if player.isOnline then
                            onlineCount = onlineCount + 1
                        else
                            offlineCount = offlineCount + 1
                        end
                    end
            
                    RageUI.Separator("↓ ~p~Gestion des joueurs~w~ ↓")
                    RageUI.Separator(string.format("~g~En Ligne~s~ : [ ~b~%d~s~ ] ~r~Hors Ligne~s~ : [ ~b~%d~s~ ] ~o~Total~s~ : [ ~b~%d~s~ ]", 
                        onlineCount, offlineCount, #playersData))
            
                    RageUI.Line()
                    RageUI.List("Filtrer par", {"En Ligne", "Hors Ligne", "Tous"}, playersFilter, nil, {}, true, {
                        onListChange = function(Index, Item)
                            playersFilter = Index
                        end
                    })
            
                    RageUI.Separator("↓ ~p~Liste des joueurs~w~ ↓")
            
                    for _, playerData in pairs(playersData) do
                        local shouldDisplay = 
                            (playersFilter == 1 and playerData.isOnline) or
                            (playersFilter == 2 and not playerData.isOnline) or
                            (playersFilter == 3)
            
                        if shouldDisplay then
                            local status = playerData.isOnline and "~g~[En ligne]" or "~r~[Hors ligne]"
                            local playerInfo = string.format("%s~s~ %s", status, playerData.username or playerData.firstname .. " " .. playerData.lastname)
                            if playerData.isOnline then
                                playerInfo = playerInfo .. string.format(" (ID: %s)", playerData.source)
                            end
                            local accountData = json.decode(playerData.accounts)
                            RageUI.Button(playerInfo, nil, {RightLabel = flechesmenuversladroite .. flechesmenuversladroite .. flechesmenuversladroite}, true, {
                                onActive = function()
                                    local playerName
                                    if playerData.isOnline then
                                        playerName = playerData.username
                                    else
                                        playerName = playerData.firstname .. " " .. playerData.lastname
                                    end
                                    RageUI.Info(playerName,
                                    {
                                    "Identifier: ~g~" .. playerData.identifier .. "~w~",
                                    "Première connexion: ~g~" .. formatDate(playerData.created_at) .. "~w~",
                                    "Dernière connexion: ~g~" .. formatDate(playerData.last_seen) .. "~w~",
                                    "Group: ~y~" .. playerData.group .. "~w~",
                                    "",
                                    "Informations",
                                    "Argent en Banque: ~g~" .. accountData.bank .. "$~w~",
                                    "Argent liquide: ~g~" .. accountData.money  .. "$~w~",
                                    "Argent sale: ~g~" .. accountData.black_money .. "$~w~",
                                    "Métier: ~g~" .. playerData.job .. "~w~",
                                    "Grade: ~g~" .. playerData.job_grade .. "~w~",
                                    }, 
                                    nil)
                                end,
                                onSelected = function()
                                    currentIdentifier = playerData.identifier
                                    currentPlayer = playerData
                                    isPlayerIsOnline = playerData.isOnline
                                end
                            }, MenuGestionJoueursOptions)
                        end
                    end
                else
                    RageUI.Separator("Chargement des données...")
                    RageUI.Separator("Cela peut prendre quelques secondes...")
                end
            end)
            

            RageUI.IsVisible(MenuGestionJoueursOptions, function()
                if currentIdentifier and currentPlayer and isPlayerIsOnline then
                    RageUI.Button("Gestion du joueur", nil, {RightLabel = "🙍‍♂️"}, true, {}, MenuGestionJoueursOptionsGestion)
                    RageUI.Button("Envoyer un message", nil, {RightLabel = flechesmenuversladroite .. flechesmenuversladroite .. flechesmenuversladroite}, true, {
                        onSelected = function()
                            local input = lib.inputDialog('Envoyer un message', {
                                {type = 'input', label = 'Message', description = false, required = true, min = 4, max = 150},
                              })
                            if input ~= nil then
                                TriggerServerEvent('adminmenu:sendmessage', currentPlayer.source, input[1])
                            end
                        end
                    })
                end
            end)

            RageUI.IsVisible(MenuGestionJoueursOptionsGestion, function()
                if currentIdentifier and currentPlayer and isPlayerIsOnline then
                    RageUI.Button("Téléportations", nil, {RightLabel = "⚡"}, true, {}, MenuGestionJoueursOptionsGestionTeleportation)
                    RageUI.Button("Inventaires", nil, {RightLabel = "🎒"}, true, {}, MenuGestionJoueursOptionsGestionInventaire)
                    RageUI.Button("Autres", nil, {RightLabel = "⚙️"}, true, {}, MenuGestionJoueursOptionsGestionAutre)
                end
            end)

            RageUI.IsVisible(MenuGestionJoueursOptionsGestionAutre, function()
                if currentIdentifier and currentPlayer and isPlayerIsOnline then
                    RageUI.Button("Soigner", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local target = currentPlayer.source
                            TriggerServerEvent('menu:soigner:joueur', target)
                        end
                    })
                    RageUI.Button("Rénimer", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local coords = GetEntityCoords(GetPlayerPed(currentPlayer.source))
                            local target = currentPlayer.source
                            TriggerServerEvent('revive:joueur', target, coords)
                        end
                    })
                end
            end)

            RageUI.IsVisible(MenuGestionJoueursOptionsGestionInventaire, function()
                if currentIdentifier and currentPlayer and isPlayerIsOnline then
                    RageUI.Button("Voir l'inventaire", nil, {RightLabel = flechesmenuversladroite .. flechesmenuversladroite .. flechesmenuversladroite}, true, {
                        onSelected = function()
                            local target = currentPlayer.source
                            TriggerServerEvent('menu:inventaire:player', target)
                        end
                    })
                    RageUI.Button("Supprimer l'inventaire", nil, {RightLabel = flechesmenuversladroite .. flechesmenuversladroite .. flechesmenuversladroite}, true, {
                        onSelected = function()
                            local target = currentPlayer.source
                            TriggerServerEvent('menu:inventaire:delete', target)
                        end
                    })
                end
            end)

            RageUI.IsVisible(MenuGestionJoueursOptionsGestionTeleportation, function()
                if currentIdentifier and currentPlayer and isPlayerIsOnline then
                    RageUI.List("Téléportation", {"GO TO", "BRING", "BRING BACK"}, TeleportationIndex, nil, {}, true, {
                        onListChange = function(Index, Item)
                            TeleportationIndex = Index
                        end,
                        onSelected = function()
                            if TeleportationIndex == 1 then
                                TriggerServerEvent('admin:requestPlayerCoords', currentPlayer.source)
                            elseif TeleportationIndex == 2 then
                                local adminCoords = GetEntityCoords(PlayerPedId())
                                TriggerServerEvent('admin:bringPlayer', currentPlayer.source, adminCoords)
                            elseif TeleportationIndex == 3 then
                                TriggerServerEvent('admin:bringPlayerBack', currentPlayer.source, LastCoordsForBringBack)
                            end
                        end
                    })

                end
            end)

            RageUI.IsVisible(MenuPersonnel, function()
                RageUI.Button("Mes options", nil, {RightLabel = "⚙️"}, true, {}, MenuPersonnelOptions)
                RageUI.Button("Listes serveur", nil, {RightLabel = "📰"}, true, {}, MenuPersonnelServer)
                RageUI.Button("Gestion des véhicules", nil, {RightLabel = "🚘"}, true, {}, MenuPersonnelVehicules)
                RageUI.Button("Gestion développement", nil, {RightLabel = "🧷"}, true, {}, MenuPersonnelDeveloppement)
            end)

            RageUI.IsVisible(MenuPersonnelDeveloppement, function()
                RageUI.Button("Plus d'informations", nil, {RightLabel = flechesmenuversladroite ..  flechesmenuversladroite .. flechesmenuversladroite}, true, {}, MenuPersonnelDeveloppementInfo)
                RageUI.Checkbox("Afficher les coordonnées", nil, CheckBoxCoords, {}, {
                    onChecked = function()
                        CheckBoxCoords = true
                    end,
                    onUnChecked = function()
                        CheckBoxCoords = false
                    end
                })
            end)

            RageUI.IsVisible(MenuPersonnelDeveloppementInfo, function()
                RageUI.Button("Coordonnées", nil, {RightLabel = flechesmenuversladroite}, true, {}, MenuPersonnelDeveloppementInfoCoords)
            end)

            RageUI.IsVisible(MenuPersonnelDeveloppementInfoCoords, function()
                RageUI.List("Coordonnées", {"vector3", "{x, y, z}"}, coordsIndex, nil, {}, true, {
                    onListChange = function(Index, Item)
                        coordsIndex = Index
                    end,
                    onSelected = function()
                        if coordsIndex == 1 then
                            local coords = GetEntityCoords(PlayerPedId())
                            print("vector3(" .. coords.x .. ", " .. coords.y .. ", " .. coords.z .. ")")
                            notify("Les coordonnées sont dans le F8 !")
                        elseif coordsIndex == 2 then
                            local coords = GetEntityCoords(PlayerPedId())
                            print("{x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z .. "}")
                            notify("Les coordonnées sont dans le F8 !")
                        end
                    end
                })

                RageUI.Button("Heading", nil, {RightLabel = flechesmenuversladroite}, true, {
                    onSelected = function()
                        local heading = GetEntityHeading(PlayerPedId())
                        print(heading)
                        notify("Le heading est dans le F8 !")
                    end
                })
            end)

            RageUI.IsVisible(MenuPersonnelVehicules, function()
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    RageUI.Button("Réparer", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            SetVehicleFixed(vehicle)
                        end
                    })

                    RageUI.Button("Supprimer", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            SetEntityAsMissionEntity(vehicle, true, true)
                            DeleteEntity(vehicle)
                        end
                    })
                    RageUI.Button("Spawn", nil, {RightLabel = flechesmenuversladroite}, false, {})
                    RageUI.Button("Nettoyer", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            SetVehicleDirtLevel(vehicle, 0.0)
                        end
                    })

                    RageUI.Button("Remplir le réservoir du vehicule", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            exports['RESSOURCE_OF_FUEL']:SetFuel(GetVehiclePedIsIn(PlayerPedId(), false), 100.0)
                        end
                    })

                    RageUI.Button("Vider le réservoir du vehicule", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            exports['RESSOURCE_OF_FUEL']:SetFuel(GetVehiclePedIsIn(PlayerPedId(), false), 0.0)
                        end
                    })

                    RageUI.Button("Changer la plaque du vehicule", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local input = lib.inputDialog('Plaque du vehicule', {
                                {type = 'input', label = 'Plaque du vehicule', description = false, required = true, min = 4, max = 8},
                            })

                            if input ~= nil then
                                SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), input[1])
                            end
                        end
                    })

                    RageUI.List("Booster le vehicule", {1, 2, 4, 8, 16, 32, 64, 128, 256}, boosterIndex, nil, {}, true, {
                        onListChange = function(Index, Item)
                            boosterIndex = Index
                        end,

                        onSelected = function()
                            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            SetVehicleEnginePowerMultiplier(vehicle, 10 ^ boosterIndex)
                            SetVehicleEngineTorqueMultiplier(vehicle, 10 ^ boosterIndex)
                        end
                    })
                else
                    RageUI.Button("Réparer", nil, {RightLabel = flechesmenuversladroite}, false, {})
                    RageUI.Button("Supprimer", nil, {RightLabel = flechesmenuversladroite}, false, {})

                    RageUI.Button("Spawn", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            local input = lib.inputDialog('Model du vehicule', {
                                {type = 'input', label = 'Model du vehicule', description = false, required = true, min = 4, max = 50},
                            })

                            if input ~= nil then
                                local vehicle = input[1]
                                RequestModel(vehicle)
                                while not HasModelLoaded(vehicle) do
                                    Wait(1)
                                end
                                local vehicled = CreateVehicle(vehicle, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)
                                SetEntityAsMissionEntity(vehicled, true, true)
                                SetModelAsNoLongerNeeded(vehicle)
                                SetPedIntoVehicle(PlayerPedId(), vehicled, -1)
                            end
                        end
                    })
                    RageUI.Button("Nettoyer", nil, {RightLabel = flechesmenuversladroite}, false, {})
                    RageUI.Button("Remplir le réservoir du vehicule", nil, {RightLabel = flechesmenuversladroite}, false, {})
                    RageUI.Button("Vider le réservoir du vehicule", nil, {RightLabel = flechesmenuversladroite}, false, {})
                end
            end)

            RageUI.IsVisible(MenuPersonnelServer, function()
                RageUI.Button("Liste des métiers", nil, {RightLabel = flechesmenuversladroite ..  flechesmenuversladroite .. flechesmenuversladroite}, true, {}, MenuPersonnelServerJobs)
                RageUI.Button("Liste des catégories concessionnaires", nil, {RightLabel = flechesmenuversladroite ..  flechesmenuversladroite .. flechesmenuversladroite}, true, {}, MenuPersonnelServerCategories)
                RageUI.Button("Liste des ressources", nil, {RightLabel = flechesmenuversladroite .. flechesmenuversladroite .. flechesmenuversladroite}, true, {}, MenuPersonnelServerResources)
                RageUI.Button("Liste des items", nil, {RightLabel = flechesmenuversladroite ..  flechesmenuversladroite .. flechesmenuversladroite}, true, {
                    onSelected = function()
                        TriggerServerEvent('ox:creativechest')
                        inventory:openInventory('stash', 'creativechest')
                        RageUI.CloseAll()
                    end
                })
                RageUI.Button("Poubelle Administrative", nil, {RightLabel = flechesmenuversladroite}, true, {
                    onSelected = function()
                        TriggerServerEvent('ox:admintrash')
                        inventory:openInventory('stash', 'admintrash')
                        RageUI.CloseAll()
                    end
                })
            end)

            RageUI.IsVisible(MenuPersonnelServerResources, function()
                if not ResourcesFetched then
                    ESX.TriggerServerCallback('getServerResources', function(resources)
                        ressourcess = resources
                        ResourcesFetched = true
                    end)
                else
                    TriggerServerEvent('getResourceStatus')
                    table.sort(ressourcess)
                    for k, v in pairs(ressourcess) do
                        if resourceIndexes[v] == nil then
                            resourceIndexes[v] = 1
                        end
                    
                        local resourceState = resourceStates[v] or "unknown"
                        local description = "Status: " .. resourceState
                        local name
                        if resourceState == "started" then
                            description = description .. " (Appuyez pour arreter/relancer)"
                            name = "~g~" .. v
                        elseif resourceState == "stopped" then
                            description = description .. " (Appuyez pour lancer)"
                            name = "~r~" .. v
                        end
                    
                        RageUI.List(name, actions, resourceIndexes[v], description, {}, true, {
                            onListChange = function(index)
                                resourceIndexes[v] = index
                            end,
                            onSelected = function(index)
                                local selectedAction = actions[index]
                                
                                if selectedAction == "START" then
                                    TriggerServerEvent('startResource', v)
                                    ResourcesFetched = false
                                    TriggerServerEvent('getResourceStatus')
                                elseif selectedAction == "RESTART" then
                                    TriggerServerEvent('restartResource', v)
                                    ResourcesFetched = false
                                    TriggerServerEvent('getResourceStatus')
                                elseif selectedAction == "STOP" then
                                    TriggerServerEvent('stopResource', v)
                                    ResourcesFetched = false
                                    TriggerServerEvent('getResourceStatus')
                                end

                                ESX.TriggerServerCallback('getServerResources', function(resources)
                                    ressourcess = resources
                                    TriggerServerEvent('getResourceStatus')
                                    ResourcesFetched = true
                                end)
                            end
                        })
                    end
                end
            end)

            RageUI.IsVisible(MenuPersonnelServerResourcesOptions, function()
                if currentRessource and ResourcesFetched then
                    print(currentRessource)
                end
            end)

            RageUI.IsVisible(MenuPersonnelServerCategories, function()
                RageUI.Button("Faire apparaitre un vehicule custom", nil, {RightLabel = flechesmenuversladroite}, true, {
                    onSelected = function()
                        local input = lib.inputDialog('Model du vehicule', {
                            {type = 'input', label = 'Model du vehicule', description = false, required = true, min = 4, max = 50},
                        })

                        if input ~= nil then
                            local vehicle = input[1]
                            RequestModel(vehicle)
                            while not HasModelLoaded(vehicle) do
                                Wait(1)
                            end
                            local vehicled = CreateVehicle(vehicle, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)
                            SetEntityAsMissionEntity(vehicled, true, true)
                            SetModelAsNoLongerNeeded(vehicle)
                            SetPedIntoVehicle(PlayerPedId(), vehicled, -1)
                        end
                    end
                })
                RageUI.Separator("↓ ~p~Liste des catégories~w~ ↓")
                if not CategoriesFetched then
                    ESX.TriggerServerCallback('adminmenu:getAllCategories', function(jobs)
                        allJobs = jobs
                        CategoriesFetched = true
                    end)
                else
                    for k, v in pairs(allJobs) do
                        RageUI.Button(v.label, nil, {RightLabel = flechesmenuversladroite}, true, {
                            onSelected = function()
                                ESX.TriggerServerCallback('admin:getAllCarCategories', function(categorie)
                                    allCategories = categorie
                                    currentCategories = v
                                end, v.name)
                            end
                        }, MenuPersonnelServerCategoriesCar)
                    end
                end
            end)

            RageUI.IsVisible(MenuPersonnelServerCategoriesCar, function()
                if not CategoriesFetched then
                    ESX.TriggerServerCallback('admin:getAllCarCategories', function(categorie)
                        allCategories = categorie
                        CategoriesFetched = true
                    end)
                else
                    for k, v in pairs(allCategories) do
                        RageUI.Button(v.name .. " ( " .. v.model .. " )", nil, {RightLabel = sp(v.price) .. "~g~$"}, true, {
                            onSelected = function()
                                ESX.TriggerServerCallback('admin:GetInfoCar', function(car)
                                    currentcar = car
                                end, v.model)
                            end
                        }, MenuPersonnelServerCategoriesCarOptions)
                    end
                end
            end)

            RageUI.IsVisible(MenuPersonnelServerCategoriesCarOptions, function()
                if currentcar then
                    RageUI.Separator("↓ ~p~Base de donnée~w~ ↓")
                    for k, v in pairs(currentcar) do
                        RageUI.Separator(v.name .. " ( " .. v.model .. " )")
                        RageUI.Button("Modifier le prix", nil, {RightLabel = sp(v.price) .. "~g~$"}, true, {
                            onSelected = function()
                                local input = lib.inputDialog('Prix', {
                                    {type = 'input', label = 'Prix', description = false, required = true, min = 1, max = 10},
                                })

                                if input ~= nil then
                                    local newPrice = tonumber(input[1])
                                    if newPrice and newPrice > 0 then
                                        if currentcar then
                                            for k, v in pairs(currentcar) do
                                                TriggerServerEvent("admin:updatePrice", v.model, newPrice)
                                                v.price = newPrice
                                                break
                                            end
                                        end
                                    else
                                        notify("Prix invalide. Veuillez entrer un nombre positif.")
                                    end
                                end
                            end
                        })
                    end
                end
            end)
            
            RageUI.IsVisible(MenuPersonnelServerJobs, function()
                if not jobsFetched then
                    ESX.TriggerServerCallback('adminmenu:getAllJobs', function(jobs)
                        allJobs = jobs
                        jobsFetched = true
                    end)
                else
                    for k, v in pairs(allJobs) do
                        RageUI.Button("[" .. k .. "] - " .. v.label .. " ( " .. v.name .. " )", nil, {RightLabel = flechesmenuversladroite}, true, {
                            onSelected = function()
                                ESX.TriggerServerCallback('adminmenu:getJobGrades', function(jobGrades)
                                    allGrades = jobGrades
                                    currentJob = v
                                end, v.name)
                            end
                        }, MenuPersonnelServerGrades)
                    end
                end
            end)

            RageUI.IsVisible(MenuPersonnelServerGrades, function()
                for k, v in pairs(allGrades) do
                    RageUI.Button("[" .. k .. "] - " .. v.label .. " ( " .. v.name .. " )", nil, {RightLabel = flechesmenuversladroite}, true, {
                        onSelected = function()
                            currentGrade = v
                        end
                    })
                end
            end)

            RageUI.IsVisible(MenuPersonnelOptions, function()
                RageUI.Separator("Mes Options")
                RageUI.Checkbox("Afficher les noms des joueurs", nil, CheckBoxName, {}, {
                    onChecked = function()
                        CheckBoxName = true
                    end,
                    onUnChecked = function()
                        CheckBoxName = false
                    end
                })

                RageUI.Checkbox("Invincible", nil, CheckBoxInvincible, {}, {
                    onChecked = function()
                        CheckBoxInvincible = true
                        SetEntityInvincible(PlayerPedId(), true)
                    end,
                    onUnChecked = function()
                        CheckBoxInvincible = false
                        SetEntityInvincible(PlayerPedId(), false)
                    end
                })

                RageUI.Checkbox("Endurance illimité", nil, CheckBoxInfiniteStamina, {}, {
                    onChecked = function()
                        CheckBoxInfiniteStamina = true
                    end,
                    onUnChecked = function()
                        CheckBoxInfiniteStamina = false
                    end
                })

                RageUI.Checkbox("Noclip", nil, CheckBoxNoclip, {}, {
                    onChecked = function()
                        CheckBoxNoclip = true
                        ToggleNoclip()
                    end,
                    onUnChecked = function()
                        CheckBoxNoclip = false
                        ToggleNoclip()
                    end
                })

                RageUI.Checkbox("Voir les coordonnées", nil, CheckBoxCoords, {}, {
                    onChecked = function()
                        CheckBoxCoords = true
                    end,
                    onUnChecked = function()
                        CheckBoxCoords = false
                    end
                })

                RageUI.Button("Nettoyer le ped", nil, {RightLabel = flechesmenuversladroite ..  flechesmenuversladroite}, true, {
                    onSelected = function()
                        ClearPedBloodDamage(PlayerPedId())
                        ClearPedTasksImmediately(PlayerPedId())
                    end
                })

                RageUI.Button("Se Suicider", nil, {RightLabel = flechesmenuversladroite ..  flechesmenuversladroite}, true, {
                    onSelected = function()
                        SetEntityHealth(PlayerPedId(), 0)
                    end
                })
            end)
        else
            Citizen.Wait(550)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if CheckBoxName then
            local localPlayerCoords = GetEntityCoords(PlayerPedId())
            local localPlayerId = GetPlayerServerId(PlayerId())
            local localPlayerName = GetPlayerName(PlayerId())
            DrawText3D(localPlayerCoords.x, localPlayerCoords.y, localPlayerCoords.z + 1.0, localPlayerId .. " - " .. localPlayerName)
            for _, v in pairs(GetActivePlayers()) do
                if v ~= PlayerId() then
                    if NetworkIsPlayerActive(v) then
                        local playerPed = GetPlayerPed(v)
                        local playerCoords = GetEntityCoords(playerPed)
                        local distance = GetDistanceBetweenCoords(playerCoords, localPlayerCoords, true)

                        if distance < 10.0 then
                            local playerId = GetPlayerServerId(v)
                            local playerName = GetPlayerName(v)
                            DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, playerId .. " - " .. playerName)
                        end
                    end
                end
            end
        elseif CheckBoxInfiniteStamina then
            RestorePlayerStamina(PlayerId(), 1.0)
        elseif CheckBoxCoords then
            local ped = PlayerPedId()
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local heading = GetEntityHeading(ped)
            local coordsText = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f", x, y, z, heading)
            DrawText2D(coordsText, 0.5, 0.97, 0.4, 4)
        else
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent("admin:toggleMenu")
AddEventHandler("admin:toggleMenu", function() ToggleMenu() end)

RegisterCommand("admin", function(source, args, rawCommand)
    if group == "admin" or group == "superadmin" or group == "owner" or group ==
        "mod" or group == "support" or group == "dev" then
        ToggleMenu2()
    end
end)

RegisterNetEvent('adminmenu:receivemessage')
AddEventHandler('adminmenu:receivemessage', function(message)
    notify(message)
end)

RegisterNetEvent('admin:teleportToCoords')
AddEventHandler('admin:teleportToCoords', function(x, y, z)
    local playerPed = PlayerPedId()
    RequestCollisionAtCoord(x, y, z)
    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(x, y, z)
        Citizen.Wait(0)
    end
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
end)

RegisterNetEvent('reanimatePlayerClient')
AddEventHandler('reanimatePlayerClient', function(coords)
    SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, false)
    SetPlayerInvincible(PlayerPedId(), false)
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
    ClearPedBloodDamage(PlayerPedId())
end)


RegisterNetEvent('admin:forcedTeleport')
AddEventHandler('admin:forcedTeleport', function(x, y, z)
    local playerPed = PlayerPedId()
    RequestCollisionAtCoord(x, y, z)
    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(x, y, z)
        Citizen.Wait(0)
    end
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
end)

RegisterNetEvent('admin:bringPlayerBack')
AddEventHandler('admin:bringPlayerBack', function(x, y, z)
    local playerPed = PlayerPedId()
    RequestCollisionAtCoord(x, y, z)
    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(x, y, z)
        Citizen.Wait(0)
    end
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
end)

RegisterNetEvent('admin:SaveCoords')
AddEventHandler('admin:SaveCoords', function(coords)
    if coords then
        LastCoordsForBringBack = coords
    end
end)

RegisterNetEvent('sendResourceStatus')
AddEventHandler('sendResourceStatus', function(states)
    resourceStates = states
end)

RegisterNetEvent("admin:priceUpdated")
AddEventHandler("admin:priceUpdated", function(model, newPrice)
    if currentcar then
        for k, v in pairs(currentcar) do
            if v.model == model then
                v.price = newPrice
                notify("Prix mis à jour avec succès.")
                break
            end
        end
    end
end)

RegisterNetEvent("admin:receiveGroup")
AddEventHandler("admin:receiveGroup",
                function(receivedGroup) group = receivedGroup end)

Citizen.CreateThread(function() TriggerServerEvent("admin:requestGroup") end)


RegisterKeyMapping('admin', 'Menu admin', 'keyboard', 'F9')