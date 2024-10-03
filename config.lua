Config = {}

--[[
Possible to leave description empty, will result in no description.
Possible to leave icon/iconColor empty, will result in a default icon/iconColor.
]]

Config.Unit = "km" -- or mp (WILL ADD /h AUTOMATICALLY IF NEEDED)

Config.Disables = {
    invisibleDuringTestDrive = "enabled";
    icons = "enabled",
    testDrive = "enabled",
    vehStats = "enabled"
}

Config.Categories = {
    {
        name = "Sports",
        icon = "bars",
        iconColor = "#ffffff",
        vehicles = {
            {
                name = "Adder", model = "adder", 
                icon = "bars", iconColor = "#ffffff", 
                price = 100000, description = "This is a description",
                -- You can leave it empty, but no stats will be shown to the player about the vehicle
                stats = {
                    maxspeed = "200", -- your units
                    acceleration = "3.7", -- seconds
                    braking = "1.9",
                    handling = "7",
                    steering = "5"
                }
            },
            {name = "Banshee", model = "banshee", price = 80000}
        }
    },
    {
        name = "SUVs",
        icon = "bars",
        iconColor = "#ffffff",
        vehicles = {
            {name = "Baller", model = "baller", price = 60000},
            {name = "Granger", model = "granger", price = 50000}
        }
    }
}

Config.TestDrive = {
    -- You can disable TestDrive in Config.Disables
    Time = 60,
    Locations = {
        { x=-401.3283, y=1209.4569, z=325.9423, h=345.7479 },
        --{ x = 2800.0452, y = -3800.2119, z = 140.0890, h = 356.6177 },
        --{ x = 2719.8813, y = -3800.0520, z = 139.9889, h = 266.8519 },
        --{ x = 2880.1096, y = -3800.2295, z = 139.9889, h = 91.7169 },
        --{ x = 2920.4221, y = -3891.5068, z = 141.0009, h = 106.0717 },
        --{ x = 2940.6335, y = -3717.8071, z = 141.0012, h = 57.2322 },
        --{ x = 2679.6968, y = -3708.4382, z = 141.0009, h = 285.3845 },
        --{ x = 2659.2209, y = -3882.0217, z = 141.0009, h = 242.4512 }
    }
}


-- SERVER FUNCTION --
Config.getMoney = function(source)
    ESX = exports["es_extended"]:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(source)

    return xPlayer.getMoney()
end
Config.removeMoney = function(source, amount)
    ESX = exports["es_extended"]:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeMoney(amount)
end
