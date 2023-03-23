<template>
  <v-container fluid>
    <search-section />
    <news-section />
    <key-data-section />
  </v-container>
</template>

<script>
import SearchSection from '~/components/home/SearchSection.vue'
import KeyDataSection from '~/components/home/KeyDataSection.vue'
import NewsSection from '~/components/home/NewsSection.vue'

export default {
  components: {
    'search-section': SearchSection,
    'key-data-section': KeyDataSection,
    'news-section': NewsSection,
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>
