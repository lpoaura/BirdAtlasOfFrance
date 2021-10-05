<template>
  <informative-page :nuxt-content="nuxtContent" />
</template>

<script>
export default {
  computed: {
    nuxtContent() {
      const protocol = this.$route.params.protocol
      return `fr/protocoles/${protocol}`
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
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
