RegisterNetEvent('qbx_crafting:server:startCraft', function(recipeId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local recipe = Config.Recipes[recipeId]
    if not recipe then return end

    -- Node Requirement Check
    if recipe.requiredNode and GetResourceState('qbx_skills') == 'started' then
        local unlocked = exports.qbx_skills:HasNodeUnlocked(src, recipe.requiredNode)
        if not unlocked then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Crafting Locked',
                description = 'Required Memetics Node not unlocked!',
                type = 'error'
            })
            return
        end
    end

    -- Ingredient Check
    for _, ing in ipairs(recipe.ingredients) do
        local count = exports.ox_inventory:Search(src, 'count', ing.item)
        if count < ing.amount then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Missing Materials',
                description = string.format('Requires %dx %s', ing.amount, ing.item),
                type = 'error'
            })
            return
        end
    end

    -- Remove ingredients
    for _, ing in ipairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(src, ing.item, ing.amount)
    end

    -- Trigger Client Progress
    TriggerClientEvent('qbx_crafting:client:doCraftProgress', src, recipeId, recipe.duration)
end)

RegisterNetEvent('qbx_crafting:server:finishCraft', function(recipeId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local recipe = Config.Recipes[recipeId]
    if not recipe then return end

    -- Add Result Item
    exports.ox_inventory:AddItem(src, recipe.result.item, recipe.result.amount)

    -- Award Skill XP
    if recipe.skill and recipe.xpReward and GetResourceState('qbx_skills') == 'started' then
        exports.qbx_skills:AddXP(src, recipe.skill, recipe.xpReward)
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Crafting Complete',
        description = string.format('Successfully crafted %dx %s', recipe.result.amount, recipe.label),
        type = 'success'
    })
end)
