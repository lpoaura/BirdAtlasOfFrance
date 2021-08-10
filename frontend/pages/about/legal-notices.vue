<template>
  <informative-page :nuxt-content="nuxtContent" />
</template>

<script>
export default {
  data: () => ({
    nuxtContent: 'fr/mentions-legales',
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
@media screen and (max-width: 545px) {
  div.container.container--fluid >>> .TabMenu {
    display: none;
  }

  div.container.container--fluid >>> .DropdownListWrapper {
    display: block;
    margin-top: 16px;
    margin-bottom: 0;
  }
}
</style>
