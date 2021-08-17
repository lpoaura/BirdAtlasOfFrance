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
        @showMobileMenu="showMobileMenu"
      />
      <standard-nav-bar
        v-else
        :background-color="
          ['/news', '/en/news'].includes(
            $route.path.endsWith('/') && $route.path.length > 1
              ? $route.path.slice(0, -1)
              : $route.path
          ) && !scrolled
            ? 'transparent'
            : ''
        "
        :nav-items="navItems"
        @showMobileMenu="showMobileMenu"
      />
    </transition>
    <mobile-menu
      :display="displayMobileMenu"
      :top-position="currentScroll"
      :nav-items="navItems"
      @hideMobileMenu="hideMobileMenu"
    />
    <v-main>
      <nuxt />
    </v-main>
    <app-footer
      v-show="
        [
          '/',
          '/en',
          '/news',
          '/en/news',
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
import MobileMenu from '~/components/layouts/MobileMenu.vue'
import Footer from '~/components/layouts/Footer.vue'

export default {
  components: {
    'transparent-nav-bar': TransparentNavBar,
    'standard-nav-bar': StandardNavBar,
    'mobile-menu': MobileMenu,
    'app-footer': Footer,
  },
  data: () => ({
    scrolled: false,
    displayMobileMenu: false,
    currentScroll: 0,
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
    window.addEventListener('scroll', this.listener)
    if (this.detectMobile()) {
      this.$router.push('/mobile')
    }
  },
  beforeDestroy() {
    window.removeEventListener('scroll', this.listener)
  },
  methods: {
    detectMobile() {
      return window.innerWidth < 915
    },
    showMobileMenu() {
      document.documentElement.style.overflow = 'hidden'
      this.currentScroll = window.scrollY
      this.displayMobileMenu = true
    },
    hideMobileMenu() {
      this.displayMobileMenu = false
      document.documentElement.style.overflow = 'auto'
    },
    listener() {
      this.$debounce(this.handleScroll())
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
