<template>
  <header>
    <nuxt-link to="/" class="ODFLogo">
      <img src="/nav-bar/ODF-logo-white.svg" />
    </nuxt-link>
    <nav>
      <nuxt-link
        v-for="(item, index) in navItems"
        :key="index"
        :to="item.routerPath"
        class="NavItem"
        :class="[
          [item.routerPath, `${item.routerPath}/`].includes(
            `/${$route.path.substring(1).split('/')[0]}`
          )
            ? 'selected'
            : '',
        ]"
        >{{ item.label }}</nuxt-link
      >
    </nav>
    <div class="HeaderIcons">
      <nuxt-link to="#" class="ButtonsIcons"
        ><img class="Icon" src="/nav-bar/language-FR-white.svg"
      /></nuxt-link>
      <nuxt-link to="/about/contact" class="ButtonsIcons"
        ><img class="Icon" src="/nav-bar/contact-white.svg"
      /></nuxt-link>
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
}
</script>

<style scoped>
header {
  position: fixed;
  z-index: 10;
  width: 100%;
  height: 80px;
  padding: 0 5%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.ODFLogo {
  flex: 1;
  height: 50%;
  display: flex;
}

nav {
  flex: 2;
  height: 47px;
  align-self: flex-end;
  display: flex;
  justify-content: space-between;
}

.NavItem {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  text-decoration: none;
  font-size: 14px;
  line-height: 14px;
  color: #fcfcfc;
}

.NavItem.selected {
  font-weight: bold;
  border-bottom: 3px solid #fcfcfc;
}

.HeaderIcons {
  flex: 1;
  display: flex;
  justify-content: flex-end;
}

.ButtonsIcons {
  background: rgba(252, 252, 252, 0.2);
  width: 32px;
  height: 32px;
  border-radius: 4px;
  margin-left: 4%;
  display: flex;
}

.Icon {
  height: 16px;
  margin: auto;
}
</style>
