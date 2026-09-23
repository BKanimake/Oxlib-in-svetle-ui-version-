# Once Human-Inspired FiveM Zombie Survival Framework

## Overview
This architecture provides a modular, performant FiveM survival ecosystem inspired by *Once Human* (Stardust mechanics, Cradle Memetics progression, contaminated hotzones, and client-side threat density).

---

## 1. Resource Hierarchy (`[survival_core]`)
- **`qbx_skills`**: Core Memetics progression system. Manages XP, player levels, available skill points, node unlocking, and persistent MySQL database state.
- **`qbx_pollution`**: Handles Stardust pollution zones, timecycle post-processing effects, gas mask filtering, maximum HP reduction (capping health down to 100 based on Sanity drop), and persistent HUD events.
- **`qbx_crafting`**: Workbenches (Tier 1 Survival, Tier 2 Gunsmith, Tier 3 Bio-Refinery) with material consumption, assembly progress circles, node-gated recipes, and skill XP payouts.
- **`qbx_zombies`**: Grid-based local client threat director. Spawns infected dynamically near players (snapped to ground, max 10 per player bucket) to optimize server tick rates. Supports precision headshots and `ox_target` corpse looting with state bag deduplication (`Entity(ped).state.looted`).
- **`qbx_survival_nui`**: Svelte 4 single-page NUI application for the persistent Sanity Gauge HUD and the Cradle Memetics / Workbench UI windows (built with high-contrast semi-transparent solid backgrounds to prevent CEF `backdrop-blur` artifacts).

---

## 2. Server Design & Gameplay Mechanics

### A. Cradle Memetics & Skill Paths
1. **Scavenging**: Earned by looting infected and searching containers. Unlocks faster searching speeds and extra salvage material drops.
2. **Gunsmithing**: Earned by crafting ammo and assembling gear. Unlocks weapon suppressor fabrication and reduced weapon degradation.
3. **Survival & Biology**: Earned by purifying water and foraging. Unlocks toxin resistance (30% reduced sanity drain) and extended hunger/thirst buffers.
4. **Engineering**: Earned by workbench production and refining. Unlocks Tier 3 Bio-Refining and faster crafting assembly speeds.

### B. Stardust Pollution & Sanity Dynamics
- **Hotzones**: Pre-configured contaminated sectors ("Toxic Basin", "Infested Core", "Quarry Stardust Anomaly").
- **Visual Effects**: Activates `drug_wobbly` timecycle modifiers with scaled intensity upon entry.
- **Health Cap Penalty**: As Sanity drops from 100% down to 0%, the player's maximum achievable health is dynamically clamped down from 200 HP to 100 HP.
- **Mitigation**: Wearing a `gas_mask` reduces sanity drain from -4/sec to -1/sec. Unlocking the *Stardust Immunity* memetic node further reduces drain by 30%.

### C. Advanced Server Concepts for Future Expansion
1. **Stardust Storms**: Global server events where pollution spreads beyond hotzones for 15 minutes, spawning Elite Mutant Variants that drop rare Stardust Cores.
2. **Water & Food Contamination**: Raw water sources inflict Sanity damage unless boiled or processed at a Tier 1 Survival Workbench.
3. **Territory Purification Generators**: Base-building generators powered by `stardust_ore` that create purified sanctuary bubbles around player shelters.

---

## 3. Installation & Setup
1. **Database**: Import `survival_core/skills.sql` into your MySQL database (`oxmysql`).
2. **Items Registry**: Copy item definitions from `survival_core/items_registry.lua` into your `ox_inventory/data/items.lua`.
3. **Resource Start Order** (in `server.cfg`):
   ```cfg
   ensure oxmysql
   ensure ox_lib
   ensure qbx_core
   ensure ox_target
   ensure ox_inventory

   # Survival Framework
   ensure qbx_skills
   ensure qbx_pollution
   ensure qbx_crafting
   ensure qbx_zombies
   ensure qbx_survival_nui
   ```
