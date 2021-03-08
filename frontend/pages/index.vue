<template>
  <v-container fluid>
    <search-section />
    <key-data-section :key-data="keyData" />
  </v-container>
</template>

<script>
import SearchSection from '~/components/home/SearchSection.vue'
import KeyDataSection from '~/components/home/KeyDataSection.vue'

export default {
  // async asyncData({ $content }) {
  //   const news1 = await $content('news/news-1').fetch()
  //   return { news1 }
  // },
  components: {
    'search-section': SearchSection,
    'key-data-section': KeyDataSection,
  },
  async asyncData({ $axios }) {
    const keyData = await $axios.$get('/api/v1/general_stats')
    return { keyData }
  },
  head: {
    title: 'Accueil',
  },
}
</script>
