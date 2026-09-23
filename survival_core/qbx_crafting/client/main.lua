local function GetRecipesForTier(tier)
    local tierRecipes = {}
    for recipeId, recipe in pairs(Config.Recipes) do
        if recipe.tier == tier then
            tierRecipes[recipeId] = recipe
        end
    end
    return tierRecipes
end

for tierKey, bench in pairs(Config.Workbenches) do
    local tierNum = tonumber(tierKey:sub(5)) or 1

    for i, coords in ipairs(bench.coords) do
        exports.ox_target:addBoxZone({
            coords = coords,
            size = vec3(2.0, 2.0, 2.0),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'workbench_' .. tierKey .. '_' .. i,
                    icon = 'fa-solid fa-screwdriver-wrench',
                    label = 'Open ' .. bench.label,
                    onSelect = function()
                        if GetResourceState('qbx_survival_nui') == 'started' then
                            exports.qbx_survival_nui:OpenCraftingUI(tierNum, GetRecipesForTier(tierNum))
                        end
                    end
                }
            }
        })
    end
end

RegisterNetEvent('qbx_crafting:client:doCraftProgress', function(recipeId, duration)
    local recipe = Config.Recipes[recipeId]
    if not recipe then return end

    if lib.progressCircle({
        duration = duration,
        position = 'bottom',
        label = 'Assembly: ' .. recipe.label,
        useWhileDead = false,
        canCancel = true,
        anim = { dict = 'anim@amb@clubhouse@tutorial@bkg@', clip = 'idle_a' }
    }) then
        TriggerServerEvent('qbx_crafting:server:finishCraft', recipeId)
    else
        lib.notify({ title = 'Crafting Cancelled', type = 'error' })
    end
end)
