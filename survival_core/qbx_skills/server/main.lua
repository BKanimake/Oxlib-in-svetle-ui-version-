local skillsCache = {}

local function CalculateLevel(xp)
    if not xp or xp <= 0 then return 1 end
    -- Square-root progression: Level 1 = 0-99xp, Level 2 = 100xp, Level 10 = 10,000xp
    return math.floor(math.sqrt(xp) / 10) + 1
end

local function LoadPlayerData(cid)
    local data = MySQL.single.await('SELECT * FROM player_skills WHERE citizenid = ?', { cid })
    if not data then
        skillsCache[cid] = {
            scavenging = 0,
            gunsmithing = 0,
            survival = 0,
            engineering = 0,
            skill_points = 0,
            unlocked_nodes = {}
        }
        MySQL.insert('INSERT INTO player_skills (citizenid, scavenging, gunsmithing, survival, engineering, skill_points, unlocked_nodes) VALUES (?, 0, 0, 0, 0, 0, ?)', {
            cid, json.encode({})
        })
    else
        local nodes = {}
        if data.unlocked_nodes then
            local success, decoded = pcall(json.decode, data.unlocked_nodes)
            if success and type(decoded) == 'table' then
                nodes = decoded
            end
        end
        skillsCache[cid] = {
            scavenging = data.scavenging or 0,
            gunsmithing = data.gunsmithing or 0,
            survival = data.survival or 0,
            engineering = data.engineering or 0,
            skill_points = data.skill_points or 0,
            unlocked_nodes = nodes
        }
    end
    return skillsCache[cid]
end

exports('AddXP', function(source, skillName, amount)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local cid = player.PlayerData.citizenid

    if not skillsCache[cid] then
        LoadPlayerData(cid)
    end

    local currentXP = skillsCache[cid][skillName] or 0
    local oldLevel = CalculateLevel(currentXP)
    local newXP = currentXP + amount
    local newLevel = CalculateLevel(newXP)

    skillsCache[cid][skillName] = newXP

    -- Award skill points on level up
    if newLevel > oldLevel then
        local earnedPoints = newLevel - oldLevel
        skillsCache[cid].skill_points = skillsCache[cid].skill_points + earnedPoints
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Milestone Reached',
            description = string.format('%s reached Level %d! (+%d Skill Points)', skillName:upper(), newLevel, earnedPoints),
            type = 'success'
        })
    end

    MySQL.update('UPDATE player_skills SET ' .. skillName .. ' = ?, skill_points = ? WHERE citizenid = ?', {
        newXP, skillsCache[cid].skill_points, cid
    })

    TriggerClientEvent('qbx_skills:client:updateState', source, skillsCache[cid])
end)

exports('GetSkillState', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end
    local cid = player.PlayerData.citizenid
    if not skillsCache[cid] then
        LoadPlayerData(cid)
    end
    return skillsCache[cid]
end)

exports('HasNodeUnlocked', function(source, nodeId)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    local cid = player.PlayerData.citizenid
    if not skillsCache[cid] then LoadPlayerData(cid) end

    for _, node in ipairs(skillsCache[cid].unlocked_nodes or {}) do
        if node == nodeId then return true end
    end
    return false
end)

RegisterNetEvent('qbx_skills:server:unlockNode', function(nodeId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local cid = player.PlayerData.citizenid

    if not skillsCache[cid] then LoadPlayerData(cid) end
    local pData = skillsCache[cid]

    local nodeConfig = Config.Nodes[nodeId]
    if not nodeConfig then return end

    if pData.skill_points < nodeConfig.cost then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Memetics Upgrade',
            description = 'Not enough skill points!',
            type = 'error'
        })
        return
    end

    -- Check if already unlocked
    for _, n in ipairs(pData.unlocked_nodes) do
        if n == nodeId then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Memetics Upgrade',
                description = 'Node already unlocked!',
                type = 'inform'
            })
            return
        end
    end

    pData.skill_points = pData.skill_points - nodeConfig.cost
    table.insert(pData.unlocked_nodes, nodeId)

    MySQL.update('UPDATE player_skills SET skill_points = ?, unlocked_nodes = ? WHERE citizenid = ?', {
        pData.skill_points, json.encode(pData.unlocked_nodes), cid
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Memetics Unlocked',
        description = 'Unlocked node: ' .. nodeConfig.label,
        type = 'success'
    })

    TriggerClientEvent('qbx_skills:client:updateState', src, pData)
end)

RegisterNetEvent('qbx_skills:server:requestSync', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local cid = player.PlayerData.citizenid
    local data = LoadPlayerData(cid)
    TriggerClientEvent('qbx_skills:client:updateState', src, data)
end)
