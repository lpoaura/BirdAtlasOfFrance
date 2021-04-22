<!-- Faire une unique navbar -->
<template>
  <v-app>
    <transition
      v-if="!['/mobile', '/mobile/'].includes($route.path)"
      name="navBar"
    >
      <transparent-nav-bar
        v-if="
          [
            '/',
            '/en',
            '/get-involved',
            '/en/get-involved',
            '/about',
            '/en/about',
          ].includes(
            $route.path.endsWith('/') && $route.path.length > 1
              ? $route.path.slice(0, -1)
              : $route.path
          ) && !scrolled
        "
        :nav-items="navItems"
      />
      <standard-nav-bar v-else :nav-items="navItems" />
    </transition>
    <v-main>
      <nuxt />
    </v-main>
    <app-footer
      v-show="
        [
          '/',
          '/en',
          '/get-involved',
          '/en/get-involved',
          '/about',
          '/en/about',
        ].includes(
          $route.path.endsWith('/') && $route.path.length > 1
            ? $route.path.slice(0, -1)
            : $route.path
        )
      "
    />
  </v-app>
</template>

<script>
import TransparentNavBar from '~/components/layouts/TransparentNavBar.vue'
import StandardNavBar from '~/components/layouts/StandardNavBar.vue'
import Footer from '~/components/layouts/Footer.vue'

export default {
  components: {
    'transparent-nav-bar': TransparentNavBar,
    'standard-nav-bar': StandardNavBar,
    'app-footer': Footer,
  },
  data: () => ({
    scrolled: false,
  }),
  computed: {
    navItems() {
      return [
        {
          // label: this.$t('home'),
          label: 'Accueil',
          route: '/',
        },
        // {
        //   label: 'Espèces',
        //   route: '#',
        // },
        {
          // label: this.$t('map'),
          label: 'Carte',
          route: '/prospecting',
        },
        {
          // label: this.$t('get-involved'),
          label: 'Participer',
          route: '/get-involved',
        },
        {
          // label: this.$t('about'),
          label: 'À propos',
          route: '/about',
        },
      ]
    },
  },
  beforeMount() {
    window.addEventListener('scroll', this.debounce(this.handleScroll))
    if (this.detectMobile()) {
      this.$router.push('/mobile')
    }
  },
  beforeDestroy() {
    window.removeEventListener('scroll', this.debounce(this.handleScroll))
  },
  methods: {
    detectMobile() {
      return window.innerWidth < 915
    },
    debounce(fn) {
      // This holds the requestAnimationFrame reference, so we can cancel it if we wish
      let frame
      // The debounce function returns a new function that can receive a variable number of arguments
      return (...params) => {
        // If the frame variable has been defined, clear it now, and queue for next frame
        if (frame) {
          cancelAnimationFrame(frame)
        }
        // Queue our function call for the next frame
        frame = requestAnimationFrame(() => {
          // Call our function and pass any params we received
          fn(...params)
        })
      }
    },
    handleScroll() {
      this.scrolled = window.scrollY > 0
    },
  },
}
</script>

<style scoped>
.theme--light.v-application {
  background-color: var(--v-background-base, #fcfcfc) !important;
}

.theme--dark.v-application {
  background-color: var(--v-background-base, #121212) !important;
}

.navBar-enter-active,
.navBar-leave-active {
  transition: opacity 0.3s;
}
.navBar-enter,
.navBar-leave-to {
  opacity: 0;
}
</style>
