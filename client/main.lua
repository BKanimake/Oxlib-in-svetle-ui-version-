local isRadioOpen = false
local currentChannel = 0
local radioList = {}
local currentCallSign = ''
local hasRadioItem = false -- Assuming they have it or checking via inventory later

-- Core logic to toggle UI
local function ToggleRadio(state)
    isRadioOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        type = 'toggleRadio',
        data = { state = state }
    })

    if state then
        -- Play animation (optional, placeholder)
        ExecuteCommand('e phone')
    else
        ExecuteCommand('e c')
    end
end

-- Command / Export to open radio
RegisterCommand('radio', function()
    -- Only allow if they have the item or no item required
    -- For now, allow it to open to see UI
    ToggleRadio(not isRadioOpen)
end, false)
RegisterKeyMapping('radio', 'Open Radio', 'keyboard', 'F5') -- Default key F5

exports('OpenRadio', function()
    ToggleRadio(true)
end)

-- NUI Callbacks
RegisterNUICallback('closeRadio', function(data, cb)
    ToggleRadio(false)
    cb('ok')
end)

RegisterNUICallback('changeChannel', function(data, cb)
    local channel = tonumber(data.channel)
    if channel and channel >= 0 and channel <= Config.MaxFrequency then
        if currentChannel ~= channel then
            local oldChannel = currentChannel
            currentChannel = channel
            exports['pma-voice']:setRadioChannel(channel)

            if oldChannel > 0 then
                TriggerServerEvent('radio:server:leaveChannel', oldChannel)
            end
            if channel > 0 then
                TriggerServerEvent('radio:server:joinChannel', channel, currentCallSign)
                lib.notify({
                    title = 'Radio',
                    description = 'Switched to channel ' .. channel .. '.0',
                    type = 'success'
                })
            else
                lib.notify({
                    title = 'Radio',
                    description = 'Radio turned off.',
                    type = 'error'
                })
            end
        end
    end
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    currentCallSign = data.callSign or ''
    -- Update server with new callsign if in a channel
    if currentChannel > 0 then
        TriggerServerEvent('radio:server:updateCallSign', currentChannel, currentCallSign)
    end
    lib.notify({
        title = 'Radio',
        description = 'Settings saved.',
        type = 'success'
    })
    cb('ok')
end)

-- Receive radio list updates from server
RegisterNetEvent('radio:client:updateRadioList')
AddEventHandler('radio:client:updateRadioList', function(channel, list)
    if currentChannel == channel then
        radioList = list
        SendNUIMessage({
            type = 'updateRadioList',
            data = { list = radioList }
        })
    end
end)

-- Cuff / Dead Logic Handling (Framework Agnostic-ish, utilizing generic events)
local isDead = false
local isCuffed = false

local function DisconnectRadio()
    if currentChannel > 0 then
        exports['pma-voice']:setRadioChannel(0)
        TriggerServerEvent('radio:server:leaveChannel', currentChannel)
        currentChannel = 0
        if isRadioOpen then
            ToggleRadio(false)
        end
        lib.notify({
            title = 'Radio',
            description = 'Radio disconnected.',
            type = 'error'
        })
    end
end

-- Typical Death Events
AddEventHandler('esx:onPlayerDeath', function()
    isDead = true
    DisconnectRadio()
end)
AddEventHandler('hospital:server:SetDeathStatus', function(isDeadStatus)
    isDead = isDeadStatus
    if isDead then DisconnectRadio() end
end)

-- Typical Cuff Events
AddEventHandler('esx_policejob:handcuff', function()
    isCuffed = not isCuffed
    if isCuffed then DisconnectRadio() end
end)
AddEventHandler('police:client:GetCuffed', function()
    isCuffed = true
    DisconnectRadio()
end)
AddEventHandler('police:client:GetUnCuffed', function()
    isCuffed = false
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isRadioOpen then
            ToggleRadio(false)
        end
        if currentChannel > 0 then
            exports['pma-voice']:setRadioChannel(0)
        end
    end
end)

-- Allow server to trigger open
RegisterNetEvent('radio:client:openRadio')
AddEventHandler('radio:client:openRadio', function()
    ToggleRadio(true)
end)
