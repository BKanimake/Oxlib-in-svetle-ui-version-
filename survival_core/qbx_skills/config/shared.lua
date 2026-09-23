Config = {}

Config.Skills = {
    scavenging = {
        label = 'Scavenging',
        description = 'Looting corpses, searching containers, recycling junk.'
    },
    gunsmithing = {
        label = 'Gunsmithing',
        description = 'Crafting weapons, ammo assembly, modding gear.'
    },
    survival = {
        label = 'Survival & Biology',
        description = 'Foraging, purifying water, bio-stims, toxin resistance.'
    },
    engineering = {
        label = 'Engineering',
        description = 'Workbench construction, refining, generator maintenance.'
    }
}

Config.Nodes = {
    -- Scavenging Nodes
    ['scav_speed_1'] = { skill = 'scavenging', tier = 1, cost = 1, label = 'Fast Fingers', description = 'Reduces searching and looting time by 25%.' },
    ['scav_bonus_1'] = { skill = 'scavenging', tier = 2, cost = 1, label = 'Scrap Collector', description = 'Increases scrap yield from looted corpses and containers.' },

    -- Gunsmithing Nodes
    ['gun_durability_1'] = { skill = 'gunsmithing', tier = 1, cost = 1, label = 'Reinforced Firing Pin', description = 'Reduces weapon degradation speed.' },
    ['gun_craft_silencer'] = { skill = 'gunsmithing', tier = 2, cost = 2, label = 'Suppressor Fabrication', description = 'Unlocks crafting improvised silencers at Gunsmith Bench.' },

    -- Survival Nodes
    ['surv_buffer_1'] = { skill = 'survival', tier = 1, cost = 1, label = 'Hardened Metabolism', description = 'Slower hunger and thirst loss rates.' },
    ['surv_toxin_res_1'] = { skill = 'survival', tier = 2, cost = 2, label = 'Stardust Immunity', description = 'Reduces sanity loss rate in contaminated zones by 30%.' },

    -- Engineering Nodes
    ['eng_craft_speed_1'] = { skill = 'engineering', tier = 1, cost = 1, label = 'Efficient Assembly', description = 'Boosts crafting speed at all workbenches by 20%.' },
    ['eng_refinery_boost'] = { skill = 'engineering', tier = 2, cost = 2, label = 'Stardust Refiner', description = 'Unlocks bio-refinery workbench recipes.' }
}
