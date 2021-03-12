<!-- STOC, Observatoire Rapace -->
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
    <nuxt-content :document="protocolContent" />
  </v-container>
</template>

<script>
import InformativeHeader from '~/components/InformativeHeader.vue'

export default {
  components: {
    'informative-header': InformativeHeader,
  },
  data: () => ({
    protocolContent: {},
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
      .then((content) => {
        this.protocolContent = content
        console.log(this.protocolContent)
        this.logo = content.logo
        this.title = content.title
        this.subtitle = content.subtitle
        this.lastUpdate = content.updatedAt
      })
      .catch((error) => {
        // eslint-disable-next-line
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
</style>
