<template>
  <header>
    <div class="ODFLogo">
      <img src="/ODF-logo-white.svg" />
    </div>
    <nav>
      <div class="HomeNavItem">Accueil</div>
      <router-link
        v-for="(item, index) in navItems"
        :key="index"
        :to="item.routerPath"
        class="NavItem"
        >{{ item.label }}</router-link
      >
    </nav>
    <div class="HeaderIcons">
      <router-link to="#" class="Icon">
        <img src="/language-white.svg"
      /></router-link>
      <router-link to="/support" class="Icon"
        ><img src="/support-white.svg"
      /></router-link>
    </div>
  </header>
</template>

<script>
export default {
  data: () => ({
    navItems: [
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

.HomeNavItem {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 14px;
  line-height: 14px;
  color: #fcfcfc;
  border-bottom: 3px solid #fcfcfc;
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
