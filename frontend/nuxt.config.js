// import colors from 'vuetify/es5/util/colors'

export default {
  // Global page headers (https://go.nuxtjs.dev/config-head)
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
        content: '/home/home-picture.jpg',
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
        content: '/home/home-picture.jpg',
      },
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.png' },
      {
        rel: 'stylesheet',
        href:
          'https://fonts.googleapis.com/css?family=Playfair+Display:300,400,500,600,700,800,900&display=swap',
      },
      {
        rel: 'stylesheet',
        href:
          'https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800,900&display=swap',
      },
    ],
  },

  // Global CSS (https://go.nuxtjs.dev/config-css)
  css: ['~/assets/style.css'],

  // Plugins to run before rendering page (https://go.nuxtjs.dev/config-plugins)
  plugins: [
    '~/plugins/directives.js',
    '~/plugins/formatDate.js',
    '~/plugins/toPercent.js',
    '~/plugins/thousandDelimiter.js',
    '~/plugins/getPageTitle.js',
    '~/plugins/departmentsList.js',
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
    '@nuxtjs/pwa',
  ],

  // Modules (https://go.nuxtjs.dev/config-modules)
  modules: [
    // https://go.nuxtjs.dev/axios
    '@nuxtjs/axios',
    // https://go.nuxtjs.dev/pwa
    '@nuxtjs/pwa',
    'nuxt-leaflet',
    '@nuxt/content',
    // 'nuxt-i18n',
    'nuxt-clipboard',
  ],

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

  // Axios module configuration (https://go.nuxtjs.dev/config-axios)
  loading: false,
  axios: {
    baseURL: 'http://localhost:8888',
  },
  // privateRuntimeConfig: {
  //   axios: {
  //     baseURL: process.env.API_URL,
  //   },
  // },
  publicRuntimeConfig: {
    axios: {
      browserBaseURL: process.env.API_URL,
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

  // Vuetify module configuration (https://go.nuxtjs.dev/config-vuetify)
  vuetify: {
    customVariables: ['~/assets/variables.scss'],
    theme: {
      options: {
        customProperties: true,
      },
      dark: false,
      themes: {
        dark: {
          background: '#121212',
          //   primary: colors.blue.darken2,
          //   accent: colors.grey.darken3,
          //   secondary: colors.amber.darken3,
          //   info: colors.teal.lighten1,
          //   warning: colors.amber.base,
          //   error: colors.deepOrange.accent4,
          //   success: colors.green.accent3,
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
