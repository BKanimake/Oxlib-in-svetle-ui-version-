<script>
  import { onMount } from 'svelte';

  let isVisible = false;
  let currentChannel = 0; // 0 means off
  let maxChannel = 5000;
  let callSign = '';

  // Settings Panel state
  let settingsOpen = false;
  let listColor = '#ffffff';
  let radioList = []; // Array of names on the radio

  // Handle NUI Messages from Lua
  onMount(() => {
    window.addEventListener('message', (event) => {
      const { type, data } = event.data;
      if (type === 'toggleRadio') {
        isVisible = data.state;
      } else if (type === 'updateRadioList') {
        radioList = data.list;
      }
    });

    // Close on Escape
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && isVisible) {
        closeRadioUI();
      }
    });
  });

  function closeRadioUI() {
    isVisible = false;
    settingsOpen = false;
    fetch(`https://${GetParentResourceName()}/closeRadio`, {
      method: 'POST',
      body: JSON.stringify({})
    }).catch(() => {});
  }

  function powerOff() {
      currentChannel = 0;
      fetch(`https://${GetParentResourceName()}/changeChannel`, {
          method: 'POST',
          body: JSON.stringify({ channel: 0 }) // 0 = disconnect
      }).catch(() => {});
  }

  function changeChannel(dir) {
      let newChannel = currentChannel + dir;
      if (newChannel > maxChannel) newChannel = maxChannel;
      if (newChannel < 1) newChannel = 1; // Cannot arrow down to 0, 0 is strictly power off

      currentChannel = newChannel;

      fetch(`https://${GetParentResourceName()}/changeChannel`, {
          method: 'POST',
          body: JSON.stringify({ channel: currentChannel })
      }).catch(() => {});
  }

  function setChannelDirect(e) {
      const val = parseInt(e.target.value);
      if(!isNaN(val) && val >= 1 && val <= maxChannel) {
          currentChannel = val;
          fetch(`https://${GetParentResourceName()}/changeChannel`, {
              method: 'POST',
              body: JSON.stringify({ channel: currentChannel })
          }).catch(() => {});
      } else if (val === 0) {
          powerOff();
      }
  }

  function saveSettings() {
      fetch(`https://${GetParentResourceName()}/saveSettings`, {
          method: 'POST',
          body: JSON.stringify({ callSign, listColor })
      }).catch(() => {});
      settingsOpen = false;
  }

</script>

{#if isVisible}
  <div class="fixed inset-0 flex items-center justify-center bg-black/30 backdrop-blur-sm z-50">

    <!-- Settings Panel / Radio List -->
    {#if settingsOpen}
      <div class="absolute right-10 top-1/4 w-80 bg-gray-900 border border-gray-700 rounded-lg p-4 shadow-2xl text-white">
        <h2 class="text-xl font-bold mb-4 border-b border-gray-700 pb-2">Radio Settings</h2>

        <div class="mb-4">
          <label class="block text-sm text-gray-400 mb-1">Call Sign</label>
          <input
            type="text"
            bind:value={callSign}
            class="w-full bg-gray-800 border border-gray-600 rounded px-3 py-2 text-white focus:outline-none focus:border-blue-500"
            placeholder="e.g. 1A-01"
          />
        </div>

        <div class="mb-6">
          <label class="block text-sm text-gray-400 mb-1">Radio List Color</label>
          <input
            type="color"
            bind:value={listColor}
            class="w-full h-10 rounded cursor-pointer bg-transparent border-0"
          />
        </div>

        <button
          on:click={saveSettings}
          class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded transition-colors"
        >
          Save Settings
        </button>

        <div class="mt-6 pt-4 border-t border-gray-700">
           <h3 class="text-md font-bold mb-2">Members on Frequency</h3>
           <ul class="max-h-40 overflow-y-auto space-y-1" style="color: {listColor}">
              {#if currentChannel === 0}
                  <li class="text-gray-500 italic">Radio is turned off.</li>
              {:else if radioList.length === 0}
                  <li class="text-gray-500 italic">No one on this frequency</li>
              {:else}
                  {#each radioList as member}
                      <li class="px-2 py-1 bg-gray-800 rounded">{member}</li>
                  {/each}
              {/if}
           </ul>
        </div>
      </div>
    {/if}

    <!-- Radio UI -->
    <div class="relative w-[400px] h-[800px] select-none filter drop-shadow-2xl">
      <!-- Background Image -->
      <img
        src="radio_bg.png"
        alt="Radio"
        class="absolute inset-0 w-full h-full object-contain pointer-events-none"
      />

      <!-- Screen Overlay -->
      <div class="absolute top-[36%] left-[28%] w-[43%] h-[12%] bg-[#8b9b8b]/10 rounded flex items-center justify-center p-2">
         <!-- Digital Display -->
         <div class="w-full h-full bg-[#111111]/90 rounded flex flex-col justify-between p-1 border-2 border-black relative overflow-hidden shadow-inner">
             <div class="flex justify-between items-center text-[#55ff55] px-1 h-1/4">
                 <div class="flex items-center gap-1">
                    <span class="text-[10px] font-bold tracking-tighter" style="text-shadow: 0 0 5px #55ff55;">CH</span>
                 </div>
                 <div class="flex gap-1 h-3">
                     <!-- Battery Icon -->
                     <div class="w-5 h-2 border border-[#55ff55] rounded-sm relative" style={currentChannel === 0 ? "opacity: 0.2" : ""}>
                         <div class="w-[80%] h-full bg-[#55ff55]"></div>
                         <div class="absolute -right-[2px] top-1/2 -translate-y-1/2 w-[2px] h-1 bg-[#55ff55]"></div>
                     </div>
                 </div>
             </div>

             <div class="flex-grow flex items-center justify-center">
                 <input
                   type="text"
                   value={currentChannel === 0 ? "OFF" : currentChannel}
                   on:blur={setChannelDirect}
                   on:keydown={(e) => { if (e.key === 'Enter') e.target.blur(); }}
                   class="radio-display w-full bg-transparent text-[#55ff55] text-5xl text-center focus:outline-none focus:bg-[#55ff55]/10 rounded tracking-widest"
                   style={currentChannel === 0 ? "text-shadow: none; opacity: 0.3;" : "text-shadow: 0 0 10px #55ff55;"}
                 />
             </div>
         </div>
      </div>

      <!-- Controls -->

      <!-- Power Off Button (Top right knob) -->
      <button
        on:click={powerOff}
        class="absolute top-[16%] right-[32%] w-12 h-12 rounded-full cursor-pointer hover:bg-white/10"
        title="Power Off"
      ></button>

      <!-- Channel Up (Right arrow) -->
      <button
        on:click={() => changeChannel(1)}
        class="absolute top-[60%] right-[30%] w-16 h-12 rounded cursor-pointer hover:bg-white/10"
        title="Channel Up"
      ></button>

      <!-- Channel Down (Left arrow) -->
      <button
        on:click={() => changeChannel(-1)}
        class="absolute top-[60%] left-[30%] w-16 h-12 rounded cursor-pointer hover:bg-white/10"
        title="Channel Down"
      ></button>

      <!-- Settings Button (Middle button) -->
      <button
        on:click={() => settingsOpen = !settingsOpen}
        class="absolute top-[70%] left-[30%] w-[40%] h-12 rounded cursor-pointer hover:bg-white/10"
        title="Settings / Radio List"
      ></button>

    </div>
  </div>
{/if}
