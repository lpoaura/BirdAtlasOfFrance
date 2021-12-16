module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
  },
  requireConfigFile: false,
  parserOptions: {
    parser: '@babel/eslint-parser',
  },
  extends: [
    '@nuxtjs',
    'prettier',
    'plugin:prettier/recommended',
    'plugin:nuxt/recommended',
  ],
  plugins: ['prettier'],
  // add your custom rules here
  rules: {
    'no-console': 'off',
    'vue/no-v-html': 'off',
    'unicorn/escape-case': 'off',
  },
}
