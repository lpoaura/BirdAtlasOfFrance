<template>
  <informative-page :nuxt-content="nuxtContent" />
</template>

<script>
export default {
  data: () => ({
    nuxtContent: 'fr/what-is-ODF-project',
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid >>> .Logo {
  width: 110px;
}

div.container.container--fluid >>> .InformativePageLogo {
  height: 60px;
}

@media screen and (max-width: 1240px) {
  div.container.container--fluid >>> .TabMenu {
    display: none;
  }

  div.container.container--fluid >>> .DropdownListWrapper {
    display: block;
    margin-top: 16px;
    margin-bottom: 0;
  }
}

@media screen and (max-width: 680px) {
  div.container.container--fluid >>> .Logo {
    width: 80px;
  }
}
</style>
