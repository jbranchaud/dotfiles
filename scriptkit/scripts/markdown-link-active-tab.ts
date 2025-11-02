// Name: Markdown-Linkify Chrome Tab
// Description: Copy markdown link for current Chrome tab
// Shortcut: control option v

import '@johnlindquist/kit';

const turnTitleAndUrlIntoMarkdownLink = ({ title: _title, url }) => {
  // in case the title is blank, use the URL as the title
  const titleIsPresent = _title && _title.trim !== '';
  const title = titleIsPresent ? _title : url;

  // combine the title and URL into a markdown link
  const markdownLink = `[${title}](${url})`;

  return markdownLink;
};

let jxa = await npm('@jxa/run');

let result = await jxa.run(() => {
  // @ts-ignore - Application is a JXA global available in this context
  let windows = Application('com.google.Chrome').windows();
  let tab = windows[0].activeTab();

  return {
    url: tab.url(),
    title: tab.title(),
  };
});

await copy(turnTitleAndUrlIntoMarkdownLink(result));
