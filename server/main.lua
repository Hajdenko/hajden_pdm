lib.locale()

local TCE = TriggerClientEvent

local plate = require('server.plate')
local db = require('server.db')

lib.callback.register('hajden_pdm:serverPurchaseCar', function(source, vehicle, color, price)
    TCE('hajden_pdm:finalizePurchase', source, vehicle, color, price)
end)

lib.callback.register('hajden_pdm:server:purchaseVehicle', function(source, vehicleProps, color)
    player = Config.getPlayer(source)
    if not player then
        print('Player not found for source: ' .. source)
        return false
    end

    if Config.getMoney() >= vehicleProps.price then
        Config.removeMoney(player, vehicleProps.price)

        vehicleProps.plate = plate.getPlate()

        local success = db.insertVehicle(xPlayer.identifier, vehicleProps)
        
        if success then
            return true
        else
            Config.addMoney(player, vehicleProps.price) -- Refund the money
            return false
        end
    else
        TCE('esx:showNotification', source, locale('not_enough_money'))
        return false
    end
end)
