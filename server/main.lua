lib.locale()

local TCE = TriggerClientEvent

local plate = require('server.plate')
local db = require('server.db')

lib.callback.register('hajden_pdm:serverPurchaseCar', function(source, vehicle, color, price)
    TCE('hajden_pdm:finalizePurchase', source, vehicle, color, price)
end)

lib.callback.register('hajden_pdm:server:purchaseVehicle', function(source, vehicleProps, color)
    if not Config.getPlayer(source) then
        print('Player not found for source: ' .. source)
        return false
    end

    if Config.getMoney(source) >= vehicleProps.price then
        Config.removeMoney(source, vehicleProps.price)

        vehicleProps.plate = plate.getPlate()

        local success = db.insertVehicle(Config.getIdentifier(source), vehicleProps)
        
        if success then
            return true
        else
            Config.addMoney(source, vehicleProps.price) -- Refund the money
            return false
        end
    else
        Config.Notify(source, locale('not_enough_money'))
        return false
    end
end)
