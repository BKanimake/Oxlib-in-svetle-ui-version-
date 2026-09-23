local sanity = 100.0
local inPollutionZone = false
local currentZoneName = ""

local hotZones = {
    { coords = vector3(2443.0, 4975.0, 46.0), radius = 250.0, name = "Toxic Basin" },
    { coords = vector3(980.0, -135.0, 74.0), radius = 300.0, name = "Infested Core" },
    { coords = vector3(2155.0, 2921.0, 48.0), radius = 200.0, name = "Quarry Stardust Anomaly" }
}

for _, zone in ipairs(hotZones) do
    lib.points.new({
        coords = zone.coords,
        distance = zone.radius,
        onEnter = function()
            inPollutionZone = true
            currentZoneName = zone.name
            SetTimecycleModifier('drug_wobbly')
            SetTimecycleModifierStrength(0.45)
            lib.notify({
                title = 'Contamination Alert',
                description = 'Entering high Stardust pollution area: ' .. zone.name,
                type = 'error'
            })
        end,
        onExit = function()
            inPollutionZone = false
            currentZoneName = ""
            ClearTimecycleModifier()
            lib.notify({
                title = 'Zone Cleared',
                description = 'Left contaminated area. Air purity restored.',
                type = 'inform'
            })
        end
    })
end

CreateThread(function()
    while true do
        Wait(2000)
        local ped = PlayerPedId()

        if inPollutionZone and not IsEntityDead(ped) then
            local hasMask = exports.ox_inventory:Search('count', 'gas_mask') > 0

            -- Check client-side cached skill node state
            local hasImmunity = false
            if GetResourceState('qbx_skills') == 'started' then
                hasImmunity = exports.qbx_skills:HasNodeUnlockedClient('surv_toxin_res_1')
            end

            local baseDrain = hasMask and 1.0 or 4.0
            if hasImmunity then
                baseDrain = baseDrain * 0.7
            end

            sanity = math.max(0.0, sanity - baseDrain)

            -- Sanity reduces player max health limit (scales 100 to 200 HP)
            local maxHealthLimit = math.floor(100 + sanity)
            if GetEntityHealth(ped) > maxHealthLimit then
                SetEntityHealth(ped, maxHealthLimit)
            end

            -- Hallucination trigger at extremely low sanity
            if sanity < 25.0 then
                SetTimecycleModifierStrength(0.85)
            end

            if GetResourceState('qbx_survival_nui') == 'started' then
                exports.qbx_survival_nui:UpdateSanity(math.floor(sanity))
            end
        elseif not inPollutionZone and sanity < 100.0 then
            sanity = math.min(100.0, sanity + 0.5)
            if GetResourceState('qbx_survival_nui') == 'started' then
                exports.qbx_survival_nui:UpdateSanity(math.floor(sanity))
            end
        end
    end
end)

exports('GetSanity', function()
    return sanity
end)

exports('SetSanity', function(value)
    sanity = math.max(0.0, math.min(100.0, value))
    if GetResourceState('qbx_survival_nui') == 'started' then
        exports.qbx_survival_nui:UpdateSanity(math.floor(sanity))
    end
end)
