// Name: Get Email for Newsletter
// Description: Create email address with current domain interpolated

import '@johnlindquist/kit';

const createEmailWithDomain = (baseEmail: string, { url }: { url: string }) => {
  const [emailUser, emailDomain] = baseEmail.split('@');

  const urlObj = new URL(url);
  let domain = urlObj.host.split('.');

  // Only remove www if it's exactly the first subdomain
  if (domain[0] === 'www') {
    domain = domain.slice(1);
  }

  return `${emailUser}+${domain.join('-')}@${emailDomain}`;
};

let jxa = await npm('@jxa/run');

let result = await jxa.run(() => {
  // @ts-ignore - Application is a JXA global available in this context
  let windows = Application('com.google.Chrome').windows();
  let tab = windows[0].activeTab();

  return {
    url: tab.url(),
  };
});

const baseEmail = await env('PERSONAL_EMAIL');

await copy(createEmailWithDomain(baseEmail, result));
