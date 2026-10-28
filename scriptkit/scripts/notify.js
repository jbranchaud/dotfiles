// Name: Notify
// Description: Send a system notification
import '@johnlindquist/kit';

let message = await arg('Notification message');

// notify global only available in Kit.app context, use terminal-notifier for CLI
if (typeof notify !== 'undefined') {
  await notify(message);
} else {
  await execa('terminal-notifier', ['-title', 'Script Kit', '-message', message]);
}
