<template>
  <informative-page :nuxt-content="nuxtContent" />
</template>

<script>
export default {
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  computed: {
    nuxtContent() {
      const protocol = this.$route.params.protocol
      return `fr/protocoles/${protocol}`
    },
  },
}
</script>

<style scoped>
/********** RESPONSIVE **********/

@media screen and (width <= 680px) {
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
