<template>
  <v-container fluid>
    <header>
      <map-search-bar />
      <div class="Selectors">
        <territories-selector />
      </div>
    </header>
    <v-row>
      <v-col cols="3">
        <h1>Page de prospection</h1>
        <seasons-select @selectedSeason="updateSelectedSeason" />
        <area-search-bar @selectedCity="updateSelectedCity" />
        <h4>Se rendre en...</h4>
        <v-list dense>
          <clickable-territory
            v-for="territory in territoriesData"
            :key="territory.name"
            :territory-data="territory"
            @selectedTerritory="updateSelectedTerritory"
          />
        </v-list>
      </v-col>
      <v-col cols="9">
        <client-only>
          <lazy-prospecting-map
            :selected-season="selectedSeason"
            :selected-city-bounds="selectedCityBounds"
            :selected-territory-bounds="selectedTerritoryBounds"
            @clickedFeature="updateClickedFeature"
          />
        </client-only>
      </v-col>
    </v-row>
    <feature-dashboard
      :clicked-feature="clickedFeature"
      :drawer="drawer"
      :selected-season="selectedSeason"
    />
  </v-container>
</template>

<script>
import MapSearchBar from '~/components/prospecting/MapSearchBar.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'

import AreaSearchBar from '~/components/AreaSearchBar.vue'
import ClickableTerritory from '~/components/ClickableTerritory.vue'
import SeasonsSelect from '~/components/SeasonsSelect.vue'
import FeatureDashboard from '~/components/FeatureDashboard.vue'

export default {
  components: {
    'map-search-bar': MapSearchBar,
    'territories-selector': TerritoriesSelector,
    'lazy-prospecting-map': () => {
      if (process.client) {
        return import('~/components/ProspectingMap.vue')
      }
    },
    'area-search-bar': AreaSearchBar,
    'clickable-territory': ClickableTerritory,
    'seasons-select': SeasonsSelect,
    'feature-dashboard': FeatureDashboard,
  },
  //   async fetch() {
  //     console.log('[async fetch]')
  //     this.territoriesData = await this.$axios.$get(
  //       `http://localhost:8888/api/v1/...`
  //     )
  //   },
  data: () => ({
    drawer: false,
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
    selectedCityBounds: null,
    selectedTerritoryBounds: null,
    clickedFeature: null,
  }),
  methods: {
    updateSelectedSeason(season) {
      this.selectedSeason = season
    },
    updateSelectedCity(bounds) {
      this.selectedCityBounds = bounds
    },
    updateSelectedTerritory(bounds) {
      this.selectedTerritoryBounds = bounds
    },
    updateClickedFeature(feature) {
      this.drawer = true
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
