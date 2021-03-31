<template>
  <v-container fluid>
    <h1>Comment pouvons-nous vous aider ?</h1>
  </v-container>
</template>

<script>
export default {
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 80px;
}
</style>
