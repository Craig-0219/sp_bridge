function sp.getOnlinePlayers()
    return #GetPlayers()
end

exports('GetOnlinePlayers', function()
    return sp.getOnlinePlayers()
end)
