<template>
  <v-container fluid>
    <header>
      <div class="MapSearchBar">
        <map-search-bar
          @selectedArea="updateSelectedArea"
          @selectedSpecies="updateSelectedSpecies"
        />
      </div>
      <div class="Selectors">
        <seasons-selector
          :selected-season="selectedSeason"
          @selectedSeason="updateSelectedSeason"
        />
        <layers-selector
          :selected-layer="selectedLayer"
          :selected-species="selectedSpecies"
          @selectedLayer="updateSelectedLayer"
          @epocOdfOfficialIsOn="updateEpocOdfOfficial"
          @epocOdfReserveIsOn="updateEpocOdfReserve"
          @planIsOn="updatePlan"
          @planOpacity="updatePlanOpacity"
          @orthophotoIsOn="updateOrthophoto"
          @orthophotoOpacity="updateOrthophotoOpacity"
        />
        <territories-selector />
      </div>
    </header>
    <client-only>
      <lazy-prospecting-map
        :selected-area="selectedArea"
        :selected-species="selectedSpecies"
        :selected-season="selectedSeason"
        :selected-layer="selectedLayer"
        :epoc-odf-official-is-on="epocOdfOfficialIsOn"
        :epoc-odf-reserve-is-on="epocOdfReserveIsOn"
        :plan-is-on="planIsOn"
        :plan-opacity="planOpacity"
        :orthophoto-is-on="orthophotoIsOn"
        :orthophoto-opacity="orthophotoOpacity"
        :selected-territory-bounds="selectedTerritoryBounds"
        @selectedSpecies="updateSelectedSpecies"
      />
    </client-only>
  </v-container>
</template>

<script>
import MapSearchBar from '~/components/prospecting/MapSearchBar.vue'
import SeasonsSelector from '~/components/prospecting/SeasonsSelector.vue'
import LayersSelector from '~/components/prospecting/LayersSelector.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'

export default {
  components: {
    'map-search-bar': MapSearchBar,
    'seasons-selector': SeasonsSelector,
    'layers-selector': LayersSelector,
    'territories-selector': TerritoriesSelector,
    'lazy-prospecting-map': () => {
      if (process.client) {
        return import('~/components/prospecting/ProspectingMap.vue')
      }
    },
  },
  data: () => ({
    selectedArea: null,
    selectedSpecies: null,
    selectedSeason: {
      label: 'Toutes saisons',
      value: 'all_period',
      featuresColors: [
        'rgba(51, 105, 80, 0.2)',
        'rgba(51, 105, 80, 0.4)',
        'rgba(51, 105, 80, 0.6)',
        'rgba(51, 105, 80, 0.8)',
        '#336950',
      ],
      speciesDistributionColors: ['#336950'],
    },
    selectedLayer: 'Indice de complétude',
    epocPointsIsOn: true,
    epocOdfOfficialIsOn: true,
    epocOdfReserveIsOn: true,
    planIsOn: false,
    planOpacity: '50',
    orthophotoIsOn: false,
    orthophotoOpacity: '50',
    selectedTerritoryBounds: null,
  }),
  methods: {
    updateSelectedArea(data) {
      this.selectedArea = data
    },
    updateSelectedSpecies(species) {
      this.selectedSpecies = species
      if (!species && this.selectedLayer === "Répartition de l'espèce") {
        this.selectedLayer = 'Indice de complétude'
      }
    },
    updateSelectedSeason(season) {
      this.selectedSeason = season
    },
    updateSelectedLayer(layer) {
      this.selectedLayer = layer
    },
    updateEpocPoints(value) {
      this.epocPointsIsOn = value
    },
    updateEpocOdfOfficial(value) {
      this.epocOdfOfficialIsOn = value
    },
    updateEpocOdfReserve(value) {
      this.epocOdfReserveIsOn = value
    },
    updatePlan(value) {
      this.planIsOn = value
    },
    updatePlanOpacity(value) {
      this.planOpacity = value
    },
    updateOrthophoto(value) {
      this.orthophotoIsOn = value
    },
    updateOrthophotoOpacity(value) {
      this.orthophotoOpacity = value
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
