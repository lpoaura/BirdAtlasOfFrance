<template>
  <v-container fluid>
    <h1>Fiche espèce {{ cdnom }}</h1>
  </v-container>
</template>

<script>
export default {
  computed: {
    cdnom() {
      return this.$route.params.cdnom
    },
  },
  head: {
    title: 'Fiche espèce',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}
</style>
