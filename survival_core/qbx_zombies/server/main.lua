local lootTable = {
    { item = 'scrap_parts', min = 1, max = 4, chance = 80 },
    { item = 'stardust_ore', min = 1, max = 2, chance = 40 },
    { item = 'mutagen_extract', min = 1, max = 1, chance = 20 },
    { item = 'purified_water', min = 1, max = 1, chance = 15 }
}

RegisterNetEvent('qbx_zombies:server:rewardLoot', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local itemsGiven = 0
    for _, entry in ipairs(lootTable) do
        local roll = math.random(100)
        if roll <= entry.chance then
            local count = math.random(entry.min, entry.max)
            exports.ox_inventory:AddItem(src, entry.item, count)
            itemsGiven = itemsGiven + 1
        end
    end

    if itemsGiven == 0 then
        -- Guarantee scrap parts if bad RNG
        exports.ox_inventory:AddItem(src, 'scrap_parts', 1)
    end

    -- Award Scavenging XP
    if GetResourceState('qbx_skills') == 'started' then
        exports.qbx_skills:AddXP(src, 'scavenging', 35)
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Infected Looted',
        description = 'Harvested materials from corpse (+35 Scavenging XP)',
        type = 'success'
    })
end)
