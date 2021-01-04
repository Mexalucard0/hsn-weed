ESX = nil
TriggerEvent('esx:getSharedObject',function(obj)
    ESX = obj
end)
weeds = {}
inhouse = {}
RegisterServerEvent('hsn-weed:spawnweed')
AddEventHandler('hsn-weed:spawnweed', function(coord)
    local id = math.random(11111,99999)
    local src = source
    weeds[id] = {
        pressed = false,
        weedstatus = 0,
        coords = coord,
        weedid = id,               
    }
    TriggerClientEvent('hsn-weed:client:Sync', -1, weeds)
    Citizen.Wait(1500)
    TriggerClientEvent('hsn-weed:client:spawnweedprop',-1,weeds)
end)

RegisterServerEvent("hsn-weedsystem:stashcheck")
AddEventHandler("hsn-weedsystem:stashcheck", function(data)
    local player = ESX.GetPlayerFromId(source)
    inhouse[player.identifier] = data
end)

RegisterServerEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(playerId, xPlayer)
    local src = playerId
    TriggerClientEvent('hsn-weed:client:Sync', -1, weeds)
    Citizen.Wait(5000)
    TriggerClientEvent('hsn-weed:client:spawnweedprop',-1,weeds)
end)

exports["ghmattimysql"]:ready(function()
    local result = exports.ghmattimysql:executeSync('SELECT * FROM hsn_weed')
    for i = 1, #result do
        result[i].coords = json.decode(result[i].coords)
        weeds[result[i].weedid] = result[i]
    end
end)



ESX.RegisterUsableItem("femaleseed", function(source)
    
    local player = ESX.GetPlayerFromId(source)
    if inhouse[player.identifier] then
        local saksi = player.getInventoryItem("pot")
        if saksi.count >= 1 then
            local coord = player.getCoords()
            local id = math.random(11111,99999)
            local src = source
            weeds[id] = {
                pressed = false,
                weedstatus = 0,
                coords = coord,
                weedid = id,               
            }
            player.removeInventoryItem("pot", 1)
            player.removeInventoryItem("femaleseed", 1)
            TriggerClientEvent('hsn-weed:client:Sync', -1, weeds)
            Citizen.Wait(1500)
            TriggerClientEvent('hsn-weed:client:spawnweedprop',-1,weeds)
            print(id)
            print(coord)
            exports.ghmattimysql:execute('INSERT INTO hsn_weed (weedid, coords, weedstatus) VALUES (@weedid, @coords, @weedstatus)', {
                ['@weedid']   =  id,
                ['@coords']   = json.encode(coord),
                ['@weedstatus'] = 0
            }, function(rowsChanged)
            end)
        else
            TriggerClientEvent("notification", source, "Bunu yapmak için saksıya ihtiyacın var!")
        end
    else
        TriggerClientEvent("notification", source, "Bunu yapmak için evinde olman gerek!")
    end
end)

RegisterServerEvent('hsn-weed:server:updateweedstate')
AddEventHandler('hsn-weed:server:updateweedstate',function(weed,item)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local stat = math.random(1,5)
    if Player.getInventoryItem(item).count >= 1 then
        if not weeds[weed].pressed then
            if weeds[weed].weedstatus  >= 100 then
                Player.addInventoryItem('weedq',15)
                TriggerClientEvent('notification',src,'Keneviri tamamen işlediniz',3)
                TriggerClientEvent('hsn-weed:client:deleteweed',-1,weed)
                weeds[weed] = nil
                return
            end
            weeds[weed].pressed = true
            weeds[weed].weedstatus = weeds[weed].weedstatus + stat
            exports.ghmattimysql:execute("UPDATE hsn_weed SET weedstatus = '"..weeds[weed].weedstatus.. "' WHERE weedid = '" ..weed.. "'")
            TriggerClientEvent('hsn-weed:client:updateweedstatus',-1,weed,weeds[weed].weedstatus)
            Player.removeInventoryItem(item, 1)
        else
            TriggerClientEvent('notification',src,'Kenevirin işlenmesi için biraz beklemeniz gerekiyor',2)
        end
    else
        TriggerClientEvent('notification',src,'Yeterli eşyaya sahip değilsin',2)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000 * 60 * Config.WaitPressMinute)
        for k,v in pairs(weeds) do
            if v.pressed then
                v.pressed = false
            end
        end
    end
end)


ESX.RegisterServerCallback('hsn-weed:server:getItem',function(source,cb,item)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Player then
        if Player.getInventoryItem(item).count >= 1 then
            cb(true)
        else
            cb(false)
        end
    end
end)

