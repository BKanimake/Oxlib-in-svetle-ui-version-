Config = {}

Config.Workbenches = {
    tier1 = {
        label = 'Survival Workbench (Tier 1)',
        prop = `prop_toolchest_01`,
        coords = {
            vector3(2435.0, 4966.0, 46.0),
            vector3(18.0, 3680.0, 39.5)
        }
    },
    tier2 = {
        label = 'Gunsmith Bench (Tier 2)',
        prop = `prop_table_03b`,
        coords = {
            vector3(2438.0, 4968.0, 46.0)
        }
    },
    tier3 = {
        label = 'Stardust Bio-Refinery (Tier 3)',
        prop = `prop_generator_03a`,
        coords = {
            vector3(2440.0, 4970.0, 46.0)
        }
    }
}

Config.Recipes = {
    -- Tier 1 Recipes
    gas_mask = {
        tier = 1,
        label = 'Filter Gas Mask',
        duration = 5000,
        skill = 'survival',
        xpReward = 45,
        ingredients = {
            { item = 'scrap_parts', amount = 3 }
        },
        result = { item = 'gas_mask', amount = 1 }
    },
    purified_water = {
        tier = 1,
        label = 'Purified Water',
        duration = 3000,
        skill = 'survival',
        xpReward = 20,
        ingredients = {
            { item = 'scrap_parts', amount = 1 }
        },
        result = { item = 'purified_water', amount = 2 }
    },

    -- Tier 2 Recipes
    ammo_box = {
        tier = 2,
        label = 'Surplus Ammo Pack',
        duration = 6000,
        skill = 'gunsmithing',
        xpReward = 60,
        ingredients = {
            { item = 'scrap_parts', amount = 5 }
        },
        result = { item = 'ammo_box', amount = 1 }
    },
    weapon_silencer = {
        tier = 2,
        label = 'Improvised Suppressor',
        duration = 8000,
        skill = 'gunsmithing',
        requiredNode = 'gun_craft_silencer',
        xpReward = 120,
        ingredients = {
            { item = 'scrap_parts', amount = 8 },
            { item = 'stardust_ore', amount = 2 }
        },
        result = { item = 'weapon_silencer', amount = 1 }
    },

    -- Tier 3 Recipes
    biostim = {
        tier = 3,
        label = 'Stardust Bio-Stim',
        duration = 10000,
        skill = 'engineering',
        requiredNode = 'eng_refinery_boost',
        xpReward = 150,
        ingredients = {
            { item = 'stardust_ore', amount = 4 },
            { item = 'mutagen_extract', amount = 2 }
        },
        result = { item = 'biostim', amount = 1 }
    }
}
