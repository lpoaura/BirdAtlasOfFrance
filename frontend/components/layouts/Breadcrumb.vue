<template>
  <nav>
    <nuxt-link to="/" class="NavElement HomeIcon">
      <img src="/house.svg" />
    </nuxt-link>
    <div v-for="(crumb, index) in crumbs" :key="index" class="NavItem">
      <img class="NavElement NavItemChevron" src="/chevron-right.svg" />
      <nuxt-link :to="crumb.route" class="NavElement NavItemText"
        ><h6 class="black02 fw-500">{{ crumb.title }}</h6></nuxt-link
      >
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
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.NavElement {
  margin-right: 10px;
}

.HomeIcon {
  height: 16px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.NavItem {
  display: flex;
  align-items: center;
}

.NavItem:last-child h6.fw-500 {
  font-weight: 600;
  white-space: nowrap;
  overflow-x: hidden;
  text-overflow: ellipsis;
}

.NavItemChevron {
  height: 8px;
}
</style>
