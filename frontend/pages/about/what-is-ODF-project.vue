<template>
  <informative-page :nuxt-content="nuxtContent" />
</template>

<script>
export default {
  data: () => ({
    nuxtContent: 'fr/projet-ODF',
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid :deep(.Logo) {
  width: 110px;
}

div.container.container--fluid :deep(.InformativePageLogo) {
  height: 60px;
}

/********** RESPONSIVE **********/

@media screen and (width <= 1300px) {
  div.container.container--fluid :deep(.TabMenu) {
    display: none;
  }

  div.container.container--fluid :deep(.DropdownListWrapper) {
    display: block;
    margin-top: 16px;
    margin-bottom: 0;
  }
}

@media screen and (width <= 680px) {
  div.container.container--fluid :deep(.Logo) {
    width: 80px;
  }
}
</style>
