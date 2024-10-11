cl_config = {
    punishPlayer = function(ped, reason)
        local playerId = NetworkGetPlayerIndexFromPed(ped)
    
        -- EDIT
    
        lib.callback.await('punish.hajden_pdm:server', false, reason);
    end,

    Notify = function(description, type, title, duration)
        if not description then print("notifications description is missing") return end
        return lib.notify({
            title = title or "PDM",
            description = description,
            type = type or "inform",
            duration = duration or 3000
        })
    end,

    getPlayerJob = function()
        return ESX.GetPlayerData().job
    end
}
