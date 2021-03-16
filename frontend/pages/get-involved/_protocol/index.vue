<!-- Générer automatiquement les items du menu en fonction des fichiers md récupérés -->
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
      <div
        v-else-if="selectedMenuItem === '#documents'"
        class="InformativePageContent"
      >
        <div class="ProtocolsDocumentsContent">
          <div class="ProtocolsDocumentsCard"></div>
          <div class="ProtocolsDocumentsCard"></div>
          <div class="ProtocolsDocumentsCard"></div>
        </div>
      </div>
      <nuxt-content v-else :document="protocolDescription" />
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    protocolDescription: {},
    protocolGetInvolved: {},
    logo: '',
    title: '',
    subtitle: '',
    lastUpdate: '',
    menuItems: [
      { label: 'Description', routerPath: '' },
      { label: 'Participer', routerPath: '#get-involved' },
      { label: 'Bilans', routerPath: '#documents' },
    ],
    selectedMenuItem: '',
  }),
  mounted() {
    const protocol = this.$route.params.protocol
    this.$content(`protocols/${protocol}/description`)
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
    this.$content(`protocols/${protocol}/participer`)
      .fetch()
      .then((getInvolved) => {
        this.protocolGetInvolved = getInvolved
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
  head: {
    title: 'Fiche protocole',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 80px;
}

.InformativePageSection >>> .nuxt-content p {
  margin-bottom: 20px;
}
</style>
