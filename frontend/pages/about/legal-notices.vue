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
/********** RESPONSIVE **********/

@media screen and (width <= 600px) {
  div.container.container--fluid :deep(.TabMenu) {
    display: none;
  }

  div.container.container--fluid :deep(.DropdownListWrapper) {
    display: block;
    margin-top: 16px;
    margin-bottom: 0;
  }
}
</style>
