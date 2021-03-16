<!-- Partenaires -->
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
        :document="pageGetInvolved"
      />
      <nuxt-content
        v-else-if="selectedMenuItem === '#who-we-are'"
        :document="pageWhoWeAre"
      />
      <nuxt-content
        v-else-if="selectedMenuItem === '#partners'"
        :document="pagePartners"
      />
      <nuxt-content v-else :document="pageDescription" />
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    pageDescription: {},
    pageGetInvolved: {},
    pageWhoWeAre: {},
    pagePartners: {},
    logo: '',
    title: '',
    subtitle: '',
    lastUpdate: '',
    menuItems: [
      { label: 'Description', routerPath: '' },
      { label: 'Participer', routerPath: '#get-involved' },
      { label: 'Qui sommes-nous ?', routerPath: '#who-we-are' },
      { label: 'Partenaires', routerPath: '#partners' },
    ],
    selectedMenuItem: '',
  }),
  mounted() {
    // this.$content(`what-is-ODF-project`)
    //   .sortBy('order')
    //   .fetch()
    //   .then((test) => {
    //     console.log(test)
    //   })
    //   .catch((error) => {
    //     console.log(error)
    //   })
    this.$content(`what-is-ODF-project/description`)
      .fetch()
      .then((description) => {
        this.pageDescription = description
        this.logo = description.logo
        this.title = description.title
        this.subtitle = description.subtitle
        this.lastUpdate = this.$formatDate(description.updatedAt)
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`what-is-ODF-project/participer`)
      .fetch()
      .then((getInvolved) => {
        this.pageGetInvolved = getInvolved
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`what-is-ODF-project/qui-sommes-nous`)
      .fetch()
      .then((whoWeAre) => {
        this.pageWhoWeAre = whoWeAre
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`what-is-ODF-project/partenaires`)
      .fetch()
      .then((partners) => {
        this.pagePartners = partners
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
    title: 'ODF quésaco ?',
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

.Logo {
  height: 60px;
}
</style>
