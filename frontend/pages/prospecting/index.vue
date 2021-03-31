<!-- Comment zoomer sur une commune au démarrage en ayant seulement son code ? -->
<template>
  <v-container fluid>
    <header>
      <map-search-bar @selectedMunicipality="updateSelectedMunicipality" />
      <div class="Selectors">
        <territories-selector />
      </div>
    </header>
    <client-only>
      <lazy-prospecting-map
        :selected-season="selectedSeason"
        :selected-municipality-bounds="selectedMunicipalityBounds"
        :selected-territory-bounds="selectedTerritoryBounds"
        @clickedFeature="updateClickedFeature"
      />
    </client-only>
  </v-container>
</template>

<script>
import MapSearchBar from '~/components/prospecting/MapSearchBar.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'

export default {
  components: {
    'map-search-bar': MapSearchBar,
    'territories-selector': TerritoriesSelector,
    'lazy-prospecting-map': () => {
      if (process.client) {
        return import('~/components/ProspectingMap.vue')
      }
    },
  },
  //   async fetch() {
  //     console.log('[async fetch]')
  //     this.territoriesData = await this.$axios.$get(
  //       `http://localhost:8888/api/v1/...`
  //     )
  //   },
  data: () => ({
    territoriesData: [
      {
        name: 'Auvergne-Rhône-Alpes',
        bounds: {
          _southWest: {
            lat: 43.94537239244211,
            lng: 1.9227157458160173,
          },
          _northEast: {
            lat: 46.924007100770275,
            lng: 7.218125902066018,
          },
        },
      },
      {
        name: "Provence-Alpes-Côte-d'Azur",
        bounds: {
          _southWest: {
            lat: 42.265114458337585,
            lng: 3.3014714192032777,
          },
          _northEast: {
            lat: 45.32897866218559,
            lng: 8.596881575453278,
          },
        },
      },
      {
        name: 'Guadeloupe',
        bounds: {
          _southWest: {
            lat: 15.64816381409883,
            lng: -62.120774194373965,
          },
          _northEast: {
            lat: 16.66776866124075,
            lng: -60.796921655311465,
          },
        },
      },
    ],
    selectedSeason: 'breeding',
    selectedMunicipalityBounds: null,
    selectedTerritoryBounds: null,
    clickedFeature: null,
  }),
  // mounted() {
  //   console.log(this.$route)
  // },
  methods: {
    updateSelectedSeason(season) {
      this.selectedSeason = season
    },
    updateSelectedMunicipality(data) {
      this.selectedMunicipalityBounds = data.bounds
      this.$router.push({
        path: '/prospecting',
        query: { place: `${data.code}` },
      })
    },
    updateSelectedTerritory(bounds) {
      this.selectedTerritoryBounds = bounds
    },
    updateClickedFeature(feature) {
      this.clickedFeature = feature
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
div.container.container--fluid {
  padding-top: 68px;
}

header {
  position: relative;
  background: #fcfcfc;
  width: 100%;
  height: 68px;
  padding: 12px 2%;
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.05);
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
  display: flex;
  justify-content: space-between;
}

.Selectors {
  display: flex;
  justify-content: flex-end;
}
</style>
