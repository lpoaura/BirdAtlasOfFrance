<template>
  <v-container fluid>
    <div v-if="mobileMapControlIsOpen" class="MobileMapControl">
      <knowledge-level-control
        v-show="selectedLayer.value === 'knowledge-level' && !clickedFeature"
        :current-territory="currentTerritory"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <count-taxa-control
        v-show="selectedLayer.value === 'species-number' && !clickedFeature"
        :current-territory="currentTerritory"
        :count-taxa-classes="countTaxaClasses"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <feature-dashboard-control
        v-if="
          ['knowledge-level', 'species-number', 'epoc'].includes(
            selectedLayer.value
          ) &&
          clickedFeature &&
          !clickedEpocPoint
        "
        :clicked-feature="clickedFeature"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <species-dashboard-control
        v-if="selectedLayer.value === 'species-distribution' && selectedSpecies"
        :selected-species="selectedSpecies"
        :selected-season="selectedSeason"
        @mobileMapControl="openOrCloseMobileMapControl"
      />
      <section
        v-if="selectedLayer.value === 'epoc' && clickedEpocPoint"
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
            @epocRealizedIsOn="updateEpocRealized"
            @epocOdfIsOn="updateEpocOdf"
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
            <h5
              v-if="currentTerritory.area_code"
              class="fw-600 right-margin-12"
            >
              {{ currentTerritory.area_name }}
            </h5>
            <h5 v-else class="fw-600 right-margin-12">Territoires</h5>
            <img
              class="MapSelectorChevron"
              :src="territoryIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
            />
          </div>
          <commons-selectors-territories :select-is-open="territoryIsOpen" />
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
        :count-taxa-classes="countTaxaClasses"
        :clicked-feature="clickedFeature"
        :clicked-epoc-point="clickedEpocPoint"
        :epoc-realized-is-on="epocRealizedIsOn"
        :epoc-odf-is-on="epocOdfIsOn"
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
        @epocRealizedIsOn="updateEpocRealized"
        @epocOdfIsOn="updateEpocOdf"
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
import SeasonsSelector from '~/components/commons/Selectors/Seasons.vue'
import LayersSelector from '~/components/commons/Selectors/Layers.vue'
import KnowledgeLevelControl from '~/components/prospecting/KnowledgeLevelControl.vue'
import CountTaxaControl from '~/components/prospecting/CountTaxaControl.vue'
import FeatureDashboardControl from '~/components/prospecting/FeatureDashboardControl.vue'
import SpeciesDashboardControl from '~/components/prospecting/SpeciesDashboardControl.vue'
import EpocDashboardControl from '~/components/prospecting/EpocDashboardControl.vue'

export default {
  components: {
    'map-search-bar': MapSearchBar,
    'seasons-selector': SeasonsSelector,
    'layers-selector': LayersSelector,
    'lazy-prospecting-map': () => {
      if (process.client) {
        return import('~/components/prospecting/ProspectingMap.vue')
      }
    },
    'knowledge-level-control': KnowledgeLevelControl,
    'count-taxa-control': CountTaxaControl,
    'feature-dashboard-control': FeatureDashboardControl,
    'species-dashboard-control': SpeciesDashboardControl,
    'epoc-dashboard-control': EpocDashboardControl,
  },
  data: () => ({
    selectedArea: null, // Zonage sélectionné dans la barre de recherche
    selectedSpecies: null, // Espèce sélectionnée dans la barre de recherche
    selectedSeason: {
      // Saison sélectionnée
      value: 'all_period',
      label: 'Toutes saisons',
      featuresColors: [
        '#bcbcbc',
        'rgba(51, 105, 80, 0.2)',
        'rgba(51, 105, 80, 0.4)',
        'rgba(51, 105, 80, 0.6)',
        'rgba(51, 105, 80, 0.8)',
        '#336950',
      ],
      speciesDistributionColors: ['#336950'],
    },
    selectedLayer: {
      // Couche sélectionnée
      value: 'knowledge-level',
      label: 'Indice de complétude',
      subtitle: null,
      permanent: true,
    },
    // selectedTerritory: {
    //   // Territoire cliqué (FrMet ou DOM-TOM)
    // },
    currentTerritory: {
      // Territoire sur lequel est centrée la carte (peut être non défini)
    },
    countTaxaClasses: {
      // Classes pour la couche "Nb d'espèces par maille"
      all_period: [],
      breeding: [],
      wintering: [],
    },
    clickedFeature: null, // On clique sur une maille
    clickedEpocPoint: null, // On clique sur un point EPOC
    epocRealizedIsOn: true,
    epocOdfIsOn: true,
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
  computed: {
    selectedTerritory() {
      return this.$store.state.species.selectedTerritory
    },
    territoriesList() {
      return [...this.$store.state.species.territoriesList]
    },
  },
  watch: {
    selectedSpecies() {
      this.getTerritoryList()
    },
    cdNom() {
      this.getTerritoryList()
    },
  },
  mounted() {
    document.documentElement.style.overflow = 'hidden'
    document.body.style.position = 'fixed' // Needed for iOS
    this.getTerritoryList()
  },
  beforeDestroy() {
    document.documentElement.style.removeProperty('overflow')
    document.body.style.removeProperty('position')
  },
  methods: {
    async getTerritoryList() {
      console.log('getTerritoryList', this.cdNom)
      if (this.selectedSpecies?.code) {
        console.log('getTerritoryList', this.selectedSpecies?.code)
        const params = { cd_nom: this.selectedSpecies.code }
        const territoryList = await this.$axios.$get(
          '/api/v1/taxa/list/distribution',
          { params }
        )
        this.$store.commit(
          'species/setTerritoryDistribution',
          territoryList.areas
        )
        this.initSelectedTerritory(territoryList.areas)
        // this.initSelectedTerritory(territoryList.areas)
      } else {
        this.$store.commit('species/setTerritoryDistribution', [])
      }
    },
    initSelectedTerritory(territoryList) {
      const firstTerritory = this.territoriesList.find(
        (territory) =>
          territory.isActive && territoryList.includes(territory.area_code)
      )
      console.log('FIRST TERRITORY', firstTerritory)
      this.$store.commit('species/setSelectedTerritory', firstTerritory)
    },
    updateSelectedArea(data) {
      this.selectedArea = data
    },
    updateSelectedSpecies(species) {
      this.selectedSpecies = species
      if (!species && this.selectedLayer.value === 'species-distribution') {
        this.selectedLayer = {
          value: 'knowledge-level',
          label: 'Indice de complétude',
          subtitle: null,
          permanent: true,
        }
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
      // Permet d'activer le watch de ProspectingMap et ainsi de recentrer la carte sur un territoire même si l'utilisateur se trouve déjà dessus
      this.selectedTerritory = {}
      console.log('TERRITORY', territory)
      setTimeout(() => {
        this.selectedTerritory = territory
      }, 1)
      this.territoryIsOpen = false
    },
    updateCurrentTerritory(territory) {
      this.currentTerritory = territory
      const periods = ['all_period', 'breeding', 'wintering']
      if (territory.area_code) {
        Promise.all(
          periods.map((i) => {
            const params = {
              id_area: territory.id,
              period: i,
            }
            return this.$axios.$get(`/api/v1/map/count_taxon_classes`, {
              params,
            })
          })
        )
          .then((responses) => {
            if (responses[0]) {
              responses.forEach((item, index) => {
                this.countTaxaClasses[periods[index]] = item
                this.countTaxaClasses[periods[index]].forEach(
                  (taxaClass, i) => {
                    if (
                      i !==
                      this.countTaxaClasses[periods[index]].length - 1
                    ) {
                      taxaClass.max -= 1
                    }
                  }
                )
              })
            } else {
              const emptyObj = {}
              periods.forEach((i) => (emptyObj[i] = []))
              this.countTaxaClasses = emptyObj
            }
          })
          .catch((errors) => {
            console.debug(errors)
          })
      }
      if (
        this.selectedTerritory.area_code &&
        this.currentTerritory.area_code !== this.selectedTerritory.area_code
      ) {
        this.selectedTerritory = {}
      }
    },
    updateClickedFeature(feature) {
      this.clickedFeature = feature
    },
    updateClickedEpocPoint(epoc) {
      this.clickedEpocPoint = epoc
    },
    updateEpocRealized(value) {
      this.epocRealizedIsOn = value
    },
    updateEpocOdf(value) {
      this.epocOdfIsOn = value
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

@media screen and (width <= 950px) {
  header {
    padding: 0 10px;
  }

  .MapSearchBar {
    width: 100%;
  }
}
</style>
