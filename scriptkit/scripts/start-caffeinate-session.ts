// Name: Start Caffeinate Session
// Description: Start a caffeinate session to prevent sleep with specified duration
// Author: Josh Branchaud

import '@johnlindquist/kit';
import { spawn, exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

// Duration presets in hours
const DURATION_PRESETS = {
  '8 Hours': 8,
  '4 Hours': 4,
  '2 Hours': 2,
  '1 Hour': 1,
  'Custom Duration': 'custom',
};

interface CaffeinateStatus {
  isActive: boolean;
  remainingSeconds?: number;
  timeFormatted?: string;
}

async function checkCaffeinateStatus(): Promise<CaffeinateStatus> {
  try {
    const { stdout } = await execAsync('pmset -g assertions 2>/dev/null');

    if (stdout.includes('caffeinate')) {
      // Find the caffeinate assertion and search for timeout in its context
      // Use grep to get caffeinate line and next 10 lines, then search for timeout
      const { stdout: timeoutLine } = await execAsync(
        'pmset -g assertions 2>/dev/null | grep -A 10 "caffeinate" | grep "Timeout will fire in" || true',
      );

      if (timeoutLine) {
        const timeoutMatch = timeoutLine.match(/(\d+)\s+secs?/);

        if (timeoutMatch && timeoutMatch[1]) {
          const remainingSeconds = parseInt(timeoutMatch[1], 10);
          const hours = Math.floor(remainingSeconds / 3600);
          const minutes = Math.floor((remainingSeconds % 3600) / 60);
          const seconds = remainingSeconds % 60;
          const timeFormatted = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

          return {
            isActive: true,
            remainingSeconds,
            timeFormatted,
          };
        }
      }

      return { isActive: true };
    }

    return { isActive: false };
  } catch (error) {
    return { isActive: false };
  }
}

async function killCaffeinateSessions(): Promise<void> {
  try {
    await execAsync('pkill -x caffeinate 2>/dev/null');
    // Wait a moment for processes to terminate
    await new Promise((resolve) => setTimeout(resolve, 500));
  } catch (error) {
    // pkill returns non-zero if no processes found, which is fine
  }
}

async function startCaffeinateSession() {
  // Check for existing session
  const status = await checkCaffeinateStatus();

  // the action of this script defaults to 'new'
  let action = 'new';

  if (status.isActive) {
    const statusMessage = status.timeFormatted
      ? `Active caffeinate session found. Remaining time: ${status.timeFormatted} (${status.remainingSeconds} seconds)`
      : 'Active caffeinate session found (no timeout set)';

    action = await arg(
      {
        placeholder: statusMessage,
        hint: 'What would you like to do?',
      },
      [
        { name: 'Keep current session', value: 'keep' },
        { name: 'Replace with new session', value: 'replace' },
        { name: 'Cancel', value: 'cancel' },
      ],
    );

    if (action === 'keep' || action === 'cancel') {
      process.exit(0);
    }
  }

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
    // cancel existing caffeinate session if action is to 'replace'
    if (action === 'replace') {
      await killCaffeinateSessions();
    }

    // Start caffeinate as a detached background process
    // -d: prevent display from sleeping
    // -i: prevent system from idle sleeping
    // -t: specify timeout in seconds
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
