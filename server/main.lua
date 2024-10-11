lib.locale()

local TCE = TriggerClientEvent

local plate = require('server.plate')
local db = require('server.db')

lib.callback.register('hajden_pdm:server:purchaseCar', function(source, vehicle, color, price)
    TCE('hajden_pdm:finalizePurchase', source, vehicle, color, price)
end)

lib.callback.register('hajden_pdm:server:finalizePurchase', function(source, vehicleProps, color)
    if not sv_config.getPlayer(source) then
        print('Player not found for source: ' .. source)
        return false
    end

    if sv_config.getMoney(source) >= vehicleProps.price then
        sv_config.removeMoney(source, vehicleProps.price)

        vehicleProps.plate = plate.getPlate()

        local success = db.insertVehicle(sv_config.getIdentifier(source), vehicleProps)
        
        if success then
            if ( sv_config.logging.enabled ) and ( sv_config.logging.webhooks.buy ~= nil ) then
                print("Player "..GetPlayerName(source).." has bought a vehicle. More information on discord.")
                Utils.sendWebhook(sv_config.logging.webhooks.buy, "Car Bought", "Player "..GetPlayerName(source).." has bought a vehicle.", Utils.colors.red, {
                    {name="Model", value=GetDisplayNameFromVehicleModel(vehicleProps.model), inline = true},
                    {name="Plate", value=vehicleProps.plate, inline = true},
                    {name="Color", value=json.encode(vehicleProps.color1), inline = true},
                    {name="Price", value=vehicleProps.price, inline = true},
                })
            end
            return true
        else
            sv_config.addMoney(source, vehicleProps.price) -- Refund the money
            if ( sv_config.logging.enabled ) and ( sv_config.logging.webhooks.refund ~= nil ) then
                print("Refunding Money for player "..GetPlayerName(source).." because of an error in inserting vehicle to the database. More information on discord.")
                Utils.sendWebhook(sv_config.logging.webhooks.refund, "Refunding Money", "Refunding Money for player "..GetPlayerName(source).." because of an error in inserting vehicle to the database.", Utils.colors.red, {
                    {name="Amount Refunded", value=vehicleProps.price, inline = false}
                })
            end
            return false
        end
    else
        sv_config.Notify(source, locale('not_enough_money'))
        return false
    end
end)
