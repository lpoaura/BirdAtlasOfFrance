<template>
  <v-container fluid>
    <div v-if="mobileMapControlIsOpen" class="MobileMapControl">
      <knowledge-level-control
        v-show="selectedLayer === 'Indice de complétude' && !clickedFeature"
        :current-territory="currentTerritory"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <feature-dashboard-control
        v-if="
          ['Indice de complétude', 'Points EPOC'].includes(selectedLayer) &&
          clickedFeature &&
          !clickedEpocPoint
        "
        :clicked-feature="clickedFeature"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <species-dashboard-control
        v-if="selectedLayer === 'Répartition de l\'espèce' && selectedSpecies"
        :selected-species="selectedSpecies"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <section
        v-if="selectedLayer === 'Points EPOC' && clickedEpocPoint"
        class="MapControl"
      >
        <div
          v-if="clickedFeature"
          class="MapControlComeBack"
          @click="updateClickedEpocPoint(null)"
        >
          <img class="MapControlComeBackIcon" src="/previous.svg" />
          <span class="fw-500">{{ clickedFeature.properties.area_name }}</span>
        </div>
        <epoc-dashboard-control
          :clicked-epoc-point="clickedEpocPoint"
          @mobileMapControl="openOrCloseMobileMapControl"
        />
      </section>
    </div>
    <header>
      <div class="MapSearchBar">
        <map-search-bar
          :selected-species="selectedSpecies"
          @selectedArea="updateSelectedArea"
          @selectedSpecies="updateSelectedSpecies"
        />
      </div>
      <div class="MapSelectors">
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
            <h5 class="fw-600 right-margin-12">Territoires</h5>
            <img
              class="MapSelectorChevron"
              :src="territoryIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
            />
          </div>
          <territories-selector
            :select-is-open="territoryIsOpen"
            :selected-territory="selectedTerritory"
            @selectedTerritory="updateSelectedTerritory"
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
        :current-territory="currentTerritory"
        :clicked-feature="clickedFeature"
        :clicked-epoc-point="clickedEpocPoint"
        :epoc-odf-official-is-on="epocOdfOfficialIsOn"
        :epoc-odf-reserve-is-on="epocOdfReserveIsOn"
        :plan="plan"
        :orthophoto="orthophoto"
        :mobile-map-control-is-open="mobileMapControlIsOpen"
        @selectedSpecies="updateSelectedSpecies"
        @selectedSeason="updateSelectedSeason"
        @selectedLayer="updateSelectedLayer"
        @selectedTerritory="updateSelectedTerritory"
        @currentTerritory="updateCurrentTerritory"
        @clickedFeature="updateClickedFeature"
        @clickedEpocPoint="updateClickedEpocPoint"
        @epocOdfOfficialIsOn="updateEpocOdfOfficial"
        @epocOdfReserveIsOn="updateEpocOdfReserve"
        @planIsOn="updatePlan"
        @planOpacity="updatePlanOpacity"
        @orthophotoIsOn="updateOrthophoto"
        @orthophotoOpacity="updateOrthophotoOpacity"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
    </client-only>
  </v-container>
</template>

<script>
import MapSearchBar from '~/components/prospecting/MapSearchBar.vue'
import SeasonsSelector from '~/components/prospecting/SeasonsSelector.vue'
import LayersSelector from '~/components/prospecting/LayersSelector.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'
import KnowledgeLevelControl from '~/components/prospecting/KnowledgeLevelControl.vue'
import FeatureDashboardControl from '~/components/prospecting/FeatureDashboardControl.vue'
import SpeciesDashboardControl from '~/components/prospecting/SpeciesDashboardControl.vue'

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
    'knowledge-level-control': KnowledgeLevelControl,
    'feature-dashboard-control': FeatureDashboardControl,
    'species-dashboard-control': SpeciesDashboardControl,
  },
  data: () => ({
    selectedArea: null, // Zonage sélectionné dans la barre de recherche
    selectedSpecies: null, // Espèce sélectionnée dans la barre de recherche
    selectedSeason: {
      // Saison sélectionnée
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
    selectedLayer: 'Indice de complétude', // Couche sélectionnée
    selectedTerritory: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      name: null,
      icon: null,
      isActive: null,
    },
    currentTerritory: {
      // Territoire sur lequel est centrée la carte (peut être non défini)
      id: null,
      name: null,
    },
    clickedFeature: null, // On clique sur une maille
    clickedEpocPoint: null, // On clique sur un point EPOC
    // epocPointsIsOn: true, À PASSER DANS ProspectingMap
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
    // clc: { À PASSER DANS ProspectingMap
    //   isOn: false,
    //   url: 'http://wxs.ign.fr/corinelandcover/geoportail/r/wms',
    //   layers: 'LANDCOVER.CLC18',
    //   opacity: '50',
    //   zIndex: 3,
    //   attribution: 'Corine Land Cover 2018',
    //   name: 'Corine Land Cover 2018',
    //   visible: true,
    //   transparent: true,
    // },
    seasonIsOpen: false,
    layerIsOpen: false,
    territoryIsOpen: false,
    // MOBILE
    mobileMapControlIsOpen: false,
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  mounted() {
    document.documentElement.style.overflow = 'hidden'
    document.body.style.position = 'fixed' // Needed for iOS
  },
  beforeDestroy() {
    document.documentElement.style.removeProperty('overflow')
    document.body.style.removeProperty('position')
  },
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
    updateSelectedTerritory(territory) {
      this.selectedTerritory = territory
      this.territoryIsOpen = false
    },
    updateCurrentTerritory(territory) {
      this.currentTerritory = territory
      if (
        this.selectedTerritory.name &&
        this.currentTerritory.name !== this.selectedTerritory.name
      ) {
        this.selectedTerritory = {
          name: null,
          icon: null,
          isActive: null,
        }
      }
    },
    updateClickedFeature(feature) {
      this.clickedFeature = feature
    },
    updateClickedEpocPoint(epoc) {
      this.clickedEpocPoint = epoc
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
    // MOBILE
    openOrCloseMobileMapControl(value) {
      this.mobileMapControlIsOpen = value
    },
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

/********** RESPONSIVE **********/

@media screen and (max-width: 950px) {
  header {
    padding: 0 10px;
  }

  .MapSearchBar {
    width: 100%;
  }
}
</style>
