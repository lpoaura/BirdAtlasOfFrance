// import colors from 'vuetify/es5/util/colors'

export default {
  head: {
    titleTemplate: '%s | Atlas des Oiseaux de France',
    title: '',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      {
        hid: 'description',
        name: 'description',
        content:
          "Oiseaux de France est le plus ambitieux projet de science participative en cours sur les oiseaux. Il vise à mettre à jour et diffuser l’état des connaissances de l'avifaune française en période de nidification et d'hivernage, en France métropolitaine et en Outre-Mer.",
      },
      {
        hid: 'og:type',
        property: 'og:type',
        content: 'website',
      },
      {
        hid: 'og:url',
        property: 'og:url',
        content: 'https://www.oiseauxdefrance.org/',
      },
      {
        hid: 'og:title',
        property: 'og:title',
        content: 'Atlas des Oiseaux de France',
      },
      {
        hid: 'og:description',
        property: 'og:description',
        content:
          "Oiseaux de France est le plus ambitieux projet de science participative en cours sur les oiseaux. Il vise à mettre à jour et diffuser l’état des connaissances de l'avifaune française en période de nidification et d'hivernage, en France métropolitaine et en Outre-Mer.",
      },
      {
        hid: 'og:image',
        property: 'og:image',
        content: '/home/home-picture-0.webp',
      },
      {
        hid: 'twitter:card',
        property: 'twitter:card',
        content: 'summary_large_image',
      },
      {
        hid: 'twitter:url',
        property: 'twitter:url',
        content: 'https://oiseauxdefrance.org/',
      },
      {
        hid: 'twitter:title',
        property: 'twitter:title',
        content: 'Atlas des Oiseaux de France',
      },
      {
        hid: 'twitter:description',
        property: 'twitter:description',
        content:
          "Oiseaux de France est le plus ambitieux projet de science participative en cours sur les oiseaux. Il vise à mettre à jour et diffuser l’état des connaissances de l'avifaune française en période de nidification et d'hivernage, en France métropolitaine et en Outre-Mer.",
      },
      {
        hid: 'twitter:image',
        property: 'twitter:image',
        content: '/home/home-picture-0.webp',
      },
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.png' },
      {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css?family=Playfair+Display:900&display=swap',
        defer: true,
      },
      {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800,900&display=swap',
        defer: true,
      },
    ],
  },

  // Global CSS (https://go.nuxtjs.dev/config-css)
  css: ['~/assets/style.css'],

  // Plugins to run before rendering page (https://go.nuxtjs.dev/config-plugins)
  plugins: [
    '~/plugins/directives.js',
    '~/plugins/formatDate.js',
    '~/plugins/getLatestDate.js',
    '~/plugins/checkEmail.js',
    '~/plugins/toPercent.js',
    '~/plugins/thousandDelimiter.js',
    '~/plugins/generateCaptcha.js',
    '~/plugins/getPageTitle.js',
    '~/plugins/detectMobile.js',
    '~/plugins/departmentsList.js',
    '~/plugins/redLists.js',
    '~/plugins/animateScrollTo.js',
    '~/plugins/debounce.js',
    // { src: '~/plugins/vueLeaflet.js', ssr: false },
  ],

  // Auto import components (https://go.nuxtjs.dev/config-components)
  components: true,

  // Modules for dev and build (recommended) (https://go.nuxtjs.dev/config-modules)
  buildModules: [
    // https://go.nuxtjs.dev/eslint
    '@nuxtjs/eslint-module',
    // https://go.nuxtjs.dev/stylelint
    '@nuxtjs/stylelint-module',
    // https://go.nuxtjs.dev/vuetify
    '@nuxtjs/vuetify',
    // https://go.nuxtjs.dev/pwa
    // '@nuxtjs/pwa',
  ],

  // Modules (https://go.nuxtjs.dev/config-modules)
  modules: [
    '@nuxtjs/axios',
    '@nuxtjs/pwa',
    // '@nuxtjs/i18n',
    'nuxt-leaflet',
    '@nuxt/content',
    'nuxt-mail',
    'nuxt-clipboard',
    [
      'nuxt-matomo',
      {
        matomoUrl: '//webstats.lpo-aura.org/',
        siteId: 5,
      },
    ],
  ],

  // Axios module configuration (https://go.nuxtjs.dev/config-axios)
  loading: false,
  axios: {
    // baseURL: 'http://localhost:8888',
    proxy: true,
    retry: { retries: 5 },
  },
  // publicRuntimeConfig: {
  //   axios: {
  //     browserBaseURL: process.env.API_URL,
  //   },
  // },
  proxy: {
    '/api/taxa': process.env.TAXREF_URL || 'https://taxref.mnhn.fr',
    '/api': process.env.API_URL || 'http://localhost:8888',
    '/taxhub': process.env.GEONATURE_URL || 'https://geonature.alx.host',
  },
  // PWA module configuration
  pwa: {
    meta: {
      /* meta options */
      name: 'Atlas des Oiseaux de France',
      author: 'LPO Agir pour la Biodiversité',
      theme_color: '#eb6a0aff',
    },
    manifest: {
      name: 'Atlas des Oiseaux de France',
      short_name: 'ODF',
      lang: 'fr',
      useWebmanifestExtension: false,
    },
    icon: {
      /* icon options */
    },
  },

  // i18n module configuration
  // i18n: {
  //   locales: [
  //     { code: 'fr', iso: 'fr-FR', name: 'FR' },
  //     { code: 'en', iso: 'en-US', name: 'EN' },
  //   ],
  //   defaultLocale: 'fr',
  //   vueI18n: {
  //     fallbackLocale: 'fr',
  //     messages: {
  //       fr: {
  //         home: 'Accueil',
  //         map: 'Carte',
  //         'get-involved': 'Participer',
  //         about: 'À propos',
  //       },
  //       en: {
  //         home: 'Home',
  //         map: 'Map',
  //         'get-involved': 'Get involved',
  //         about: 'About',
  //       },
  //     },
  //   },
  // },

  // Mail module configuration
  mail: {
    message: [
      {
        name: 'test',
        to: process.env.DEVELOPER_MAIL_1 || 'odf',
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'oiseauxdefrance',
        to: process.env.ODF_MAIL || 'odf',
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'stoc',
        to: process.env.STOC_MAIL || 'odf',
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'shoc',
        to: process.env.SHOC_MAIL || 'odf',
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'rapaces',
        to: process.env.OBS_RAPACES_MAIL || 'odf',
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'wetlands',
        to: process.env.WETLANDS_MAIL || 'odf',
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'technique',
        to: [
          process.env.DEVELOPER_MAIL_1 || 'odf',
          process.env.DEVELOPER_MAIL_2 || 'odf',
          process.env.ODF_MAIL || 'odf',
        ],
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'design',
        to: [
          process.env.DEVELOPER_MAIL_1 || 'odf',
          process.env.DESIGNER_MAIL_1 || 'odf',
          process.env.DESIGNER_MAIL_2 || 'odf',
          process.env.ODF_MAIL || 'odf',
        ],
        from: process.env.SMTP_LOGIN || 'odf',
      },
      {
        name: 'generalfeedback',
        to: [
          process.env.DEVELOPER_MAIL_1 || 'odf',
          process.env.ODF_MAIL || 'odf',
        ],
        from: process.env.SMTP_LOGIN || 'odf',
      },
    ],
    smtp: {
      host: process.env.SMTP_HOST || 'smtp',
      port: process.env.SMTP_PORT || 587,
      // secure: false,
      // requireTLS: true,
      auth: {
        user: process.env.SMTP_LOGIN || 'odf',
        pass: process.env.SMTP_PWD || 'odf',
      },
    },
  },

  // Vuetify module configuration (https://go.nuxtjs.dev/config-vuetify)
  vuetify: {
    customVariables: ['~/assets/variables.scss'],
    defaultAssets: false,
    theme: {
      options: {
        customProperties: true,
      },
      dark: false,
      themes: {
        dark: {
          background: '#121212',
        },
        light: {
          background: '#fcfcfc',
        },
      },
    },
  },

  // Build Configuration (https://go.nuxtjs.dev/config-build)
  build: {},
}
