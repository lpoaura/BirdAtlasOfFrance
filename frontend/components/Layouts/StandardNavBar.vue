<template>
  <header>
    <nuxt-link to="/" class="ODFLogo">
      <img src="/ODF-logo-black.svg" />
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
                'border-bottom': '3px solid #262626',
              }
            : {
                'font-weight': 'normal',
              },
        ]"
        >{{ item.label }}</nuxt-link
      >
    </nav>
    <div class="HeaderIcons">
      <nuxt-link to="#" class="Icon">
        <img src="/language-black.svg"
      /></nuxt-link>
      <nuxt-link to="/support" class="Icon"
        ><img src="/support-black.svg"
      /></nuxt-link>
    </div>
  </header>
</template>

<script>
export default {
  data: () => ({
    navItems: [
      {
        label: 'Accueil',
        routerPath: '/',
      },
      {
        label: 'Espèces',
        routerPath: '#',
      },
      {
        label: 'Carte',
        routerPath: '/prospecting',
      },
      {
        label: 'Participer',
        routerPath: '/get-involved',
      },
      {
        label: 'À propos',
        routerPath: '#',
      },
    ],
  }),
}
</script>

<style scoped>
header {
  position: fixed;
  z-index: 10;
  background-color: #fcfcfc;
  width: 100%;
  height: 80px;
  padding: 0 5%;
  border-bottom: 1px solid #efefef;
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
  color: #262626;
}

.HeaderIcons {
  flex: 1;
  height: 30%;
  display: flex;
  justify-content: flex-end;
}

.Icon {
  margin-left: 8%;
}
</style>
