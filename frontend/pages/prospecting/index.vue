<template>
  <div>
    <v-container>
      <v-row>
        <v-col cols="3">
          <h1>Page de prospection</h1>
          <seasons @selectedSeason="updateSelectedSeason" />
          <area-search-bar @selectedCity="updateSelectedCity" />
          <h4>Se rendre en...</h4>
          <clickable-territory
            v-for="territory in territoriesData"
            :key="territory.name"
            :territory-data="territory"
            @selectedTerritory="updateSelectedTerritory"
          />
        </v-col>
        <v-col cols="9">
          <prospecting-map
            :selected-season="selectedSeason"
            :selected-city-bounds="selectedCityBounds"
            :selected-territory-bounds="selectedTerritoryBounds"
          />
        </v-col>
      </v-row>
    </v-container>
    <v-navigation-drawer
      v-model="drawer"
      :mini-variant="miniVariant"
      fixed
      app
      right
    >
      <v-container>
        <v-row align="center">
          <v-col cols="12">
            <div class="text-center">
              <h3>Tableau de bord de la maille consultée</h3>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </v-navigation-drawer>
  </div>
</template>

<script>
import ProspectingMap from '~/components/ProspectingMap.vue'
import AreaSearchBar from '~/components/AreaSearchBar.vue'
import ClickableTerritory from '~/components/ClickableTerritory.vue'
import Seasons from '~/components/Seasons.vue'

export default {
  components: {
    'prospecting-map': ProspectingMap,
    'area-search-bar': AreaSearchBar,
    'clickable-territory': ClickableTerritory,
    seasons: Seasons,
  },
  //   async fetch() {
  //     console.log('[async fetch]')
  //     this.territoriesData = await this.$axios.$get(
  //       `http://127.0.0.1:8888/api/v1/...`
  //     )
  //   },
  data: () => ({
    drawer: true,
    miniVariant: false,
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
  },
}
</script>
