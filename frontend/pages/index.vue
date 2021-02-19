<!-- Définir la taille max pour chaque élément -->
<!-- Afficher la taille max si la hauteur d'écran descend sous une certaine valeur -->
<template>
  <v-container fluid>
    <search-section />
    <key-data-section />
  </v-container>
</template>

<script>
import SearchSection from '~/components/Home/SearchSection.vue'
import KeyDataSection from '~/components/Home/KeyDataSection.vue'

export default {
  // async asyncData({ $content }) {
  //   const news1 = await $content('news/news-1').fetch()
  //   return { news1 }
  // },
  components: {
    'search-section': SearchSection,
    'key-data-section': KeyDataSection,
  },
  head: {
    title: 'Accueil',
  },
}
</script>

<style scoped>
.container--fluid {
  padding: 0;
}
</style>
