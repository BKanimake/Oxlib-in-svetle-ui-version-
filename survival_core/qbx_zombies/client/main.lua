local activeZombies = {}
local ZOMBIE_CAP = 10
local ZOMBIE_MODELS = { `u_m_y_zombie_01`, `a_m_m_hillbilly_01` }

local function RequestZombieModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end
end

CreateThread(function()
    for _, model in ipairs(ZOMBIE_MODELS) do
        RequestModel(model)
    end

    while true do
        Wait(2500)
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        -- Despawn distant entities
        for i = #activeZombies, 1, -1 do
            local entity = activeZombies[i]
            if not DoesEntityExist(entity) or #(GetEntityCoords(entity) - pCoords) > 85.0 then
                if DoesEntityExist(entity) then DeleteEntity(entity) end
                table.remove(activeZombies, i)
            end
        end

        -- Spawn up to local density limit
        if #activeZombies < ZOMBIE_CAP and not IsPedInAnyVehicle(playerPed, false) then
            local offset = vector3(pCoords.x + math.random(-30, 30), pCoords.y + math.random(-30, 30), pCoords.z + 10.0)
            local found, groundZ = GetGroundZFor_3dCoord(offset.x, offset.y, offset.z, true)

            if found and #(vector3(offset.x, offset.y, groundZ) - pCoords) > 15.0 then
                local model = ZOMBIE_MODELS[math.random(#ZOMBIE_MODELS)]
                RequestZombieModel(model)

                local ped = CreatePed(4, model, offset.x, offset.y, groundZ, 0.0, true, true)

                SetPedRelationshipGroupHash(ped, `HATES_PLAYER`)
                TaskCombatPed(ped, playerPed, 0, 16)
                SetPedMoveRateOverride(ped, 1.2)
                SetPedSuffersCriticalHits(ped, true) -- Rewards precision headshots

                table.insert(activeZombies, ped)
            end
        end
    end
end)

-- Search Infected via ox_target
exports.ox_target:addGlobalPed({
    {
        name = 'search_infected',
        icon = 'fa-solid fa-radiation',
        label = 'Extract Residue & Parts',
        canInteract = function(entity)
            return IsEntityDead(entity) and not Entity(entity).state.looted
        end,
        onSelect = function(data)
            if lib.progressCircle({
                duration = 3000,
                position = 'bottom',
                label = 'Collecting Samples...',
                useWhileDead = false,
                canCancel = true,
                anim = { dict = 'amb@medic@standing@tendtodead@idle_a', clip = 'idle_a' }
            }) then
                Entity(data.entity).state:set('looted', true, true)
                TriggerServerEvent('qbx_zombies:server:rewardLoot')
            end
        end
    }
})
