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
  // mounted() {
  //   console.log(this.$i18n)
  //   // La locale courante est accessible depuis this.$i18n.localeProperties
  // },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>
