local RadioChannels = {} -- Structure: { [channel] = { [source] = "CallSign" } }

-- Helper function to format list
local function GetChannelList(channel)
    local list = {}
    if RadioChannels[channel] then
        for src, name in pairs(RadioChannels[channel]) do
            table.insert(list, name)
        end
    end
    return list
end

-- Helper to broadcast only to channel members
local function BroadcastChannelUpdate(channel)
    if not RadioChannels[channel] then return end
    local list = GetChannelList(channel)
    for src, _ in pairs(RadioChannels[channel]) do
        TriggerClientEvent('radio:client:updateRadioList', src, channel, list)
    end
end

-- Handle joining a channel
RegisterNetEvent('radio:server:joinChannel')
AddEventHandler('radio:server:joinChannel', function(channel, callSign)
    local src = source

    -- Leave current channel first if they were in one (cleanup just in case)
    for ch, members in pairs(RadioChannels) do
        if members[src] then
            members[src] = nil
            BroadcastChannelUpdate(ch)
        end
    end

    if channel > 0 then
        if not RadioChannels[channel] then
            RadioChannels[channel] = {}
        end

        -- Add to new channel
        local displayName = callSign ~= '' and callSign or ("Citizen " .. src)
        RadioChannels[channel][src] = displayName

        -- Broadcast update to everyone in this channel
        BroadcastChannelUpdate(channel)
    end
end)

-- Handle leaving a channel
RegisterNetEvent('radio:server:leaveChannel')
AddEventHandler('radio:server:leaveChannel', function(channel)
    local src = source
    if RadioChannels[channel] and RadioChannels[channel][src] then
        RadioChannels[channel][src] = nil
        BroadcastChannelUpdate(channel)
    end
end)

-- Update callsign while in a channel
RegisterNetEvent('radio:server:updateCallSign')
AddEventHandler('radio:server:updateCallSign', function(channel, callSign)
    local src = source
    if RadioChannels[channel] and RadioChannels[channel][src] then
        local displayName = callSign ~= '' and callSign or ("Citizen " .. src)
        RadioChannels[channel][src] = displayName
        BroadcastChannelUpdate(channel)
    end
end)

-- Cleanup on drop
AddEventHandler('playerDropped', function(reason)
    local src = source
    for ch, members in pairs(RadioChannels) do
        if members[src] then
            members[src] = nil
            BroadcastChannelUpdate(ch)
        end
    end
end)

-- Item usability (Framework Agnostic Support)
if GetResourceState('ox_inventory') == 'started' then
    exports('radio', function(event, item, inventory, slot, data)
        if event == 'usingItem' then
            TriggerClientEvent('radio:client:openRadio', inventory.id)
            return false
        end
    end)
elseif GetResourceState('es_extended') == 'started' then
    local ESX = exports['es_extended']:getSharedObject()
    ESX.RegisterUsableItem(Config.RadioItem, function(source)
        TriggerClientEvent('radio:client:openRadio', source)
    end)
elseif GetResourceState('qb-core') == 'started' then
    local QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.CreateUseableItem(Config.RadioItem, function(source, item)
        TriggerClientEvent('radio:client:openRadio', source)
    end)
end
