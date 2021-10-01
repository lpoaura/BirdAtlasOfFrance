<template>
  <v-container fluid>
    <header>
      <div class="MapSearchBar">
        <map-search-bar
          @selectedArea="updateSelectedArea"
          @selectedSpecies="updateSelectedSpecies"
        />
      </div>
      <div class="MapSelectors large">
        <div v-click-outside="closeSeasonsBox" class="MapSelectorWrapper">
          <div class="MapSelectorSelectedOption" @click="openOrCloseSeasonsBox">
            <img class="MapSelectorIcon" src="/calendar.svg" />
            <h5 class="fw-600 right-margin-12">{{ selectedSeason.label }}</h5>
            <img
              class="MapSelectorChevron"
              :src="seasonIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
            />
          </div>
          <seasons-selector
            :select-is-open="seasonIsOpen"
            :selected-season="selectedSeason"
            @selectedSeason="updateSelectedSeason"
          />
        </div>
        <div v-click-outside="closeLayersBox" class="MapSelectorWrapper">
          <div class="MapSelectorSelectedOption" @click="openOrCloseLayersBox">
            <img class="MapSelectorIcon" src="/layers.svg" />
            <h5 class="fw-600 right-margin-12">Couches</h5>
            <img
              class="MapSelectorChevron"
              :src="layerIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
            />
          </div>
          <layers-selector
            :select-is-open="layerIsOpen"
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
        </div>
        <div v-click-outside="closeTerritoriesBox" class="MapSelectorWrapper">
          <div
            class="MapSelectorSelectedOption"
            @click="openOrCloseTerritoriesBox"
          >
            <img class="MapSelectorIcon" src="/location.svg" />
            <h5 class="fw-600 right-margin-12">{{ selectedTerritory.name }}</h5>
            <img
              class="MapSelectorChevron"
              :src="territoryIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
            />
          </div>
          <territories-selector
            :select-is-open="territoryIsOpen"
            :selected-territory="selectedTerritory"
          />
        </div>
      </div>
    </header>
    <client-only>
      <lazy-prospecting-map
        :selected-area="selectedArea"
        :selected-species="selectedSpecies"
        :selected-season="selectedSeason"
        :selected-layer="selectedLayer"
        :selected-territory="selectedTerritory"
        :epoc-odf-official-is-on="epocOdfOfficialIsOn"
        :epoc-odf-reserve-is-on="epocOdfReserveIsOn"
        :plan="plan"
        :orthophoto="orthophoto"
        @selectedSpecies="updateSelectedSpecies"
        @selectedSeason="updateSelectedSeason"
        @selectedLayer="updateSelectedLayer"
        @epocOdfOfficialIsOn="updateEpocOdfOfficial"
        @epocOdfReserveIsOn="updateEpocOdfReserve"
        @planIsOn="updatePlan"
        @planOpacity="updatePlanOpacity"
        @orthophotoIsOn="updateOrthophoto"
        @orthophotoOpacity="updateOrthophotoOpacity"
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
    plan: {
      isOn: false,
      url:
        'https://wxs.ign.fr/pratique/geoportail/wmts?' +
        '&REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&TILEMATRIXSET=PM' +
        '&LAYER=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&STYLE=normal&FORMAT=image/png' +
        '&TILECOL={x}&TILEROW={y}&TILEMATRIX={z}',
      opacity: '50',
      zIndex: 2,
      attribution: 'IGN Plan V2',
    },
    orthophoto: {
      isOn: false,
      url:
        'https://wxs.ign.fr/pratique/geoportail/wmts?' +
        '&REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&TILEMATRIXSET=PM' +
        '&LAYER=ORTHOIMAGERY.ORTHOPHOTOS&STYLE=normal&FORMAT=image/jpeg' +
        '&TILECOL={x}&TILEROW={y}&TILEMATRIX={z}',
      opacity: '50',
      zIndex: 1,
      attribution: 'IGN Orthophotographies',
    },
    clc: {
      isOn: false,
      url: 'http://wxs.ign.fr/corinelandcover/geoportail/r/wms',
      layers: 'LANDCOVER.CLC18',
      opacity: '50',
      zIndex: 3,
      attribution: 'Corine Land Cover 2018',
      name: 'Corine Land Cover 2018',
      visible: true,
      transparent: true,
    },
    selectedTerritory: {
      name: 'France métropolitaine',
    },
    seasonIsOpen: false,
    layerIsOpen: false,
    territoryIsOpen: false,
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
      this.seasonIsOpen = false
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
      this.plan.isOn = value
    },
    updatePlanOpacity(value) {
      this.plan.opacity = value
    },
    updateOrthophoto(value) {
      this.orthophoto.isOn = value
    },
    updateOrthophotoOpacity(value) {
      this.orthophoto.opacity = value
    },
    openOrCloseSeasonsBox() {
      this.seasonIsOpen = !this.seasonIsOpen
    },
    closeSeasonsBox() {
      this.seasonIsOpen = false
    },
    openOrCloseLayersBox() {
      this.layerIsOpen = !this.layerIsOpen
    },
    closeLayersBox() {
      this.layerIsOpen = false
    },
    openOrCloseTerritoriesBox() {
      this.territoryIsOpen = !this.territoryIsOpen
    },
    closeTerritoriesBox() {
      this.territoryIsOpen = false
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
  padding: 0 24px 0 10px;
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

@media screen and (max-width: 950px) {
  header {
    padding: 0 10px;
  }

  .MapSearchBar {
    width: 100%;
  }
}
</style>
