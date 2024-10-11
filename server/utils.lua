lib.locale()

lib.callback.register('punish.hajden_pdm:server', function(source, reason)
    if ( sv_config.logging.enabled ) and ( sv_config.logging.webhooks.punish ~= nil ) then
        print("Punishing the player ".. GetPlayerName(source) .." on server side..")
        Utils.sendWebhook(sv_config.logging.webhooks.punish, "Punishing Player", "Player ".. GetPlayerName(source) .." is being punished for: "..reason, Utils.colors.red)
    end
    
    sv_config.punish(source, reason)
end)

Utils = {}

Utils.colors = {
    red = 16711680,      -- RGB: 255, 0, 0
    green = 65280,       -- RGB: 0, 255, 0
    blue = 255,          -- RGB: 0, 0, 255
    yellow = 16776960,   -- RGB: 255, 255, 0
    purple = 8388736,    -- RGB: 128, 0, 128
    orange = 16753920,   -- RGB: 255, 165, 0
    cyan = 65535,        -- RGB: 0, 255, 255
    pink = 16761035,     -- RGB: 255, 105, 180
    white = 16777215,    -- RGB: 255, 255, 255
    black = 0,           -- RGB: 0, 0, 0
    gray = 8421504,      -- RGB: 128, 128, 128
    brown = 10824234,    -- RGB: 165, 42, 42
    lightblue = 10092339 -- RGB: 173, 216, 230
}

Utils.sendWebhook = function(webhookUrl, title, description, color, fields)
    local embed = {
        {
            ["title"] = title or "Premium Deluxe Motorsport",
            ["description"] = description,
            ["color"] = color or color.blue,
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = GetCurrentResourceName(),
                ["icon_url"] = "https://i.imgur.com/HdO6jpI.png"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers)
        if err ~= 200 or err ~= 204 then
            print("Failed to send webhook: Error " .. tostring(err))
        end
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end

return Utils