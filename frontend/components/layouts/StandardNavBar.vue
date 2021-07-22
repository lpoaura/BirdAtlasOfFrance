<template>
  <header class="NavBar">
    <div class="NavBarODFLogoWrapper">
      <nuxt-link to="/" class="NavBarODFLogoLink">
        <img class="ODFLogo" src="/nav-bar/ODF-logo-black.svg" />
      </nuxt-link>
    </div>
    <nav>
      <nuxt-link
        v-for="(item, index) in navItems"
        :key="index"
        :to="item.route"
        class="NavBarItem"
        :class="[
          [item.route, `${item.route}/`].includes(
            `/${$route.path.substring(1).split('/')[0]}`
          )
            ? 'selected'
            : '',
        ]"
        >{{ item.label }}</nuxt-link
      >
    </nav>
    <div class="NavBarIconsMenu">
      <!-- <nuxt-link :to="switchLocalePath('en')" class="NavBarIconsWrapper" -->
      <!-- <nuxt-link to="#" class="NavBarIconsWrapper"
        ><img class="Icon" src="/nav-bar/language-FR-black.svg"
      /></nuxt-link> -->
      <nuxt-link to="/about/contact" class="NavBarIconsWrapper">
        <img class="NavBarIcon" src="/nav-bar/contact-black.svg" />
      </nuxt-link>
      <img
        class="NavBarBurgerIcon"
        src="/nav-bar/burger-black.svg"
        @click="showMobileMenu"
      />
    </div>
  </header>
</template>

<script>
export default {
  props: {
    navItems: {
      type: Array,
      required: true,
    },
  },
  methods: {
    showMobileMenu() {
      this.$emit('showMobileMenu')
    },
  },
}
</script>

<style scoped>
header {
  background: #fcfcfc;
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
}

.NavBarItem {
  color: #262626;
}

.NavBarItem.selected {
  border-bottom-color: #262626;
}

.NavBarIconsWrapper {
  background: rgba(38, 38, 38, 0.1);
}
</style>
