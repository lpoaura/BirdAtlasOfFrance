<template>
  <v-container fluid>
    <home-nav-bar />
    <div class="reverse-image"></div>
    <div class="original-image"></div>
    <div class="search-section">
      <div class="search-content">
        <div class="search-text">Hello</div>
        <div class="search-bar">Hello</div>
      </div>
    </div>
    <div class="cards-section"></div>
    <v-row justify="center" align="center">
      <v-col cols="12" sm="8" md="6">
        <species-search-bar @selectedSpecies="updateSelectedSpecies" />
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import HomeNavBar from '~/components/HomeNavBar.vue'
import SpeciesSearchBar from '~/components/SpeciesSearchBar.vue'

export default {
  // async asyncData({ $content }) {
  //   const news1 = await $content('news/news-1').fetch()
  //   return { news1 }
  // },
  components: {
    'home-nav-bar': HomeNavBar,
    'species-search-bar': SpeciesSearchBar,
  },
  data: () => ({
    selectedSpecies: null,
  }),
  methods: {
    updateSelectedSpecies(species) {
      this.selectedSpecies = species
      this.$router.push({ path: `/species-card/${species}` })
    },
  },
  head: {
    title: 'Accueil',
  },
}
</script>

<style scoped>
.container--fluid {
  padding: 0;
}

.reverse-image {
  position: absolute;
  background-image: url('/home-picture-1.jpg');
  width: 540px;
  height: 735px;
}

.original-image {
  position: absolute;
  background-image: url('/home-picture-2.jpg');
  width: 901px;
  height: 735px;
  left: 540px;
}

.search-section {
  background: linear-gradient(
      180deg,
      rgba(8, 43, 8, 0.95) 0%,
      rgba(8, 43, 8, 0.75) 10.25%,
      rgba(8, 43, 8, 0.2) 20.95%,
      rgba(8, 43, 8, 0.2) 31.47%,
      rgba(8, 43, 8, 0.2) 100%
    ),
    linear-gradient(
      89.84deg,
      rgba(8, 43, 8, 0.7) 0.14%,
      rgba(8, 43, 8, 0.7) 37.28%,
      rgba(8, 43, 8, 0) 74.41%,
      rgba(8, 43, 8, 0.21) 99.86%
    );
  position: absolute;
  z-index: 5;
  width: 100%;
  height: 735px;
  display: flex;
}

.search-content {
  background-color: coral;
  width: 912px;
  height: 302px;
  margin: auto;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.search-text {
  background-color: teal;
  width: 100%;
  height: 182px;
}

.search-bar {
  background-color: yellow;
  width: 770px;
  height: 72px;
}

.cards-section {
  background-color: yellowgreen;
  width: 100%;
  height: 856px;
  left: 0;
  top: 0;
}
</style>
