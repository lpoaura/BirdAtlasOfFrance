<template>
  <section
    v-if="display"
    class="MobileMenu"
    :style="{ top: topPosition + 'px' }"
  >
    <header>
      <div class="NavBarODFLogoWrapper">
        <nuxt-link to="/" class="NavBarODFLogoLink">
          <img class="ODFLogo" src="/nav-bar/ODF-logo-black.svg" />
        </nuxt-link>
      </div>
      <div class="NavBarIconsMenu">
        <img
          class="NavBarCloseIcon"
          src="/cross.svg"
          @click="hideMobileMenu(0)"
        />
      </div>
    </header>
    <nav>
      <div
        v-for="(item, index) in navItems"
        :key="index"
        class="NavBarItemWrapper"
      >
        <nuxt-link
          :to="item.route"
          class="NavBarItem"
          :class="
            [item.route, `${item.route}/`].includes(
              `/${$route.path.substring(1)}`
            )
              ? 'selected'
              : ''
          "
          @click.native="hideMobileMenu(200)"
        >
          {{ item.label }}
        </nuxt-link>
      </div>
      <div class="NavBarItemWrapper">
        <nuxt-link
          to="/about/contact"
          class="NavBarItem"
          :class="
            ['/about/contact', '/about/contact/'].includes(
              `/${$route.path.substring(1)}`
            )
              ? 'selected'
              : ''
          "
          @click.native="hideMobileMenu(200)"
        >
          Aide
        </nuxt-link>
      </div>
    </nav>
  </section>
</template>

<script>
export default {
  props: {
    display: {
      type: Boolean,
      required: true,
    },
    topPosition: {
      type: Number,
      required: true,
    },
    navItems: {
      type: Array,
      required: true,
    },
  },
  beforeMount() {
    if (this.$detectMobile()) {
      // First we get the viewport height and we multiple it by 1% to get a value for a vh unit
      const vh = window.innerHeight * 0.01
      // Then we set the value in the --vh custom property to the root of the document
      document.documentElement.style.setProperty('--vh', `${vh}px`)
      window.addEventListener('resize', this.listener)
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.listener)
  },
  methods: {
    hideMobileMenu(timeout) {
      setTimeout(() => {
        this.$emit('hideMobileMenu')
      }, timeout)
    },
    listener() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      const vh = window.innerHeight * 0.01
      document.documentElement.style.setProperty('--vh', `${vh}px`)
    },
  },
}
</script>

<style scoped>
.MobileMenu {
  position: absolute;
  z-index: 11;
  left: 0;
  width: 100vw;
  height: 100vh;
  height: calc(var(--vh, 1vh) * 100);
  background: linear-gradient(rgba(57, 118, 90, 0.1), rgba(57, 118, 90, 0.1)),
    white;
  display: flex;
  flex-direction: column;
}

header {
  width: 100%;
  height: 68px;
  margin-bottom: 40px;
  padding: 0 5%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

nav {
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.NavBarItemWrapper {
  height: 28px;
  min-height: 28px;
  margin-bottom: 24px;
  display: flex;
  justify-content: center;
}

.NavBarItem {
  height: 100%;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
}

.NavBarItem.selected {
  border-bottom-color: #262626;
}
</style>
