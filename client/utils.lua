Utils = {}

Utils.hexToRGB = function(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

Utils.punish = function(ped, reason)
    local playerId = NetworkGetPlayerIndexFromPed(ped)

    print('Punishing ' .. GetPlayerName(playerId) .. ' for ' .. reason)

    -- EDIT

    lib.callback.await('punish.hajden_pdm:server', false, reason);
end

Utils.notify = function(title, description, type)
    lib.notify({
        title = title,
        description = description,
        type = type
    })
end

Utils.getRandomColor = function()
    local colors = {"#FF5733", "#33FF57", "#3357FF", "#FFFF33"} -- List of random colors
    return colors[math.random(#colors)]
end

return Utils