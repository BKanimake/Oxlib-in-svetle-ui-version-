<script>
  import { onMount } from "svelte";

  let visible = false;
  let activeTab = "skills"; // "skills" | "crafting"
  let sanity = 100;
  let craftingTier = 1;

  let skills = {
    scavenging: 0,
    gunsmithing: 0,
    survival: 0,
    engineering: 0,
    skill_points: 0,
    unlocked_nodes: []
  };

  let recipes = {};

  // Compute skill level from square-root formula
  function getLevel(xp) {
    if (!xp || xp <= 0) return 1;
    return Math.floor(Math.sqrt(xp) / 10) + 1;
  }

  function getXpProgress(xp) {
    if (!xp || xp <= 0) return 0;
    const level = getLevel(xp);
    const prevLevelXp = Math.pow((level - 1) * 10, 2);
    const nextLevelXp = Math.pow(level * 10, 2);
    const diff = nextLevelXp - prevLevelXp;
    if (diff <= 0) return 100;
    return Math.min(100, Math.max(0, ((xp - prevLevelXp) / diff) * 100));
  }

  function getResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : "qbx_survival_nui";
  }

  onMount(() => {
    window.addEventListener("message", (event) => {
      const { action, data, sanity: sanityVal } = event.data;
      if (action === "toggleUI") {
        visible = data.open;
        if (data.tab) activeTab = data.tab;
        if (data.tier) craftingTier = data.tier;
        if (data.recipes) recipes = data.recipes;
      }
      if (action === "updateSanity") {
        sanity = sanityVal !== undefined ? sanityVal : event.data.sanity;
      }
      if (action === "updateSkills") {
        skills = data;
      }
    });

    window.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && visible) {
        closeUI();
      }
    });
  });

  function closeUI() {
    visible = false;
    fetch(`https://${getResourceName()}/closeUI`, { method: "POST" });
  }

  function unlockNode(nodeId) {
    if (skills.skill_points <= 0) return;
    fetch(`https://${getResourceName()}/unlockNode`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ nodeId })
    });
  }

  function craftItem(recipeId) {
    fetch(`https://${getResourceName()}/craftItem`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ recipeId })
    });
  }
</script>

<!-- Persistent Sanity Gauge (Solid background, crisp FiveM safe styling) -->
<div class="fixed top-6 right-6 flex items-center gap-3 bg-zinc-950 border border-zinc-800 p-3 rounded-lg font-mono shadow-xl z-50">
  <div class="w-3 h-3 rounded-full {sanity > 50 ? 'bg-cyan-400 animate-pulse' : 'bg-rose-500 animate-ping'}"></div>
  <span class="text-xs font-semibold text-zinc-400 tracking-wider">SANITY:</span>
  <span class="text-base font-bold {sanity > 50 ? 'text-cyan-300' : 'text-rose-400'}">{Math.round(sanity)}%</span>
</div>

<!-- Main Survival Modal Window -->
{#if visible}
  <main class="fixed inset-0 bg-black/90 flex items-center justify-center p-8 select-none z-40">
    <div class="w-full max-w-4xl bg-zinc-950 border border-zinc-800 rounded-xl overflow-hidden shadow-2xl flex flex-col">
      <!-- Header Bar -->
      <header class="p-6 border-b border-zinc-800 flex justify-between items-center bg-zinc-900/60">
        <div class="flex items-center gap-6">
          <div>
            <h1 class="text-2xl font-black tracking-widest text-zinc-100 uppercase">
              {activeTab === 'skills' ? 'Cradle Memetics' : `Workbench (Tier ${craftingTier})`}
            </h1>
            <p class="text-xs text-zinc-400">
              {activeTab === 'skills' ? 'Enhance biological, combat, and engineering capabilities' : 'Fabricate survival equipment and refined materials'}
            </p>
          </div>
          <!-- Tab Buttons -->
          <div class="flex bg-zinc-900 p-1 rounded-lg border border-zinc-800">
            <button
              on:click={() => activeTab = "skills"}
              class="px-4 py-1.5 rounded text-xs font-bold uppercase transition-colors {activeTab === 'skills' ? 'bg-cyan-600 text-zinc-100' : 'text-zinc-400 hover:text-zinc-200'}">
              Memetics
            </button>
            <button
              on:click={() => activeTab = "crafting"}
              class="px-4 py-1.5 rounded text-xs font-bold uppercase transition-colors {activeTab === 'crafting' ? 'bg-cyan-600 text-zinc-100' : 'text-zinc-400 hover:text-zinc-200'}">
              Crafting
            </button>
          </div>
        </div>

        <div class="flex items-center gap-4">
          {#if activeTab === 'skills'}
            <div class="bg-amber-500/10 border border-amber-500/40 px-4 py-2 rounded text-amber-400 font-mono text-xs font-bold">
              AVAILABLE POINTS: {skills.skill_points || 0}
            </div>
          {/if}
          <button
            on:click={closeUI}
            class="px-3 py-1.5 bg-zinc-800 hover:bg-zinc-700 text-zinc-300 rounded text-xs font-bold uppercase tracking-wider">
            Close (ESC)
          </button>
        </div>
      </header>

      <!-- Content Area -->
      <div class="p-6">
        {#if activeTab === 'skills'}
          <div class="grid grid-cols-2 gap-4">
            {#each ['scavenging', 'gunsmithing', 'survival', 'engineering'] as skillName}
              {@const xp = skills[skillName] || 0}
              {@const level = getLevel(xp)}
              {@const progress = getXpProgress(xp)}
              <div class="bg-zinc-900 border border-zinc-800 p-4 rounded-lg flex flex-col justify-between">
                <div>
                  <div class="flex justify-between items-center mb-2">
                    <span class="uppercase font-bold text-sm tracking-wide text-zinc-200">{skillName}</span>
                    <span class="text-xs font-mono text-cyan-400 font-semibold">LEVEL {level} ({xp} XP)</span>
                  </div>
                  <div class="w-full bg-zinc-800 h-2 rounded-full overflow-hidden">
                    <div class="bg-cyan-500 h-full transition-all duration-300" style="width: {progress}%"></div>
                  </div>
                </div>
              </div>
            {/each}
          </div>

          <!-- Quick Node Upgrades -->
          <div class="mt-6 border-t border-zinc-800 pt-4">
            <h3 class="text-xs font-bold text-zinc-400 uppercase tracking-widest mb-3">Available Memetic Upgrades</h3>
            <div class="grid grid-cols-2 gap-3">
              <div class="bg-zinc-900 p-3 rounded border border-zinc-800 flex justify-between items-center">
                <div>
                  <div class="text-xs font-bold text-zinc-200">Suppressor Fabrication</div>
                  <div class="text-[10px] text-zinc-400">Unlock Gunsmith Bench Suppressor Recipe</div>
                </div>
                <button
                  on:click={() => unlockNode('gun_craft_silencer')}
                  disabled={skills.skill_points <= 0 || (skills.unlocked_nodes && skills.unlocked_nodes.includes('gun_craft_silencer'))}
                  class="px-3 py-1.5 bg-cyan-600 hover:bg-cyan-500 disabled:bg-zinc-800 disabled:text-zinc-600 text-zinc-100 rounded text-xs font-bold uppercase">
                  {skills.unlocked_nodes && skills.unlocked_nodes.includes('gun_craft_silencer') ? 'Unlocked' : 'Unlock (2 Pts)'}
                </button>
              </div>

              <div class="bg-zinc-900 p-3 rounded border border-zinc-800 flex justify-between items-center">
                <div>
                  <div class="text-xs font-bold text-zinc-200">Stardust Refiner</div>
                  <div class="text-[10px] text-zinc-400">Unlock Bio-Stim Fabrication at Bio-Refinery</div>
                </div>
                <button
                  on:click={() => unlockNode('eng_refinery_boost')}
                  disabled={skills.skill_points <= 0 || (skills.unlocked_nodes && skills.unlocked_nodes.includes('eng_refinery_boost'))}
                  class="px-3 py-1.5 bg-cyan-600 hover:bg-cyan-500 disabled:bg-zinc-800 disabled:text-zinc-600 text-zinc-100 rounded text-xs font-bold uppercase">
                  {skills.unlocked_nodes && skills.unlocked_nodes.includes('eng_refinery_boost') ? 'Unlocked' : 'Unlock (2 Pts)'}
                </button>
              </div>
            </div>
          </div>

        {:else if activeTab === 'crafting'}
          <div class="space-y-3 max-h-96 overflow-y-auto pr-2">
            {#if Object.keys(recipes).length === 0}
              <div class="text-center py-12 text-zinc-500 text-sm">No recipes available for this workbench tier.</div>
            {:else}
              {#each Object.entries(recipes) as [id, recipe]}
                <div class="bg-zinc-900 border border-zinc-800 p-4 rounded-lg flex items-center justify-between">
                  <div>
                    <div class="text-sm font-bold text-zinc-100">{recipe.label}</div>
                    <div class="text-xs text-zinc-400 mt-1 flex gap-3">
                      <span>Duration: {recipe.duration / 1000}s</span>
                      <span>XP: +{recipe.xpReward} ({recipe.skill})</span>
                    </div>
                    <div class="flex gap-2 mt-2">
                      {#each recipe.ingredients as ing}
                        <span class="px-2 py-0.5 bg-zinc-800 text-zinc-300 rounded text-[11px] font-mono">
                          {ing.amount}x {ing.item}
                        </span>
                      {/each}
                    </div>
                  </div>
                  <button
                    on:click={() => craftItem(id)}
                    class="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-zinc-100 font-bold text-xs uppercase tracking-wider rounded transition-colors">
                    Craft Item
                  </button>
                </div>
              {/each}
            {/if}
          </div>
        {/if}
      </div>
    </div>
  </main>
{/if}
