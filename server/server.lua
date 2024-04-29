QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent('mto:meslekayarla', function()
    local playerId = source
    local Player = QBCore.Functions.GetPlayer(playerId)
    local onDuty = true

    if Player.PlayerData.job.name == "unemployed" then
        Player.Functions.SetJobDuty(onDuty)
        if Player.PlayerData.job.onduty then
            Player.Functions.SetJob("copcu")
        end
    end
end)


RegisterNetEvent('mto:meslekayarla2', function ()
    local playerId = source
    local Player = QBCore.Functions.GetPlayer(playerId)
    Player.Functions.SetJob("unemployed")
end)


RegisterNetEvent('mto:meslekgerial', function()
    local playerId = source
    local Player = QBCore.Functions.GetPlayer(playerId)
    Player.Functions.SetJob("unemployed")
    Player.Functions.SetJobDuty(true)
end)


RegisterNetEvent('mto:copcuitemver', function (randItem,amount)
    local playerId = source
    local Player = QBCore.Functions.GetPlayer(playerId)
    Player.Functions.AddItem(randItem, amount)
end)


RegisterNetEvent('mto:copcuundodtydeis:server', function ( )
    local playerId = source
    local Player = QBCore.Functions.GetPlayer(playerId)
    local onDuty = false

    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(onDuty)
    end
end)
