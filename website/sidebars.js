// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  tutorialSidebar: [
    {
      type: 'category',
      label: 'Introduction',
      items: [
        'introduction/why-commands-cli',
        'introduction/features',
      ],
    },
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'getting-started/installation',
        'getting-started/your-first-command',
      ],
    },
    {
      type: 'category',
      label: 'Core Concepts',
      items: [
        'core-concepts/the-commands-yaml',
        'core-concepts/aliases',
        'core-concepts/passthrough-arguments',
      ],
    },
    {
      type: 'category',
      label: 'Parameters',
      items: [
        'parameters/positional-parameters',
        'parameters/named-parameters',
        'parameters/default-values',
        'parameters/typed-parameters',
        'parameters/enum-parameters',
      ],
    },
    {
      type: 'category',
      label: 'Switches',
      items: [
        'switches/basic-switches',
        'switches/interactive-switches',
        'switches/switches-with-parameters',
      ],
    },
    {
      type: 'category',
      label: 'Advanced Topics',
      items: [
        'advanced-topics/overriding-commands',
      ],
    },
    {
      type: 'category',
      label: 'Cookbook',
      items: [
        'cookbook/multi-line-scripts',
        'cookbook/combining-switches-and-enums',
      ],
    },
  ],
};

export default sidebars;
