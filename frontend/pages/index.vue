<template>
  <v-container fluid>
    <search-section />
    <key-data-section />
  </v-container>
</template>

<script>
import SearchSection from '~/components/home/SearchSection.vue'
import KeyDataSection from '~/components/home/KeyDataSection.vue'

export default {
  components: {
    'search-section': SearchSection,
    'key-data-section': KeyDataSection,
  },
  head: {
    title: 'Accueil',
  },
}
</script>
