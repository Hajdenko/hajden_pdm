local db = {}

db.insertVehicle = function(owner, vehicleProps)
    local success = false
    MySQL.Async.execute('INSERT INTO ' .. ( Config.playerVehiclesTable or 'owned_vehicles' ) .. ' (owner, plate, vehicle, stored) VALUES (@owner, @plate, @vehicle, @stored)', {
        ['@owner']   = owner,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@stored']  = 1
    }, function(rowsChanged)
        if rowsChanged > 0 then
            success = true
        end
    end)
    
    -- Wait for the async operation to complete
    while success == false do
        Wait(0)
    end
    
    return success
end

db.select = function(query, params)
    return MySQL.query.await(query, params)
end

return db
