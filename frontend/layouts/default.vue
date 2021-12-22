<template>
  <v-app>
    <transition v-if="!$route.path.includes('/mobile')" name="navBar">
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
          $route.path.includes('/news') && !scrolled ? 'transparent' : ''
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
        !$route.path.includes('/prospecting') &&
        !$route.path.includes('/mobile')
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
    currentPath: '',
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
      this.currentScroll = window.scrollY
      this.currentPath = this.$route.path
      document.documentElement.style.overflow = 'hidden'
      document.body.style.position = 'fixed' // Needed for iOS
      document.body.style.top = `-${this.currentScroll}px` // Needed for iOS
      this.displayMobileMenu = true
    },
    hideMobileMenu() {
      if (!this.$route.path.includes('/prospecting')) {
        // Si on sélectionne un onglet (excepté l'onglet "Carte")
        document.documentElement.style.removeProperty('overflow')
        document.body.style.removeProperty('position')
      }
      document.body.style.removeProperty('top')
      if (this.currentPath === this.$route.path) {
        // Si on ferme le menu mobile sans changer de page
        window.scrollTo(0, this.currentScroll)
        setTimeout(() => {
          this.displayMobileMenu = false
        }, 250)
      } else {
        this.displayMobileMenu = false
      }
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
