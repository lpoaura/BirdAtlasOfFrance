<template>
  <v-container fluid>
    <header>
      <div class="MapSearchBar">
        <map-search-bar
          @selectedMunicipality="updateSelectedMunicipality"
          @selectedSpecies="updateSelectedSpecies"
        />
      </div>
      <div class="Selectors">
        <layers-selector
          :selected-layer="selectedLayer"
          @selectedLayer="updateSelectedLayer"
          @epocOdfOfficialIsOn="updateEpocOdfOfficial"
          @epocOdfReserveIsOn="updateEpocOdfReserve"
        />
        <territories-selector />
      </div>
    </header>
    <client-only>
      <lazy-prospecting-map
        :selected-municipality-bounds="selectedMunicipalityBounds"
        :selected-species="selectedSpecies"
        :selected-layer="selectedLayer"
        :epoc-odf-official-is-on="epocOdfOfficialIsOn"
        :epoc-odf-reserve-is-on="epocOdfReserveIsOn"
        :selected-territory-bounds="selectedTerritoryBounds"
      />
    </client-only>
  </v-container>
</template>

<script>
import MapSearchBar from '~/components/prospecting/MapSearchBar.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'
import LayersSelector from '~/components/prospecting/LayersSelector.vue'

export default {
  components: {
    'map-search-bar': MapSearchBar,
    'territories-selector': TerritoriesSelector,
    'layers-selector': LayersSelector,
    'lazy-prospecting-map': () => {
      if (process.client) {
        return import('~/components/prospecting/ProspectingMap.vue')
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
    selectedMunicipalityBounds: null,
    selectedSpecies: null,
    selectedLayer: 'Indice de complétude',
    epocOdfOfficialIsOn: true,
    epocOdfReserveIsOn: true,
    // territoriesData: [
    //   {
    //     name: 'Auvergne-Rhône-Alpes',
    //     bounds: {
    //       _southWest: {
    //         lat: 43.94537239244211,
    //         lng: 1.9227157458160173,
    //       },
    //       _northEast: {
    //         lat: 46.924007100770275,
    //         lng: 7.218125902066018,
    //       },
    //     },
    //   },
    //   {
    //     name: "Provence-Alpes-Côte-d'Azur",
    //     bounds: {
    //       _southWest: {
    //         lat: 42.265114458337585,
    //         lng: 3.3014714192032777,
    //       },
    //       _northEast: {
    //         lat: 45.32897866218559,
    //         lng: 8.596881575453278,
    //       },
    //     },
    //   },
    //   {
    //     name: 'Guadeloupe',
    //     bounds: {
    //       _southWest: {
    //         lat: 15.64816381409883,
    //         lng: -62.120774194373965,
    //       },
    //       _northEast: {
    //         lat: 16.66776866124075,
    //         lng: -60.796921655311465,
    //       },
    //     },
    //   },
    // ],
    selectedTerritoryBounds: null,
  }),
  methods: {
    updateSelectedMunicipality(data) {
      this.selectedMunicipalityBounds = data.bounds
    },
    updateSelectedSpecies(species) {
      this.selectedSpecies = species
    },
    updateSelectedLayer(layer) {
      this.selectedLayer = layer
    },
    updateEpocOdfOfficial(value) {
      this.epocOdfOfficialIsOn = value
    },
    updateEpocOdfReserve(value) {
      this.epocOdfReserveIsOn = value
    },
    updateSelectedTerritory(bounds) {
      this.selectedTerritoryBounds = bounds
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
  background: #fcfcfc;
  width: 100%;
  height: 68px;
  padding: 0 2% 0 10px;
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.05);
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.MapSearchBar {
  width: 420px;
  height: 44px;
}

.Selectors {
  display: flex;
  justify-content: flex-end;
}
</style>
