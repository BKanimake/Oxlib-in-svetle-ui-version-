local playerSkills = {
    scavenging = 0,
    gunsmithing = 0,
    survival = 0,
    engineering = 0,
    skill_points = 0,
    unlocked_nodes = {}
}

RegisterNetEvent('qbx_skills:client:updateState', function(data)
    if data then
        playerSkills = data
        if GetResourceState('qbx_survival_nui') == 'started' then
            exports.qbx_survival_nui:UpdateSkills(playerSkills)
        end
    end
end)

exports('HasNodeUnlockedClient', function(nodeId)
    for _, node in ipairs(playerSkills.unlocked_nodes or {}) do
        if node == nodeId then return true end
    end
    return false
end)

local function OpenSkillUI()
    TriggerServerEvent('qbx_skills:server:requestSync')
    if GetResourceState('qbx_survival_nui') == 'started' then
        exports.qbx_survival_nui:OpenUI('skills')
    end
end

RegisterCommand('memetics', function()
    OpenSkillUI()
end, false)

RegisterKeyMapping('memetics', 'Open Cradle Memetics / Skills', 'keyboard', 'k')

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qbx_skills:server:requestSync')
end)
