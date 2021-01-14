<template>
  <div>
    <h1>Page de prospection</h1>
    <v-row justify="center" align="center">
      <v-col cols="2">
        <seasons />
        <h3>Se rendre en...</h3>
        <clickable-territory
          v-for="territory in territoriesData"
          :key="territory.name"
          :territory-data="territory"
          @selectedTerritory="updateSelectedTerritory"
        />
      </v-col>
      <v-col cols="10">
        <prospecting-map :selected-territory-bounds="selectedTerritoryBounds" />
      </v-col>
    </v-row>
  </div>
</template>

<script>
import ProspectingMap from '~/components/ProspectingMap.vue'
import ClickableTerritory from '~/components/ClickableTerritory.vue'
import Seasons from '~/components/Seasons.vue'

export default {
  components: {
    'prospecting-map': ProspectingMap,
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
    selectedTerritoryBounds: null,
  }),
  methods: {
    updateSelectedTerritory(bounds) {
      this.selectedTerritoryBounds = bounds
    },
  },
}
</script>
