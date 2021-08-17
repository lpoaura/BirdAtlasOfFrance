<template>
  <header class="NavBar">
    <div class="NavBarODFLogoWrapper">
      <nuxt-link to="/" class="NavBarODFLogoLink">
        <img class="ODFLogo" src="/nav-bar/ODF-logo-white.svg" />
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
        ><img class="Icon" src="/nav-bar/language-FR-white.svg"
      /></nuxt-link> -->
      <nuxt-link to="/about/contact" class="NavBarIconsWrapper">
        <img class="NavBarIcon" src="/nav-bar/contact-white.svg" />
      </nuxt-link>
      <img
        class="NavBarBurgerIcon"
        src="/nav-bar/burger-white.svg"
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
.NavBarItem {
  color: #fcfcfc;
}

.NavBarItem.selected {
  border-bottom-color: #fcfcfc;
}

.NavBarIconsWrapper {
  background: rgba(252, 252, 252, 0.2);
}
</style>
