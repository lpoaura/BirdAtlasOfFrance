<template>
  <nav>
    <nuxt-link to="/" class="NavElement HomeIcon">
      <img src="/house.svg" />
    </nuxt-link>
    <div v-for="(crumb, index) in crumbs" :key="index" class="NavItem">
      <img class="NavElement NavItemChevron" src="/chevron-right.svg" />
      <nuxt-link :to="crumb.route" class="NavElement NavItemText">{{
        crumb.title
      }}</nuxt-link>
    </div>
  </nav>
</template>

<script>
export default {
  computed: {
    crumbs() {
      const routeItems = this.$route.path.endsWith('/')
        ? this.$route.path.slice(1, -1).split('/')
        : this.$route.path.substring(1).split('/')
      // console.log('routeItems : ' + routeItems)
      let path = ''
      const crumbs = []
      routeItems.forEach((item) => {
        path = `${path}/${item}`
        // console.log('path : ' + path)
        crumbs.push({
          title: this.$getPageTitle(path),
          route: path,
        })
        // console.log('crumbs : ' + this.crumbs)
      })
      return crumbs
    },
  },
}
</script>

<style scoped>
nav {
  height: 16px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
}

.NavElement {
  margin-right: 10px;
}

.HomeIcon {
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.NavItem {
  height: 100%;
  display: flex;
  align-items: center;
}

.NavItemChevron {
  height: 8px;
}

.NavItemText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 10px;
  line-height: 15px;
  color: #000;
}
</style>
