<template>
  <v-container fluid>
    <home-search-section />
    <home-news-section />
    <home-key-data-section />
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
