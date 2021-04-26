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
      <nuxt-content
        v-if="selectedMenuItem === '#get-involved'"
        :document="protocolGetInvolved"
      />
      <nuxt-content
        v-if="selectedMenuItem === '#documents'"
        :document="protocolDocuments"
      />
      <nuxt-content v-else :document="protocolDescription" />
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    protocolDescription: {},
    protocolGetInvolved: {},
    protocolDocuments: {},
    logo: '',
    title: '',
    subtitle: '',
    lastUpdate: '',
    menuItems: [
      { label: 'Description', route: '' },
      { label: 'Participer', route: '#get-involved' },
      { label: 'Bilans', route: '#documents' },
    ],
    selectedMenuItem: '',
  }),
  mounted() {
    const protocol = this.$route.params.protocol
    this.$content(`fr/protocols/${protocol}/description`)
      .fetch()
      .then((description) => {
        this.protocolDescription = description
        this.logo = description.logo
        this.title = description.title
        this.subtitle = description.subtitle
        this.lastUpdate = this.$formatDate(description.updatedAt)
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`fr/protocols/${protocol}/participer`)
      .fetch()
      .then((getInvolved) => {
        this.protocolGetInvolved = getInvolved
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`fr/protocols/${protocol}/documents`)
      .fetch()
      .then((documents) => {
        console.log(documents)
        this.protocolDocuments = documents
      })
      .catch((error) => {
        console.log(error)
      })
  },
  methods: {
    updateSelectedMenuItem(route) {
      this.selectedMenuItem = route
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
