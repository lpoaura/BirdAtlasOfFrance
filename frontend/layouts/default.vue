<!-- NavBar différente selon les pages -->
<template>
  <v-app>
    <home-nav-bar />
    <v-main>
      <nuxt />
    </v-main>
    <v-footer :absolute="!fixed" app>
      <span>&copy; {{ new Date().getFullYear() }} </span>
    </v-footer>
  </v-app>
</template>

<script>
import HomeNavBar from '~/components/Layouts/HomeNavBar.vue'

export default {
  components: {
    'home-nav-bar': HomeNavBar,
  },
  data() {
    return {
      clipped: false,
      drawer: false,
      fixed: false,
      items: [
        {
          icon: 'mdi-apps',
          title: 'Accueil',
          to: '/',
        },
        {
          icon: 'mdi-compass',
          title: 'Prospection',
          to: '/prospecting',
        },
        {
          icon: 'mdi-chart-bubble',
          title: 'Vuetify example',
          to: '/vuetify-example',
        },
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'Atlas des Oiseaux de France',
    }
  },
}
</script>
