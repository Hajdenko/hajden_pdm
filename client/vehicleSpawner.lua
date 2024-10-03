VehicleSpawner = {}

VehicleSpawner.spawnVehicle = function(vehicle, color, price)
    local playerPed = PlayerPedId()
    local coords = (type(price) == "table") and price or GetEntityCoords(playerPed) --mb price could be coords
    local vehicleModel = GetHashKey(vehicle.model)
    
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(100)
    end

    local spawnedVehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, (coords.h and coords.h or GetEntityHeading(playerPed)), true, false)
    SetVehicleCustomPrimaryColour(spawnedVehicle, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(spawnedVehicle, color.r, color.g, color.b)

    TaskWarpPedIntoVehicle(playerPed, spawnedVehicle, -1)

    local vehiclePlate = GetVehicleNumberPlateText(spawnedVehicle)

    local vehicleProps = lib.getVehicleProperties(spawnedVehicle)
    vehicleProps.plate = vehiclePlate
    vehicleProps.price = price
    vehicleProps.fuelLevel = 100.0

    return spawnedVehicle, vehicleProps
end

return VehicleSpawner