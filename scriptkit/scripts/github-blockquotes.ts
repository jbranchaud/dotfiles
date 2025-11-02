// Name: GitHub Styled Blockquotes
// Description: Insert GitHub alert blockquote syntax
// Author: Josh Branchaud
// Shortcut: cmd+shift+g

import '@johnlindquist/kit';

const blockquoteTypes = [
  {
    name: 'Note',
    description: 'Highlights information that users should take into account, even when skimming',
    value: 'note',
  },
  {
    name: 'Tip',
    description: 'Optional information to help a user be more successful',
    value: 'tip',
  },
  {
    name: 'Important',
    description: 'Crucial information necessary for users to succeed',
    value: 'important',
  },
  {
    name: 'Warning',
    description: 'Critical content demanding immediate user attention due to potential risks',
    value: 'warning',
  },
  {
    name: 'Caution',
    description: 'Negative potential consequences of an action',
    value: 'caution',
  },
];

const selected = await arg(
  {
    placeholder: 'Select a GitHub alert type',
    hint: 'Pick the type of alert blockquote to insert',
  },
  blockquoteTypes.map((type) => ({
    name: type.name,
    description: type.description,
    value: type.value,
  })),
);

// Create the template based on selection
const templates = {
  note: `> [!NOTE]
> `,
  tip: `> [!TIP]
> `,
  important: `> [!IMPORTANT]
> `,
  warning: `> [!WARNING]
> `,
  caution: `> [!CAUTION]
> `,
};

const template = templates[selected];

// Set clipboard and paste into active text field
await setSelectedText(template);

// Show success notification
await notify({
  title: 'GitHub Alert Inserted',
  body: `${selected.toUpperCase()} blockquote template pasted`,
});
