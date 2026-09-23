local isUiOpen = false

exports('OpenUI', function(tab)
    isUiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "toggleUI",
        data = { open = true, tab = tab or 'skills' }
    })
end)

exports('OpenCraftingUI', function(tier, recipes)
    isUiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "toggleUI",
        data = {
            open = true,
            tab = 'crafting',
            tier = tier,
            recipes = recipes
        }
    })
end)

exports('UpdateSanity', function(sanityValue)
    SendNUIMessage({
        action = "updateSanity",
        sanity = sanityValue
    })
end)

exports('UpdateSkills', function(skillsData)
    SendNUIMessage({
        action = "updateSkills",
        data = skillsData
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(_, cb)
    isUiOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('unlockNode', function(data, cb)
    if data and data.nodeId then
        TriggerServerEvent('qbx_skills:server:unlockNode', data.nodeId)
    end
    cb('ok')
end)

RegisterNUICallback('craftItem', function(data, cb)
    if data and data.recipeId then
        SetNuiFocus(false, false)
        isUiOpen = false
        TriggerServerEvent('qbx_crafting:server:startCraft', data.recipeId)
    end
    cb('ok')
end)
