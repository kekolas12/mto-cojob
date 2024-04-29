local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    local hash = Config.PedProps['hash']
    local coords = Config.PedProps['location']
    QBCore.Functions.LoadModel(hash)
    local playerData = QBCore.Functions.GetPlayerData()
    local job = playerData.job
    local lastJobTakenTime = 0 

    local buyerPed = CreatePed(0, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
    TaskStartScenarioInPlace(buyerPed, 'WORLD_HUMAN_CLIPBOARD', true)
    FreezeEntityPosition(buyerPed, true)
    SetEntityInvincible(buyerPed, true)
    SetBlockingOfNonTemporaryEvents(buyerPed, true)

    exports['qb-target']:AddTargetEntity(buyerPed, {
        options = {
            {
                type = 'client',
                icon = 'fa fa-book',
                label = 'İşe girmek için başvur!',
                action = function()
                    if job.name == "copcu"then
                        QBCore.Functions.Notify("Zaten çalışıyorsun!", "error")
                        return
                    end
                    local pedPos = GetEntityCoords(PlayerPedId())
                    local dist = #(pedPos - vector3(coords))
                    if dist <= 5.0 then
                        local hour = GetClockHours() -- Oyun saatini al
                        if (hour >= 20 or hour <= 4) then -- Saat 20:00 ile 04:00 arasında kontrol et
                            QBCore.Functions.Notify("Çok geç oldu, daha sonra tekrar gel.", "error")
                            return
                        end
                        local currentTime = GetGameTimer() / 1000 -- FiveM zamanını al ve saniyeye çevir
                        if currentTime - lastJobTakenTime < 1200 then -- 20 dakika aralık kontrolü (20 dakika = 1200 saniye)
                            local timeLeft = 1200 - (currentTime - lastJobTakenTime)
                            local minutesLeft = math.ceil(timeLeft / 60)
                            QBCore.Functions.Notify("Başvurmak için tekrar gelmeden önce " .. minutesLeft .. " dakika beklemelisin.", "error")
                            return
                        end
                        TriggerServerEvent("mto:meslekayarla", -1)
                        lastJobTakenTime = currentTime -- İş alındığı zamanı güncelle
                        getcojob()
                    end
                end
            },
        },
        distance = 2.0
    })
end)


function getcojob()
    Citizen.CreateThread(function() 
    local spawnPoint = vector3(-615.04, -1600.29, 27.01) 
    local spawnRadius = 5.0 
    local checkRadius = 10.0 
    local vehicle = GetClosestVehicle(spawnPoint, checkRadius)
    local distance = GetDistanceBetweenCoords(GetEntityCoords(vehicle), spawnPoint, true)
    if DoesEntityExist(vehicle) and distance < checkRadius then
        QBCore.Functions.Notify("Araç çıkartma noktası dolu!", "error")
        return
    else
        coords = vector3(-615.04, -1600.29, 27.01)
        QBCore.Functions.SpawnVehicle('trash', function(veh)
            SetVehicleNumberPlateText(veh, 'TEST')
            SetEntityHeading(veh, coords)
            exports['LegacyFuel']:SetFuel(veh, 100.0)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, false)
        end, coords, true)
    end
end)
end






local count = 0
local itemProbabilities = {
    metalscrap = 30,
    plastic = 20,
    copper = 50,
    iron = 10,
    aluminum = 15,
    steel = 25,
    glass = 5,
}

local itemIndexList = {}

for item, probability in pairs(itemProbabilities) do
    for i = 1, probability do
        table.insert(itemIndexList, item)
    end
end

local clickedTrashCanEntities = {}

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.CONModels, {
        options = {
            {
                type = 'client',
                icon = "fa fa-trash",
                label = "Çöpleri topla!",
                action = function(entity)
                    local player = PlayerPedId()
                    local playerData = QBCore.Functions.GetPlayerData()
                    local job = playerData.job
                    local onDuty = job and job.onduty and job.name == "copcu"
                    
                    local entityID = NetworkGetNetworkIdFromEntity(entity)

                    if not clickedTrashCanEntities[entityID] and onDuty then
                        clickedTrashCanEntities[entityID] = true

                        local randomIndex = math.random(1, #itemIndexList)
                        local selectedItemId = itemIndexList[randomIndex]
                        local randItem = selectedItemId
                        
                        local amount = math.random(1, 3)
                        count = (count or 0) + 1
                        
                        TriggerServerEvent('mto:copcuitemver', randItem, amount)
                        if (count == 12) then
                            aracverisi = true
                            job.onduty = false
                            TriggerServerEvent('mto:copcuundodtydeis:server',-1)
                            QBCore.Functions.Notify("Bugün yeterince çöp topladın! Hadi aracımı geri getir!", "success")
                            
                            local location = vector3(-614.13, -1599.29, 26.75)
                            local destination = AddBlipForCoord(location.x, location.y, location.z)
                            SetBlipRoute(destination, true) 
                            SetBlipDisplay(destination, 4)
                            
                            Citizen.CreateThread(function()
                                while aracverisi do
                                    Wait(150)
                                    local player = PlayerPedId()
                                    local vehicle = GetVehiclePedIsIn(player, false)
                                    local pedPos = GetEntityCoords(PlayerPedId())
                                    local dist = #(pedPos - vector3(-614.13, -1599.29, 26.75))
                                    
                                    if dist <= 5.0 then
                                        local model = GetEntityModel(vehicle)
                                        if model == GetHashKey("trash") then
                                            DeleteEntity(vehicle)
                                            count = 0
                                            QBCore.Functions.Notify("Mükemmel! İşte paran şimdi kaybol!", "success")
                                            TriggerServerEvent("mto:meslekayarla2", -1)
                                        else
                                            print("Aracın modeli TrashTruck değil!")
                                            count = 0
                                            QBCore.Functions.Notify("Sana verdiğim araçla gelmeliydin!", "error")
                                            TriggerServerEvent("mto:meslekayarla2", -1)
                                        end
                                        
                                        RemoveBlip(destination)
                                        aracverisi = false
                                    end
                                end
                            end)
                            clickedTrashCanEntities = {}
                        end
                        
                      
                        RequestAnimDict("anim@mp_snowball")
                        while not HasAnimDictLoaded("anim@mp_snowball") do
                            Wait(100)
                        end
                        TaskPlayAnim(player, "anim@mp_snowball", "pickup_snowball", 8.0, 8.0, -1, 0, 1, true, true, true)
                        Wait(1500)

                        -- local prop = CreateObject(GetHashKey("prop_cs_rub_binbag_01"), 0, 0, 0, true, true, true)
                        -- AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 57005),0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                    
                    elseif not onDuty and job.name == "copcu" then
                        QBCore.Functions.Notify("Mesain bitti", "error")
                    end
                end
            },
        },
        distance = 1.9,
    })
end)