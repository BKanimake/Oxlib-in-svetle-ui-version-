local isRiding = false
local currentRide = nil
local rideCam = nil

-- Display help notification standard
local function ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- 0.00ms Main Optimization Thread
CreateThread(function()
    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()

        if not isRiding and DoesEntityExist(playerPed) then
            local pCoords = GetEntityCoords(playerPed)

            for rideId, ride in pairs(Config.Rides) do
                local dist = #(pCoords - ride.entryCoords)

                if dist < Config.DrawDistance then
                    sleep = 0
                    DrawMarker(1, ride.entryCoords.x, ride.entryCoords.y, ride.entryCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 0, 150, 255, 100, false, true, 2, false, nil, nil, false)

                    if dist < Config.InteractDistance then
                        ShowHelpNotification(ride.prompt)
                        if IsControlJustReleased(0, Config.InteractKey) then
                            TriggerServerEvent('delperro_pier:sv_startRide', rideId)
                        end
                    end
                elseif dist < 50.0 then
                    if sleep > 500 then sleep = 500 end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Ride Events
RegisterNetEvent('delperro_pier:cl_startRide', function(rideId)
    local ride = Config.Rides[rideId]
    if not ride then return end

    isRiding = true
    currentRide = rideId

    local playerPed = PlayerPedId()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end

    -- Position player in ride
    SetEntityCoords(playerPed, ride.entryCoords.x, ride.entryCoords.y, ride.entryCoords.z, false, false, false, false)
    FreezeEntityPosition(playerPed, true)

    -- Setup cinematic camera if available
    rideCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(rideCam, ride.entryCoords.x, ride.entryCoords.y, ride.entryCoords.z + 2.0)
    SetCamRot(rideCam, 0.0, 0.0, 0.0, 2)
    SetCamActive(rideCam, true)
    RenderScriptCams(true, true, 500, true, true)

    DoScreenFadeIn(500)

    -- Ride interaction thread during ride
    CreateThread(function()
        local startTime = GetGameTimer()
        local durationMs = (ride.duration or 30) * 1000

        while isRiding and (GetGameTimer() - startTime < durationMs) do
            Wait(0)
            ShowHelpNotification("Press ~INPUT_CELLPHONE_CANCEL~ or ~INPUT_VEH_EXIT~ to exit ride early")

            if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 23) then -- Backspace / F / Enter vehicle exit
                break
            end
        end

        -- Exit ride logic
        TriggerEvent('delperro_pier:cl_exitRide', rideId)
    end)
end)

RegisterNetEvent('delperro_pier:cl_exitRide', function(rideId)
    local ride = Config.Rides[rideId]
    local playerPed = PlayerPedId()

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end

    if rideCam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(rideCam, false)
        rideCam = nil
    end

    if ride and ride.exitCoords then
        SetEntityCoords(playerPed, ride.exitCoords.x, ride.exitCoords.y, ride.exitCoords.z, false, false, false, false)
    end

    FreezeEntityPosition(playerPed, false)
    isRiding = false
    currentRide = nil

    DoScreenFadeIn(500)
end)

RegisterNetEvent('delperro_pier:cl_syncRideState', function(rideId, state)
    -- Handle ride sync
end)
