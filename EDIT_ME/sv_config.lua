ESX = exports["es_extended"]:getSharedObject()

sv_config = {
    logging = {
        enabled = true,
        webhooks = { -- you can set one webhook for everything.
            buy = "", -- vehicle buy webhook
            punish = "", -- player punishing webhook
            refund = "", -- refund webhook in case of an error
        }
    },

    playerVehiclesTable = "owned_vehicles", -- qbcore: player_vehicles

    Notify = function(source, message)
        TriggerClientEvent('ox_lib:notify', source, {
            title = "PDM",
            message = message,
            type = "inform"
        })
    end,

    punishPlayer = function(source, reason)
        DropPlayer(source, reason)
        -- currently only works with triggering events
    end,

    getPlayer = function(source)
        return ESX.GetPlayerFromId(source)

        -- QBCore equivalent:
        -- return QBCore.Functions.GetPlayer(source)
    end,

    getIdentifier = function(source)
        return sv_config.getPlayer(source).identifier

        -- QBCore equivalent:
        -- local Player = sv_config.getPlayer(source)
        -- return Player.PlayerData.citizenid or Player.PlayerData.license
    end,

    getMoney = function(source)
        return sv_config.getPlayer(source).getMoney()

        -- QBCore equivalent:
        -- local Player = sv_config.getPlayer(source)
        -- return Player.PlayerData.money['cash']
    end,

    removeMoney = function(source, amount)
        sv_config.getPlayer(source).removeMoney(amount)

        -- QBCore equivalent:
        -- local Player = sv_config.getPlayer(source)
        -- Player.Functions.RemoveMoney('cash', amount)
    end,

    addMoney = function(source, amount)
        sv_config.getPlayer(source).addMoney(amount)

        -- QBCore equivalent:
        -- local Player = sv_config.getPlayer(source)
        -- Player.Functions.AddMoney('cash', amount)
    end,

    vehiclePlatePattern = ESX.GetConfig().CustomAIPlates or "HEY ..." -- Custom plates for AI vehicles
    -- Pattern string format
    --1 will lead to a random number from 0-9.
    --A will lead to a random letter from A-Z.
    -- . will lead to a random letter or number, with a 50% probability of being either.
    --^1 will lead to a literal 1 being emitted.
    --^A will lead to a literal A being emitted.
    --Any other character will lead to said character being emitted.
    -- A string shorter than 8 characters will be padded on the right.
}