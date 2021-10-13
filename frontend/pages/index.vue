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
  // mounted() {
  //   console.log(this.$i18n)
  //   // La locale courante est accessible depuis this.$i18n.localeProperties
  //   this.$axios
  //     .$get(
  //       'https://www.xeno-canto.org/api/2/recordings?query=Circus+pygargus+cnt:France',
  //       {
  //         headers: {
  //           'Access-Control-Allow-Origin': '*',
  //           'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE,PATCH,OPTIONS',
  //           'Access-Control-Allow-Credentials': true,
  //         },
  //       }
  //     )
  //     .then((data) => {
  //       console.log(data)
  //     })
  //     .catch((error) => {
  //       console.log(error)
  //     })
  // },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>
