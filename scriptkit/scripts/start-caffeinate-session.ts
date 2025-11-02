// Name: Start Caffeinate Session
// Description: Start a caffeinate session to prevent sleep with specified duration
// Author: Josh Branchaud

import '@johnlindquist/kit';

// Duration presets in hours
const DURATION_PRESETS = {
  '8 Hours': 8,
  '4 Hours': 4,
  '2 Hours': 2,
  '1 Hour': 1,
  'Custom Duration': 'custom',
};

async function startCaffeinateSession() {
  // Choose duration from presets
  const selectedPreset = await arg('Choose session duration:', Object.keys(DURATION_PRESETS));

  let durationHours = DURATION_PRESETS[selectedPreset];

  // Handle custom duration input
  if (durationHours === 'custom') {
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

  // Convert hours to seconds for caffeinate
  const durationSeconds = Math.round(durationHours * 3600);

  try {
    // Start caffeinate as a detached background process
    // -d: prevent display from sleeping
    // -i: prevent system from idle sleeping
    // -t: specify timeout in seconds
    const { spawn } = require('child_process');
    const caffeinateProcess = spawn('caffeinate', ['-d', '-i', '-t', durationSeconds.toString()], {
      detached: true,
      stdio: 'ignore',
    });

    // Detach the process from the parent
    caffeinateProcess.unref();

    await notify({
      title: 'Caffeinate Session Started',
      body: `System will stay awake for ${durationHours} hour${durationHours === 1 ? '' : 's'}`,
    });

    // Exit the script
    process.exit(0);
  } catch (error) {
    await notify({
      title: 'Error',
      body: 'Failed to start caffeinate session',
    });
    console.error('Error:', error);
    process.exit(1);
  }
}

await startCaffeinateSession();
