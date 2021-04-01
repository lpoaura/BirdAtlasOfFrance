<!-- Générer automatiquement la page entière (composant/v-show) en fonction des fichiers md récupérés -->
<template>
  <v-container fluid>
    <informative-header
      :logo="logo"
      :title="title"
      :subtitle="subtitle"
      :last-update="lastUpdate"
      :menu-items="menuItems"
      @selectedMenuItem="updateSelectedMenuItem"
    />
    <section class="InformativePageSection">
      <nuxt-content v-show="selectedMenuItem === '#cgu'" :document="pageCGU" />
      <nuxt-content
        v-show="selectedMenuItem === ''"
        :document="pageLegalNotices"
      />
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    pageLegalNotices: {},
    pageCGU: {},
    logo: '',
    title: '',
    subtitle: '',
    lastUpdate: '',
    menuItems: [
      { label: 'Mentions légales', routerPath: '' },
      { label: 'CGU', routerPath: '#cgu' },
    ],
    selectedMenuItem: '',
  }),
  mounted() {
    this.$content(`fr/mentions-legales/mentions-legales`)
      .fetch()
      .then((legalNotices) => {
        this.pageLegalNotices = legalNotices
        this.logo = legalNotices.logo
        this.title = legalNotices.title
        this.subtitle = legalNotices.subtitle
        this.lastUpdate = this.$formatDate(legalNotices.updatedAt)
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`fr/mentions-legales/CGU`)
      .fetch()
      .then((cgu) => {
        this.pageCGU = cgu
      })
      .catch((error) => {
        console.log(error)
      })
  },
  methods: {
    updateSelectedMenuItem(routerPath) {
      this.selectedMenuItem = routerPath
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}
</style>
