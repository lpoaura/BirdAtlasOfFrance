<template>
  <v-container fluid>
    <section class="IntroSection">
      <div class="BackgroundPicture">
        <header class="IntroContent">
          <h1 class="IntroTitle">Participer via les dispositifs de suivi</h1>
          <h4 class="IntroSubtitle">
            Déterminer les <b>tendances</b> d'évolution et les
            <b>effectifs</b> chez les oiseaux<br />nécessite l'utilisation de
            dispositifs de suivi <b>adaptés</b>.
          </h4>
        </header>
      </div>
    </section>
    <menu>
      <span
        v-for="(item, index) in menuItems"
        :key="index"
        :to="item.routerPath"
        class="MenuItem"
        :class="[item.label === selectedSpeciesGroup ? 'selected' : '']"
        @click="updateSelectedSpeciesGroup(item)"
      >
        {{ item.label }}
      </span>
    </menu>
    <section class="ProtocolsSection">
      <protocols-cards :species-group-filter="selectedSpeciesGroup" />
    </section>
  </v-container>
</template>

<script>
import ProtocolsCards from '~/components/get-involved/ProtocolsCards.vue'

export default {
  components: {
    'protocols-cards': ProtocolsCards,
  },
  data: () => ({
    menuItems: [
      { label: 'Tous les dispositifs', routerPath: '' },
      { label: 'Oiseaux communs', routerPath: '#common-birds' },
      { label: 'Rapaces', routerPath: '#raptors' },
      { label: "Oiseaux d'eau", routerPath: '#water-birds' },
      // { label: 'autres', routerPath: '#other-birds' },
    ],
    // selectedMenuItem: '',
    selectedSpeciesGroup: 'Tous les dispositifs',
  }),
  // mounted() {
  //   this.selectedMenuItem = this.$route.hash
  // },
  methods: {
    updateSelectedSpeciesGroup(item) {
      this.selectedSpeciesGroup = item.label
      // this.selectedMenuItem = item.routerPath
      // this.$router.push(`${item.routerPath}`)
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
.IntroSection {
  position: relative;
  width: 100%;
  height: 336px;
}

.BackgroundPicture {
  position: relative;
  background: linear-gradient(
      94.13deg,
      rgba(37, 39, 69, 0.46) 5.97%,
      rgba(37, 39, 69, 0.76) 38.61%,
      rgba(37, 39, 69, 0.76) 76.76%,
      rgba(37, 39, 69, 0) 98.47%
    ),
    url('/get-involved/get-involved-picture.jpg') center / cover,
    rgba(47, 92, 105, 1);
  width: 100%;
  height: 100%;
  display: flex;
}

.IntroContent {
  position: absolute;
  z-index: 5;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  width: 100%;
  height: 30%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
}

.IntroTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 40px;
  line-height: 60px;
  text-align: center;
  color: #fcfcfc;
}

.IntroSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  text-align: center;
  color: #fff;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.25);
}

.ProtocolsSection {
  padding-left: 4vw;
  padding-bottom: 1%;
}

.ProtocolsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
  margin-left: 1.6vw;
  margin-bottom: 1.6vw;
}

menu {
  height: 100%;
  margin: 30px 0;
  display: flex;
  justify-content: center;
}

.MenuItem {
  border-radius: 8px;
  padding: 10px 20px;
  margin: 0 3px;
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
