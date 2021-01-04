weeds = {}
created = {}
newtree = {}
ESX = nil 
Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(1)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
end)

RegisterNetEvent('hsn-weed:client:spawnweedprop')
AddEventHandler('hsn-weed:client:spawnweedprop',function(weed)
    for k,v in pairs(weed) do
        CreateObjects(k)
    end
end)

RegisterNetEvent('hsn-weed:spawnweeds')
AddEventHandler('hsn-weed:spawnweeds',function()
    for k,v in pairs(weeds) do
        CreateObjects(k)
    end
end)

RegisterNetEvent('hsn-weed:client:updateweedstatus')
AddEventHandler('hsn-weed:client:updateweedstatus',function(weed,status)
    weeds[weed].weedstatus = status
end)
RegisterNetEvent('hsn-weed:client:Sync')
AddEventHandler('hsn-weed:client:Sync', function(weed)
    for k,v in pairs(weed) do
        weeds[k] = v
    end
end)
local props = {
    'bkr_prop_weed_med_01b',
}

RegisterNetEvent('hsn-weed:client:deleteweed')
AddEventHandler('hsn-weed:client:deleteweed',function()
    for k,v in pairs(newtree) do
        if v ~= 0 then
            --SetEntityAsMissionEntity(v, 1, 1)
            DeleteEntity(v)
            created[k] = false
            -- SetEntityAsNoLongerNeeded(v)
        end

    end
end)



function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	ClearDrawOrigin()
end
function CreateObjects(weed)
    if created[weed] ~= true then
        created[weed] = true
        local neweed = weeds[weed]
        local req = {}
        local treeModel = `bkr_prop_weed_med_01b`
        local zm = 3.55
        RequestModel(treeModel)
        while not HasModelLoaded(treeModel) do
            Citizen.Wait(100)
        end

        newtree = CreateObject(treeModel,neweed.coords.x,neweed.coords.y,neweed.coords.z-zm,true,false,false)
        SetEntityCollision(newtree,true,true)
    end
end
GetStatusFromWeedId = function(id)
    neweed = weeds[id]
    local req = {}
    if neweed.weedstatus <= 10 then
        zm = 1
        req.requireditem = Config.RequiredItems[1].item
        req.text = '1 tane '..Config.RequiredItems[1].label..' gerekiyor '..'%'..neweed.weedstatus
        return req
    elseif neweed.weedstatus <= 20 then
        req.requireditem = Config.RequiredItems[1].item
        req.text = '1 tane '..Config.RequiredItems[1].label..' gerekiyor '..'%'..neweed.weedstatus
        return req
    elseif neweed.weedstatus <= 50 then
        req.requireditem = Config.RequiredItems[1].item
        req.text = '1 tane '..Config.RequiredItems[1].label..' gerekiyor '..'%'..neweed.weedstatus
        return req
    elseif neweed.weedstatus <= 70 then
        req.requireditem = Config.RequiredItems[1].item
        req.text = '1 tane '..Config.RequiredItems[1].label..' gerekiyor '..'%'..neweed.weedstatus
        return req
    elseif neweed.weedstatus <= 80 then
        req.requireditem = Config.RequiredItems[2].item
        req.text = '1 tane '..Config.RequiredItems[2].label..' gerekiyor '..'%'..neweed.weedstatus
        return req
    elseif neweed.weedstatus <= 90 then
        req.requireditem = Config.RequiredItems[2].item
        req.text = '1 tane '..Config.RequiredItems[2].label..' gerekiyor '..'%'..neweed.weedstatus
        return req
    elseif neweed.weedstatus <= 99 then   
        req.requireditem = Config.RequiredItems[2].item
        req.text = '1 tane '..Config.RequiredItems[2].label..' gerekiyor '..'%'..neweed.weedstatus
        return req 
    elseif neweed.weedstatus >= 100 then
        req.requireditem = Config.RequiredItems[2].item
        req.text = 'Toplanabilir %100'
        return req
    end
end


Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if weeds ~= nil then
            for k,v in pairs(weeds) do
                distance = #(GetEntityCoords(PlayerPedId()) - vector3(v.coords.x, v.coords.y, v.coords.z))
                if distance <= 5.0 then
                    local state = GetStatusFromWeedId(k)
                    text = 'Kenevir'
                    wait = 1
                    if distance <= 1.5 then
                        text = 'E -'..state.text
                        if IsControlJustPressed(1, 38) then
                            TriggerServerEvent('hsn-weed:server:updateweedstate',k, state.requireditem)
                        end
                    end
                    DrawText3Ds(v.coords.x,v.coords.y,v.coords.z,text)
                end
            end
        end
        Citizen.Wait(wait)
    end
end)