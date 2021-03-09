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
  data: () => ({
    keyData: {
      prospecting_hours: {
        all_period: 0,
        breeding: 0,
        wintering: 0,
      },
      count_taxa: {
        all_period: 0,
        breeding: 0,
        wintering: 0,
      },
    },
  }),
  mounted() {
    this.$axios
      .$get('/api/v1/general_stats')
      .then((data) => {
        this.keyData = data
      })
      .catch((error) => {
        console.log(error)
      })
  },
  head: {
    title: 'Accueil',
  },
}
</script>
