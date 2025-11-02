// Name: Start Amphetamine Session
// Description: Start a new Amphetamine session with specified duration
// Author: Josh Branchaud

import '@johnlindquist/kit';

// Duration presets in hours
const DURATION_PRESETS = {
  '8 Hours': 8,
  '4 Hours': 4,
  '2 Hours': 2,
  '1 Hour': 1,
  '30 Minutes': 0.5,
  'Custom Duration': 'custom',
};

async function startAmphetamineSession() {
  // choose duration from presets
  const selectedPreset = await arg('Choose session duration:', Object.keys(DURATION_PRESETS));

  let durationHours = DURATION_PRESETS[selectedPreset];

  // Handle custom duration input
  if (durationHours === 'custom') {
    // const argConfig: PromptConfig = {}
    const customHours = await arg({
      placeholder: 'Enter custom duration in hours (can use decimals):',
      validate: async (input) => {
        const num = parseFloat(input);
        if (isNaN(num) || num <= 0) return 'Please enter a valid positive number';
        return true;
      },
    });
    durationHours = parseFloat(customHours);
  }

  // Convert hours to minutes for AppleScript
  const durationMinutes = Math.round(durationHours * 60);

  // Construct and run the AppleScript command
  const script = `tell application "Amphetamine" to start new session with options { duration:${durationMinutes}, interval:minutes, displaySleepAllowed:false }`;

  try {
    await exec(`osascript -e '${script}'`);
    notify({
      title: 'Amphetamine Session Started',
      body: `Session started for ${durationHours} hour${durationHours === 1 ? '' : 's'}`,
    });
  } catch (error) {
    notify({
      title: 'Error',
      body: 'Failed to start Amphetamine session',
    });
    console.error('Error:', error);
  }
}

await startAmphetamineSession();
