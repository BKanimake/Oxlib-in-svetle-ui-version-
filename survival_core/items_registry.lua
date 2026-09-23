-- Register these items in ox_inventory/data/items.lua or add to custom items config

return {
    ['stardust_ore'] = {
        label = 'Stardust Ore',
        weight = 250,
        stack = true,
        close = true,
        description = 'Raw alien crystal infected with Stardust energy. Used in advanced craftings and bio-refinery.'
    },

    ['mutagen_extract'] = {
        label = 'Mutagen Extract',
        weight = 100,
        stack = true,
        close = true,
        description = 'Extracted viral secretion from infected hosts. Highly reactive compound.'
    },

    ['gas_mask'] = {
        label = 'Filter Gas Mask',
        weight = 500,
        stack = false,
        close = true,
        description = 'Protects lungs against low-to-mid level Stardust pollution zones.'
    },

    ['scrap_parts'] = {
        label = 'Scrap Parts',
        weight = 150,
        stack = true,
        close = true,
        description = 'Salvaged metal and components used in general crafting and repair.'
    },

    ['purified_water'] = {
        label = 'Purified Water',
        weight = 500,
        stack = true,
        close = true,
        description = 'Cleaned water safe from Stardust toxicity and radiation.'
    },

    ['biostim'] = {
        label = 'Stardust Bio-Stim',
        weight = 100,
        stack = true,
        close = true,
        description = 'Injectable adrenaline compound that restores health and boosts temporary stamina.'
    },

    ['ammo_box'] = {
        label = 'Surplus Ammo Pack',
        weight = 300,
        stack = true,
        close = true,
        description = 'Box of reloaded survival ammunition.'
    },

    ['weapon_silencer'] = {
        label = 'Improvised Suppressor',
        weight = 400,
        stack = false,
        close = true,
        description = 'Attaches to small firearms to muffle shot noise from distant infected.'
    }
}
