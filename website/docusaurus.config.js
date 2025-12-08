import { themes as prismThemes } from 'prism-react-renderer';
const config = {
  title: 'Commands CLI',
  tagline: 'Make your CLI commands feel like a breeze',
  favicon: 'img/favicon.ico',
  future: {
    v4: true,
  },

  url: 'https://nikoro.github.io',
  baseUrl: '/commands_cli/',
  organizationName: 'Nikoro',
  projectName: 'commands_cli',
  onBrokenLinks: 'throw',
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.js',
          editUrl:
            'https://github.com/Nikoro/commands_cli/tree/main/website/docs/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      },
    ],
  ],
  themeConfig: {
      image: 'img/logo.webp',
      colorMode: {
        defaultMode: "dark",
      },
      navbar: {
        title: "Commands CLI",
        logo: {
          alt: 'Commands CLI Logo',
          src: 'img/logo_short.webp',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            label: 'Docs',
            position: 'right',
          },
          {
            href: 'https://github.com/Nikoro/commands_cli',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        copyright: `Copyright © ${new Date().getFullYear()} Dominik Krajcer.<br /> Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        defaultLanguage: 'yaml',
      },
    },
  };
  export default config;
