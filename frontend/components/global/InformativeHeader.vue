<template>
  <header>
    <breadcrumb />
    <div class="HeaderContent">
      <div class="LogoWrapper">
        <img class="Logo" :src="logo" />
      </div>
      <div class="HeaderText">
        <h1 class="HeaderTitle">{{ title }}</h1>
        <h6 class="HeaderSubtitle">{{ subtitle }}</h6>
      </div>
    </div>
    <div class="HeaderMenu">
      <span class="HeaderLastUpdate">
        Dernière actualisation le {{ lastUpdate }}
      </span>
      <menu>
        <span
          v-for="(item, index) in menuItems"
          :key="index"
          :to="item.route"
          class="MenuItem"
          :class="[item.route === selectedMenuItem ? 'selected' : '']"
          @click="updateSelectedMenuItem(item)"
        >
          {{ item.label }}
        </span>
      </menu>
    </div>
  </header>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
  },
  props: {
    logo: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    subtitle: {
      type: String,
      required: true,
    },
    lastUpdate: {
      type: String,
      required: true,
    },
    menuItems: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
    selectedMenuItem: '',
  }),
  watch: {
    $route(newVal) {
      this.selectedMenuItem = newVal.hash
      this.$emit('selectedMenuItem', newVal.hash)
    },
  },
  mounted() {
    this.selectedMenuItem = this.$route.hash
    this.$emit('selectedMenuItem', this.selectedMenuItem)
  },
  methods: {
    updateSelectedMenuItem(item) {
      this.$router.push(`${item.route}`)
    },
  },
}
</script>

<style scoped>
header {
  background: #fcfcfc;
  border-bottom: 1px solid rgba(51, 105, 80, 0.2);
  width: 100%;
  height: 262px;
  padding: 1.4% 16%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.HeaderContent {
  width: 100%;
  display: flex;
  align-items: center;
}

.LogoWrapper {
  min-width: 130px;
  max-width: 130px;
  height: 130px;
  margin-right: 3%;
  border: 4px solid rgba(0, 0, 0, 0.05);
  box-sizing: border-box;
  border-radius: 24px;
  display: flex;
}

.Logo {
  width: 90px;
  margin: auto;
}

.HeaderText {
  height: 60%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.HeaderTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 40px;
  line-height: 60px;
  color: #262626;
  white-space: nowrap;
}

.HeaderSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 300;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.HeaderMenu {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.HeaderLastUpdate {
  width: 50%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: rgba(38, 38, 38, 0.4);
}

menu {
  display: flex;
  justify-content: flex-end;
}

.MenuItem {
  border-radius: 8px;
  padding: 10px 20px;
  margin-left: 6px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  text-decoration: none;
  font-size: 14px;
  line-height: 21px;
  color: #000;
  white-space: nowrap;
}

.MenuItem.selected {
  background: rgba(57, 118, 90, 0.1);
  font-weight: bold;
  color: #39765a;
}
</style>
