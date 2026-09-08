// module.exports = {
//   customSyntax: 'postcss-html',
//   extends: ['stylelint-config-standard', 'stylelint-config-prettier'],
//   // add your custom config here
//   // https://stylelint.io/user-guide/configuration
//   rules: {
//     'selector-type-no-unknown': [
//       true,
//       {
//         ignoreTypes: ['/^v-/', '/^nuxt-/'],
//       },
//     ],
//     // 'selector-class-pattern': '^[A-Z][a-zA-Z0-9]+$',
//     'color-function-notation': 'legacy',
//     'alpha-value-notation': 'number',
//     'font-family-name-quotes': 'always-unless-keyword',
//   },
// }

module.exports = {
  customSyntax: 'postcss-html',
  extends: ['stylelint-config-standard', 'stylelint-config-recommended-vue'],
  // add your custom config here
  // https://stylelint.io/user-guide/configuration
  rules: {
    // PascalCase, camelCase, kebab-case, BEM (block__element--modifier), Vue transitions
    'selector-class-pattern':
      '^[a-zA-Z][a-zA-Z0-9]*(?:[-_]{1,2}[a-zA-Z0-9]+)*$',
    'color-function-notation': 'legacy',
    'alpha-value-notation': 'number',
    'font-family-name-quotes': 'always-unless-keyword',
  },
}
