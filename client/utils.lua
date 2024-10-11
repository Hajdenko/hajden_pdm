Utils = {}

Utils.hexToRGB = function(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

Utils.getRandomColor = function()
    local colors = {"#FF5733", "#33FF57", "#3357FF", "#FFFF33"} -- List of random colors
    return colors[math.random(#colors)]
end

return Utils