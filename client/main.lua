local isRiding = false
local currentRide = nil
local rideCam = nil
local currentCamIndex = 1

-- Display help notification standard
local function ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Camera creation & attachment helper
local function SetRideCameraMode(ped, ride, camIndex)
    if not ride or not ride.cameras or #ride.cameras == 0 then return end

    local camConfig = ride.cameras[camIndex]
    if not camConfig then return end

    if not rideCam then
        rideCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end

    AttachCamToEntity(rideCam, ped, camConfig.offset.x, camConfig.offset.y, camConfig.offset.z, true)
    SetCamRot(rideCam, camConfig.rot.x, camConfig.rot.y, camConfig.rot.z, 2)
    SetCamActive(rideCam, true)
    RenderScriptCams(true, true, 500, true, true)
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
    currentCamIndex = 1

    local playerPed = PlayerPedId()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end

    -- Position player in ride
    SetEntityCoords(playerPed, ride.entryCoords.x, ride.entryCoords.y, ride.entryCoords.z, false, false, false, false)
    FreezeEntityPosition(playerPed, true)

    -- Play hands-up / story mode ride anim
    RequestAnimDict("anim@arena@celeb@flat@solo@no_hands@")
    while not HasAnimDictLoaded("anim@arena@celeb@flat@solo@no_hands@") do
        Wait(10)
    end
    TaskPlayAnim(playerPed, "anim@arena@celeb@flat@solo@no_hands@", "cheering_a", 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Setup initial Story Mode camera view attached to player body
    SetRideCameraMode(playerPed, ride, currentCamIndex)

    DoScreenFadeIn(500)

    -- Ride interaction & multi-camera switch thread
    CreateThread(function()
        local startTime = GetGameTimer()
        local durationMs = (ride.duration or 30) * 1000

        while isRiding and (GetGameTimer() - startTime < durationMs) do
            Wait(0)
            local currentCamName = ride.cameras[currentCamIndex] and ride.cameras[currentCamIndex].name or "Camera"
            ShowHelpNotification("Press ~INPUT_NEXT_CAMERA~ to change camera [" .. currentCamName .. "] | ~INPUT_CELLPHONE_CANCEL~ or ~INPUT_VEH_EXIT~ to exit")

            -- Cycle Camera View on [V] / INPUT_NEXT_CAMERA (control 0 or 26)
            if IsControlJustReleased(0, 0) or IsControlJustReleased(0, 26) then
                currentCamIndex = currentCamIndex + 1
                if currentCamIndex > #ride.cameras then
                    currentCamIndex = 1
                end
                SetRideCameraMode(playerPed, ride, currentCamIndex)
            end

            -- Exit Early on Backspace / F / Exit Key
            if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 23) then
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

    ClearPedTasks(playerPed)

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
