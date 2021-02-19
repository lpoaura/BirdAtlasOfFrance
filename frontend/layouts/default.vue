<!-- NavBar différente selon les pages -->
<template>
  <v-app>
    <transparent-nav-bar v-if="$route.path === '/' && !scrolled" />
    <standard-nav-bar v-else />
    <v-main>
      <nuxt />
    </v-main>
    <v-footer :absolute="!fixed" app>
      <span>&copy; {{ new Date().getFullYear() }} </span>
    </v-footer>
  </v-app>
</template>

<script>
import TransparentNavBar from '~/components/Layouts/TransparentNavBar.vue'
import StandardNavBar from '~/components/Layouts/StandardNavBar.vue'

export default {
  components: {
    'transparent-nav-bar': TransparentNavBar,
    'standard-nav-bar': StandardNavBar,
  },
  data() {
    return {
      fixed: false,
      scrolled: false,
    }
  },
  created() {
    console.log('route : ' + this.$route.path)
  },
  beforeMount() {
    window.addEventListener('scroll', this.debounce(this.handleScroll))
  },
  beforeDestroy() {
    window.removeEventListener('scroll', this.debounce(this.handleScroll))
  },
  methods: {
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
