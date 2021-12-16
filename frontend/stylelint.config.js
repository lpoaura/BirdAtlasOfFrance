module.exports = {
  extends: [
    'stylelint-config-standard-scss',
    'stylelint-config-standard',
    'stylelint-config-prettier',
  ],
  // add your custom config here
  // https://stylelint.io/user-guide/configuration
  rules: {
    'selector-type-no-unknown': [
      true,
      {
        ignoreTypes: ['/^v-/', '/^nuxt-/'],
      },
    ],
  },
}
