<template>
  <header>
    <nuxt-link to="/" class="ODFLogo">
      <img src="/ODF-logo-white.svg" />
    </nuxt-link>
    <nav>
      <nuxt-link
        v-for="(item, index) in navItems"
        :key="index"
        :to="item.routerPath"
        class="NavItem"
        :style="[
          $route.path === item.routerPath
            ? {
                'font-weight': 'bold',
                'border-bottom': '3px solid #fcfcfc',
              }
            : {
                'font-weight': 'normal',
              },
        ]"
        >{{ item.label }}</nuxt-link
      >
    </nav>
    <div class="HeaderIcons">
      <nuxt-link to="#" class="ButtonsIcons"
        ><img class="Icon" src="/language-FR-white.svg"
      /></nuxt-link>
      <nuxt-link to="/support" class="ButtonsIcons"
        ><img class="Icon" src="/support-white.svg"
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
  text-decoration: none;
  font-size: 14px;
  line-height: 14px;
  color: #fcfcfc;
}

.HeaderIcons {
  flex: 1;
  display: flex;
  justify-content: flex-end;
}

.ButtonsIcons {
  background-color: rgba(252, 252, 252, 0.2);
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
