lib.locale()

local TE = TriggerEvent

---@type table
local Utils = require('client.utils')
---@type table
local VehicleSpawner = require('client.vehicleSpawner')

local function openVehicleShopMenu()
    if #Config.Categories == 1 then
        TE('hajden_pdm:showCars', Config.Categories[1].vehicles)
    else
        local options = {}
        for _, category in ipairs(Config.Categories) do
            table.insert(options, {
                title = category.name,
                icon = (Config.Disables.icons == "enabled") and category.icon or "bars",
                iconColor = (Config.Disables.icons == "enabled") and category.iconColor or "#ffffff",
                description = locale('category_description', category.name),
                event = 'hajden_pdm:showCars',
                args = category.vehicles
            })
        end

        lib.registerContext({
            id = 'pdm_menu',
            title = locale('vehicle_categories'),
            options = options
        })

        lib.showContext('pdm_menu')
    end
end

RegisterCommand('pdm', function()
    openVehicleShopMenu()
end)

---@param vehicles table
RegisterNetEvent('hajden_pdm:showCars')
AddEventHandler('hajden_pdm:showCars', function(vehicles)
    local options = {}
    for _, vehicle in ipairs(vehicles) do
        table.insert(options, {
            title = vehicle.name,
            icon = (Config.Disables.icons == "enabled") and vehicle.icon or "car",
            iconColor = (Config.Disables.icons == "enabled") and vehicle.iconColor or "#ffffff",
            description = locale('vehicle_description', vehicle.price, vehicle.description and " - "..vehicle.description or ""),
            event = 'hajden_pdm:vehicleOptions',
            args = vehicle
        })
    end

    lib.registerContext({
        id = 'car_menu',
        title = locale('available_cars'),
        menu = 'pdm_menu',
        options = options
    })

    lib.showContext('car_menu')
end)

---@param originCoords vector3
---@param vehicle number|nil
local function endTestDrive(originCoords, vehicle)
    local playerPed = cache.ped
    SetEntityCoords(playerPed, originCoords)
    SetEntityVisible(playerPed, true, false)

    local vehicleEntity = vehicle or GetVehiclePedIsIn(playerPed, false)

    NetworkSetEntityInvisibleToNetwork(vehicleEntity, false)
    if vehicleEntity then
        DeleteEntity(vehicleEntity)
    end

    lib.hideTextUI()
    lib.showContext('vehicle_options_menu')
end

---@param vehicle number
local function safeVehDelete(vehicle)
    if DoesEntityExist(vehicle) then
        if NetworkGetEntityIsNetworked(vehicle) then
            NetworkRequestControlOfEntity(vehicle)
            local timeout = GetGameTimer() + 5000
            while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do
                Wait(0)
            end

            if NetworkHasControlOfEntity(vehicle) then
                SetEntityAsMissionEntity(vehicle, false, true)
                DeleteEntity(vehicle)
            else
                SetEntityAsMissionEntity(vehicle, false, true)
                DeleteVehicle(vehicle)
            end
        else
            SetEntityAsMissionEntity(vehicle, false, true)
            DeleteEntity(vehicle)
        end
    end
end

local function checkVehicleStats(vehicle)
    return vehicle and vehicle.stats and (
        vehicle.name and 
        vehicle.price and 
        vehicle.stats.maxspeed and 
        vehicle.stats.acceleration and 
        vehicle.stats.braking and 
        vehicle.stats.handling and 
        vehicle.stats.steering
    );
end

---@param vehicle table
RegisterNetEvent('hajden_pdm:startTestDrive')
AddEventHandler('hajden_pdm:startTestDrive', function(vehicle)
    if Config.Disables.testDrive == "enabled" then
        lib.hideTextUI()
        local coords = Config.TestDrive.Locations[math.random(#Config.TestDrive.Locations)]

        if Config.Disables.invisibleDuringTestDrive == "enabled" then
            local playerPed = cache.ped
            SetEntityVisible(playerPed, false, false)
            NetworkSetEntityInvisibleToNetwork(GetVehiclePedIsIn(playerPed, false), true)
        end

        DoScreenFadeOut(1000)
        Wait(1000)

        local originalCoords = GetEntityCoords(cache.ped)
        local spawnedVehicle = VehicleSpawner.spawnVehicle(vehicle, Utils.getRandomColor(), coords)

        local remainingTime = Config.TestDrive.Time
        lib.showTextUI(locale('remaining_time_cooldown', remainingTime), {
            position = "left-center",
            icon = 'clock',
            style = {
                borderRadius = 5
            }
        })

        Wait(500)
        DoScreenFadeIn(1000)

        CreateThread(function()
            while remainingTime > 0 do
                remainingTime = remainingTime - 1
                lib.showTextUI(locale('remaining_time_cooldown', remainingTime), {
                    position = "left-center",
                    icon = 'clock',
                    style = {
                        borderRadius = 5
                    }
                })

                if not IsPedInAnyVehicle(cache.ped, false) then
                    break
                end

                Wait(1000)
            end

            endTestDrive(originalCoords, spawnedVehicle)
        end)
    else
        Utils.punish(cache.ped, "Triggering Events")
    end
end)

---@param vehicle table
RegisterNetEvent('hajden_pdm:purchaseCar')
AddEventHandler('hajden_pdm:purchaseCar', function(vehicle)
    lib.hideTextUI()

    local input = lib.inputDialog(locale('choose_color'), {
        {
            type = 'color',
            label = locale('color'),
            default = '#FFFFFF'
        }
    })

    if not input or not input[1] then return end
    local chosenColor = input[1]

    local alert = lib.alertDialog({
        title = locale('confirm_purchase'),
        content = locale('purchase_confirm', vehicle.price),
        centered = true,
        cancel = true,
        labels = {
            confirm = locale('yes'),
            cancel = locale('no')
        }
    })

    if alert == "confirm" then
        local r, g, b = Utils.hexToRGB(chosenColor)
        lib.callback.await('hajden_pdm:serverPurchaseCar', false, vehicle, {r = r, g = g, b = b}, vehicle.price)
    end
end)

---@param vehicle table
RegisterNetEvent('hajden_pdm:vehicleStats')
AddEventHandler('hajden_pdm:vehicleStats', function(vehicle)
    content = [[
        {veh_name}
        {veh_price}
        {veh_maxspeed} {units_per_hour}
        {veh_acc} s (0-100 {units_per_hour})
        {veh_braking} m (100-0 {units_per_hour})
        {veh_handling}/10
        {veh_steering}/10
    ]]

    content = string.gsub(content, "{units_per_hour}", Config.Unit.."/h")

    content = string.gsub(content, "{veh_name}",      locale("stats_vehname")..": "..vehicle.name)
    content = string.gsub(content, "{veh_price}",     locale("stats_vehprice")..": $"..vehicle.price or "N/A")
    content = string.gsub(content, "{veh_maxspeed}",  locale("stats_vehmaxSpeed")..": "..vehicle.stats.maxspeed or "N/A")
    content = string.gsub(content, "{veh_acc}",       locale("stats_vehacceleration")..": "..vehicle.stats.acceleration or "N/A")
    content = string.gsub(content, "{veh_braking}",   locale("stats_vehbraking")..": "..vehicle.stats.braking or "N/A")
    content = string.gsub(content, "{veh_handling}",  locale("stats_vehhandling")..": "..vehicle.stats.handling or "N/A")
    content = string.gsub(content, "{veh_steering}",  locale("stats_vehsteering")..": "..vehicle.stats.steering or "N/A")

    lib.alertDialog({
        header = '🚗 Vehicle Statistics',
        content = content,
        centered = true
    })

    lib.showContext('vehicle_options_menu')
end)

---@param vehicle table
RegisterNetEvent('hajden_pdm:vehicleOptions')
AddEventHandler('hajden_pdm:vehicleOptions', function(vehicle)
    local options = {
        {
            title = locale('buy_car'),
            description = locale('purchase_description', vehicle.price),
            event = 'hajden_pdm:purchaseCar',
            args = vehicle
        },
    }

    if Config.Disables.testDrive == "enabled" then
        table.insert(options, {
            title = locale('test_drive'),
            description = locale('test_drive_description'),
            event = 'hajden_pdm:startTestDrive',
            args = vehicle
        })
    end

    if Config.Disables.vehStats == "enabled" and checkVehicleStats(vehicle) then
        table.insert(options, {
            title = locale('vehicle_stats'),
            description = locale('vehicle_stats_description'),
            event = 'hajden_pdm:vehicleStats',
            args = vehicle
        })
    end

    if options[2] then
        lib.registerContext({
            id = 'vehicle_options_menu',
            title = locale('vehicle_options'),
            menu = "car_menu",
            options = options
        })
    
        lib.showContext('vehicle_options_menu')
        return;
    end

    TE("hajden_pdm:purchaseCar", vehicle)
end)

---@param vehicle table
---@param color table
---@param price number
RegisterNetEvent('hajden_pdm:finalizePurchase')
AddEventHandler('hajden_pdm:finalizePurchase', function(vehicle, color, price)
    DoScreenFadeOut(1000)
    Wait(1000)
    local spawnedVehicle, vehicleProps = VehicleSpawner.spawnVehicle(vehicle, color, price)

    local success = lib.callback.await('hajden_pdm:server:purchaseVehicle', false, vehicleProps, color)

    if success then
        Utils.notify(locale('purchase_success'), locale('enjoy_vehicle'), 'success')
    else
        Utils.notify(locale('purchase_failed'), locale('not_enough_money'), 'error')
    end

    Wait(500)
    safeVehDelete(spawnedVehicle)
    DoScreenFadeIn(1000)
end)


shutdown = function()
    lib.closeAlertDialog()
    lib.hideTextUI()

    SetEntityVisible(cache.ped, true)
end

RegisterNetEvent('esx:onPlayerLogout', shutdown)

local RES_NAME = GetCurrentResourceName()
AddEventHandler('onResourceStop', function(resourceName)
    if (RES_NAME ~= resourceName) then return end

    shutdown()
end)