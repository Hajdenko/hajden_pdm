ESX = exports["es_extended"]:getSharedObject()
lib.locale()

local TCE = TriggerClientEvent

local plate = require('server.plate')
local db = require('server.db')

lib.callback.register('hajden_pdm:serverPurchaseCar', function(source, vehicle, color, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        TCE('hajden_pdm:finalizePurchase', source, vehicle, color, price)
    else
        print('Player not found for source: ' .. source)
    end
end)

lib.callback.register('hajden_pdm:server:purchaseVehicle', function(source, vehicleProps, color)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print('Player not found for source: ' .. source)
        return false
    end

    if xPlayer.getMoney() >= vehicleProps.price then
        xPlayer.removeMoney(vehicleProps.price)

        vehicleProps.plate = plate.getPlate()

        local success = db.insertVehicle(xPlayer.identifier, vehicleProps)
        
        if success then
            print('Vehicle purchase successful for player: ' .. xPlayer.identifier)
            return true
        else
            print('Database insertion failed for player: ' .. xPlayer.identifier)
            xPlayer.addMoney(vehicleProps.price) -- Refund the money
            return false
        end
    else
        TCE('esx:showNotification', source, locale('not_enough_money'))
        return false
    end
end)