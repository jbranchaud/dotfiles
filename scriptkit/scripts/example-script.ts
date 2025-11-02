// Name: Example Script
// Description: A simple example script for your dotfiles kenv
// Author: Your Name
// Shortcut: cmd+shift+e

import '@johnlindquist/kit';

const message = await arg('What would you like to say?');
await notify({
  title: 'Example Script',
  body: message,
});
