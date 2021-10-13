<template>
  <div id="map-wrap">
    <!-- MAP -->
    <l-map
      ref="myMap"
      :zoom="zoom"
      :center="center"
      :options="{ zoomControl: false }"
      style="z-index: 0"
      @ready="initiateEnvelope"
      @update:bounds="updateEnvelope"
      @update:zoom="updateZoom"
    >
      <!-- LAYERS -->
      <!-- v-if="['Aucune', 'Points EPOC'].includes(selectedLayer) && plan.isOn" -->
      <l-tile-layer
        v-if="plan.isOn"
        :url="plan.url"
        :opacity="Number(plan.opacity) / 100"
        :z-index="plan.zIndex"
        :attribution="plan.attribution"
      />
      <!-- v-if="['Aucune', 'Points EPOC'].includes(selectedLayer) && orthophoto.isOn" -->
      <l-tile-layer
        v-if="orthophoto.isOn"
        :url="orthophoto.url"
        :opacity="Number(orthophoto.opacity) / 100"
        :z-index="orthophoto.zIndex"
        :attribution="orthophoto.attribution"
      />
      <!-- <l-wms-tile-layer
        :key="clcWms.name"
        :base-url="clcWms.url"
        :layers="clcWms.layers"
        :name="clcWms.name"
        :z-index="3"
        :attribution="clcWms.attribution"
        format="image/png"
        layer-type="base"
      >
      </l-wms-tile-layer> -->
      <!-- v-if="!['Aucune', 'Points EPOC'].includes(selectedLayer) || (['Aucune', 'Points EPOC'].includes(selectedLayer) && !plan.isOn && !orthophoto.isOn)" -->
      <l-tile-layer
        v-if="!plan.isOn && !orthophoto.isOn"
        :url="osmUrl"
        :attribution="'© les contributeurs d’OpenStreetMap'"
      />
      <!-- GEOJSON -->
      <l-geo-json
        v-if="
          selectedSpecies &&
          selectedLayer === 'Répartition de l\'espèce' &&
          speciesDistributionGeojson
        "
        :geojson="speciesDistributionGeojson"
        :options="speciesDistributionGeojsonOptions"
        :options-style="speciesDistributionGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Indice de complétude' ||
          (selectedLayer === 'Points EPOC' && currentZoom >= 11)
        "
        :geojson="knowledgeLevelGeojson"
        :options="knowledgeLevelGeojsonOptions"
        :options-style="knowledgeLevelGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Points EPOC' &&
          epocOdfOfficialIsOn &&
          currentZoom >= 11
        "
        :geojson="epocOdfOfficialGeojson"
        :options="epocOdfOfficialGeojsonOptions"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Points EPOC' &&
          epocOdfReserveIsOn &&
          currentZoom >= 11
        "
        :geojson="epocOdfReserveGeojson"
        :options="epocOdfReserveGeojsonOptions"
      />
      <!-- MAP CONTROLS -->
      <!-- Top left -->
      <l-control
        position="topleft"
        :disable-scroll-propagation="disableScrollPropagation"
      >
        <knowledge-level-control
          v-show="selectedLayer === 'Indice de complétude' && !clickedFeature"
          :selected-season="selectedSeason"
        />
        <feature-dashboard-control
          v-if="
            ['Indice de complétude', 'Points EPOC'].includes(selectedLayer) &&
            clickedFeature &&
            !clickedEpocPoint
          "
          :clicked-feature="clickedFeature"
          :selected-season="selectedSeason"
        />
        <species-dashboard-control
          v-if="selectedLayer === 'Répartition de l\'espèce' && selectedSpecies"
          :selected-species="selectedSpecies"
          :selected-season="selectedSeason"
          @selectedSpecies="deleteSelectedSpecies"
        />
        <section
          v-if="selectedLayer === 'Points EPOC' && clickedEpocPoint"
          class="MapControl"
        >
          <div
            v-if="clickedFeature"
            class="MapControlComeBack"
            @click="deleteClickedEpocPoint"
          >
            <img class="MapControlComeBackIcon" src="/previous.svg" />
            <span class="fw-500">{{
              clickedFeature.properties.area_name
            }}</span>
          </div>
          <epoc-dashboard-control :clicked-epoc-point="clickedEpocPoint" />
        </section>
        <!-- Apparaît si au moins une des conditions précédentes est remplie -->
        <div
          v-show="
            (selectedLayer === 'Indice de complétude' && !clickedFeature) ||
            (['Indice de complétude', 'Points EPOC'].includes(selectedLayer) &&
              clickedFeature &&
              !clickedEpocPoint) ||
            (selectedLayer === 'Répartition de l\'espèce' && selectedSpecies) ||
            (selectedLayer === 'Points EPOC' && clickedEpocPoint)
          "
          class="MiniMapControl mobile"
          @click="openMobileMapControl"
        >
          <img class="Icon" src="/information.svg" />
        </div>
      </l-control>
      <!-- Top right -->
      <l-control
        position="topright"
        :disable-scroll-propagation="disableScrollPropagation"
      >
        <div
          v-show="
            (knowledgeLevelIsLoading &&
              selectedLayer === 'Indice de complétude') ||
            (speciesDistributionIsLoading &&
              selectedLayer === 'Répartition de l\'espèce')
          "
          class="InformationControl"
        >
          <v-progress-circular
            :size="20"
            :width="3"
            :indeterminate="indeterminate"
            class="right-margin-8"
          />
          <h5 class="black02 fw-500">Chargement des données</h5>
        </div>
        <div
          v-show="selectedLayer === 'Points EPOC' && currentZoom < 11"
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Trop de points à afficher, zoomez à l’échelle d’une maille pour
            visualiser les points EPOC.
          </h5>
        </div>
        <div
          v-show="
            !speciesDistributionIsLoading &&
            noSpeciesData &&
            selectedLayer === 'Répartition de l\'espèce'
          "
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Pas de données pour la saison et l'emprise choisies.
          </h5>
        </div>
        <div class="MapSelectors">
          <div v-click-outside="closeSeasonsBox" class="MapSelectorWrapper">
            <div
              class="MiniMapControl"
              :class="seasonIsOpen ? 'selected' : ''"
              @click="openOrCloseSeasonsBox"
            >
              <img class="Icon" src="/calendar.svg" />
            </div>
            <seasons-selector
              :select-is-open="seasonIsOpen"
              :selected-season="selectedSeason"
              @selectedSeason="updateSelectedSeason"
            />
          </div>
          <div v-click-outside="closeLayersBox" class="MapSelectorWrapper">
            <div
              class="MiniMapControl"
              :class="layerIsOpen ? 'selected' : ''"
              @click="openOrCloseLayersBox"
            >
              <img class="Icon" src="/layers.svg" />
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
              class="MiniMapControl"
              :class="territoryIsOpen ? 'selected' : ''"
              @click="openOrCloseTerritoriesBox"
            >
              <img class="Icon" src="/location.svg" />
            </div>
            <territories-selector
              :select-is-open="territoryIsOpen"
              :selected-territory="selectedTerritory"
            />
          </div>
        </div>
      </l-control>
      <!-- Bottom left -->
      <l-control position="bottomleft">
        <div
          v-show="
            (knowledgeLevelIsLoading &&
              selectedLayer === 'Indice de complétude') ||
            (speciesDistributionIsLoading &&
              selectedLayer === 'Répartition de l\'espèce')
          "
          class="InformationControl"
        >
          <v-progress-circular
            :size="20"
            :width="3"
            :indeterminate="indeterminate"
            class="right-margin-8"
          />
          <h5 class="black02 fw-500">Chargement des données</h5>
        </div>
        <div
          v-show="selectedLayer === 'Points EPOC' && currentZoom < 11"
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Trop de points à afficher, zoomez à l’échelle d’une maille pour
            visualiser les points EPOC.
          </h5>
        </div>
        <div
          v-show="
            !speciesDistributionIsLoading &&
            noSpeciesData &&
            selectedLayer === 'Répartition de l\'espèce'
          "
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Pas de données pour la saison et l'emprise choisies.
          </h5>
        </div>
      </l-control>
      <!-- Bottom right -->
      <l-control-zoom position="bottomright"></l-control-zoom>
      <l-control position="bottomright">
        <div class="MiniMapControl" @click="geolocate">
          <img class="Icon" src="/geolocation.svg" />
        </div>
      </l-control>
    </l-map>
  </div>
</template>

<script>
import L from 'leaflet'
import {
  LMap,
  LGeoJson,
  LControl,
  LTileLayer,
  // LWMSTileLayer,
} from 'vue2-leaflet'
// import 'leaflet/dist/leaflet.css'
import KnowledgeLevelControl from '~/components/prospecting/KnowledgeLevelControl.vue'
import FeatureDashboardControl from '~/components/prospecting/FeatureDashboardControl.vue'
import SpeciesDashboardControl from '~/components/prospecting/SpeciesDashboardControl.vue'
import EpocDashboardControl from '~/components/prospecting/EpocDashboardControl.vue'
import SeasonsSelector from '~/components/prospecting/SeasonsSelector.vue'
import LayersSelector from '~/components/prospecting/LayersSelector.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'

export default {
  components: {
    LMap,
    LGeoJson,
    LControl,
    'l-tile-layer': LTileLayer,
    // 'l-wms-tile-layer': LWMSTileLayer,
    'knowledge-level-control': KnowledgeLevelControl,
    'feature-dashboard-control': FeatureDashboardControl,
    'epoc-dashboard-control': EpocDashboardControl,
    'species-dashboard-control': SpeciesDashboardControl,
    'seasons-selector': SeasonsSelector,
    'layers-selector': LayersSelector,
    'territories-selector': TerritoriesSelector,
  },
  props: {
    selectedArea: {
      // Zonage sélectionné dans la barre de recherche
      type: Object,
      required: false,
      default: null,
    },
    selectedSpecies: {
      // Espèce sélectionnée dans la barre de recherche
      type: Object,
      required: false,
      default: null,
    },
    selectedSeason: {
      // Saison sélectionnée
      type: Object,
      required: true,
    },
    selectedLayer: {
      // Couche sélectionnée
      type: String,
      required: true,
    },
    selectedTerritory: {
      // Territoire affiché (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    clickedFeature: {
      // On clique sur une maille
      type: Object,
      required: false,
      default: null,
    },
    clickedEpocPoint: {
      // On clique sur un point EPOC
      type: Object,
      required: false,
      default: null,
    },
    epocOdfOfficialIsOn: {
      type: Boolean,
      required: true,
    },
    epocOdfReserveIsOn: {
      type: Boolean,
      required: true,
    },
    plan: {
      type: Object,
      required: true,
    },
    orthophoto: {
      type: Object,
      required: true,
    },
    // MOBILE
    mobileMapControlIsOpen: {
      type: Boolean,
      required: true,
    },
  },
  data: () => ({
    // CONFIGURATION DE LA CARTE
    zoom: 11,
    currentZoom: 11,
    oldZoomKnowledgeLevel: 100,
    oldZoomSpeciesDistribution: 100,
    isProgramaticZoom: false,
    center: [48.85341, 2.3488],
    bounds: null,
    // url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    osmUrl:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    envelope: null,
    initTerritory: null,
    // CONFIGURATION DES GEOJSON
    // Indice de complétude
    knowledgeLevelGeojson: null,
    axiosSourceKnowledgeLevel: null,
    axiosErrorKnowledgeLevel: null,
    knowledgeLevelIsLoading: false,
    // Répartition de l'espèce
    speciesDistributionGeojson: null,
    axiosSourceSpeciesDistribution: null,
    axiosErrorSpeciesDistribution: null,
    speciesDistributionIsLoading: false,
    // Points EPOC
    epocOdfOfficialGeojson: null,
    epocOdfReserveGeojson: null,
    // CONFIGURATION DES MAPCONTROLS
    disableScrollPropagation: true,
    noSpeciesData: false,
    featuresClasses: [0.25, 0.5, 0.75, 1],
    searchedFeatureId: null, // Le zonage sélectionné est une maille (recherche depuis la carte de Prospection)
    searchedFeatureCode: null, // Le zonage sélectionné est une maille (recherche depuis l'URL)
    indeterminate: true, // Progress (loading)
    // MOBILE
    seasonIsOpen: false,
    layerIsOpen: false,
    territoryIsOpen: false,
  }),
  computed: {
    knowledgeLevelGeojsonOptions() {
      return {
        onEachFeature: this.knowledgeLevelOnEachFeature,
      }
    },
    knowledgeLevelOnEachFeature() {
      return (feature, layer) => {
        layer.on({
          mouseover: (event) => {
            this.highlightFeature(event)
          },
          mouseout: (event) => {
            this.resetFeatureStyle(event)
          },
          click: (event) => {
            this.$emit('clickedEpocPoint', null)
            this.$emit('clickedFeature', JSON.parse(JSON.stringify(feature)))
            this.zoomToFeature(event)
            this.openMobileMapControl()
          },
        })
      }
    },
    knowledgeLevelGeojsonStyle() {
      let selectedLayer = this.selectedLayer
      let season = this.selectedSeason.value // Nécessaire pour déclencher le changement de style
      return (feature, layer) => {
        selectedLayer = this.selectedLayer
        if (selectedLayer === 'Indice de complétude') {
          season = this.selectedSeason.value // À améliorer
          return {
            weight: 0.8,
            color: '#FFFFFF',
            opacity: 1,
            fillColor: this.setFeatureColor(
              feature.properties[season].percent_knowledge
            ),
            fillOpacity: 0.6,
          }
        } else {
          return {
            weight: 0.8,
            color: '#C4C4C4',
            opacity: 1,
            fillColor: 'rgba(0,0,0,0)',
          }
        }
      }
    },
    speciesDistributionGeojsonOptions() {
      return {
        pointToLayer: this.speciesDistributionPointToLayer,
        onEachFeature: this.speciesDistributionOnEachFeature,
      }
    },
    speciesDistributionPointToLayer() {
      return (geojsonPoint, latlng) => {
        return L.circle(latlng, { radius: 4800 })
      }
    },
    speciesDistributionOnEachFeature() {
      return (feature, layer) => {
        layer.on({
          // mouseover: (event) => {
          //   this.highlightFeature(event)
          // },
          // mouseout: (event) => {
          //   this.resetFeatureStyle(event)
          // },
          click: (event) => {
            this.zoomToFeature(event)
          },
        })
      }
    },
    speciesDistributionGeojsonStyle() {
      return (feature, layer) => {
        if (this.selectedSeason.value === 'breeding') {
          return {
            weight: 1.4,
            color:
              feature.properties.status === 'Nicheur possible'
                ? this.selectedSeason.speciesDistributionColors[0]
                : feature.properties.status === 'Nicheur probable'
                ? this.selectedSeason.speciesDistributionColors[1]
                : this.selectedSeason.speciesDistributionColors[2],
            fillColor:
              feature.properties.status === 'Nicheur possible'
                ? this.selectedSeason.speciesDistributionColors[0]
                : feature.properties.status === 'Nicheur probable'
                ? this.selectedSeason.speciesDistributionColors[1]
                : this.selectedSeason.speciesDistributionColors[2],
            fillOpacity: 0.7,
          }
        } else {
          return {
            weight: 1.4,
            color: this.selectedSeason.speciesDistributionColors[0],
            fillColor: this.selectedSeason.speciesDistributionColors[0],
            fillOpacity: 0.7,
          }
        }
      }
    },
    epocOdfOfficialGeojsonOptions() {
      return {
        pointToLayer: this.epocOdfOfficialPointToLayer,
        onEachFeature: this.epocOdfOfficialOnEachFeature,
      }
    },
    epocOdfOfficialPointToLayer() {
      return (geojsonPoint, latlng) => {
        const epocOdfOfficialIcon = new L.Icon({
          iconUrl: '/prospecting/epoc-ODF-Official.svg',
          iconSize: [32, 39],
          iconAnchor: [16, 35.5],
        })
        return L.marker(latlng, {
          icon: epocOdfOfficialIcon,
        })
      }
    },
    epocOdfOfficialOnEachFeature() {
      return (feature, layer) => {
        layer.bindTooltip('EPOC ODF', {
          direction: 'right',
          offset: [14, -18],
          permanent: false,
          opacity: 1,
          className: 'LeafletTooltip',
        })
        layer.on({
          click: (event) => {
            this.$emit('clickedEpocPoint', feature)
            this.openMobileMapControl()
          },
        })
      }
    },
    epocOdfReserveGeojsonOptions() {
      return {
        pointToLayer: this.epocOdfReservePointToLayer,
        onEachFeature: this.epocOdfReserveOnEachFeature,
      }
    },
    epocOdfReservePointToLayer() {
      return (geojsonPoint, latlng) => {
        const epocOdfReserveIcon = new L.Icon({
          iconUrl: '/prospecting/epoc-ODF-Reserve.svg',
          iconSize: [32, 39],
          iconAnchor: [16, 35.5],
        })
        return L.marker(latlng, {
          icon: epocOdfReserveIcon,
        })
      }
    },
    epocOdfReserveOnEachFeature() {
      return (feature, layer) => {
        layer.bindTooltip('EPOC ODF de réserve', {
          direction: 'right',
          offset: [14, -18],
          permanent: false,
          opacity: 1,
          className: 'LeafletTooltip',
        })
        layer.on({
          click: (event) => {
            this.$emit('clickedEpocPoint', feature)
            this.openMobileMapControl()
          },
        })
      }
    },
  },
  watch: {
    selectedArea(newVal) {
      if (newVal) {
        if (newVal.type_code === 'ATLAS_GRID') {
          // Pouvoir afficher le tableau de bord si c'est une maille qui est sélectionnée
          this.searchedFeatureId = newVal.id
        }
        this.zoomToArea(newVal.bounds)
        this.$emit('clickedFeature', null)
        this.$emit('clickedEpocPoint', null)
      }
    },
    selectedSpecies(newVal) {
      if (newVal) {
        this.$emit('clickedFeature', null)
        this.$emit('clickedEpocPoint', null)
        this.oldZoomSpeciesDistribution = 101
        this.updateSpeciesDistributionGeojson(newVal)
      }
    },
    selectedSeason(newVal) {
      if (this.selectedSpecies) {
        this.updateSpeciesDistributionGeojson(this.selectedSpecies)
      }
    },
    selectedLayer(newVal) {
      if (newVal === 'Aucune') {
        this.$emit('clickedFeature', null)
      }
      this.$emit('clickedEpocPoint', null)
    },
  },
  mounted() {
    // console.log('mounted')
    this.isProgramaticZoom = true
    if (this.$route.query.area && this.$route.query.type) {
      this.$axios
        .$get(
          `/api/v1/lareas/${this.$route.query.type}/${this.$route.query.area}`
        )
        .then((data) => {
          if (this.$route.query.type === 'ATLAS_GRID') {
            this.searchedFeatureCode = this.$route.query.area
          }
          const area = L.geoJSON(data)
          this.$refs.myMap.mapObject.fitBounds(area.getBounds())
        })
        .catch((error) => {
          console.log(error)
        })
    } else {
      if (navigator.geolocation) {
        // La géolocalisation est supportée par le navigateur
        navigator.geolocation.getCurrentPosition(
          this.setGeolocation,
          this.catchGeolocationError
        )
      } else {
        // La géolocalisation N'EST PAS supportée par le navigateur
        this.$axios
          .$get(
            'api/v1/lareas/position?coordinates=2.3488,48.85341&type_code=ATLAS_TERRITORY&bbox=true&only_enable=true'
          )
          .then((data) => {
            const territory = L.geoJSON(data)
            this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
          })
          .catch((error) => {
            console.log(error)
          })
      }
      if (this.$route.query.species) {
        this.$axios
          .$get(`/api/v1/search_taxa?cd_nom=${this.$route.query.species}`)
          .then((data) => {
            this.$emit('selectedSpecies', data[0])
          })
          .catch((error) => {
            console.log(error)
          })
      }
    }
  },
  methods: {
    setGeolocation(position) {
      this.center = [position.coords.latitude, position.coords.longitude]
    },
    catchGeolocationError() {
      // Si l'utilisateur a désactivé la géolocalisation (ou tout autre problème), alors on centre sur la France métropolitaine
      this.$axios
        .$get(
          'api/v1/lareas/position?coordinates=2.3488,48.85341&type_code=ATLAS_TERRITORY&bbox=true&only_enable=true'
        )
        .then((data) => {
          const territory = L.geoJSON(data)
          this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
        })
        .catch((error) => {
          console.log(error)
        })
    },
    defineEnvelope(bounds) {
      const x = [bounds.getWest(), bounds.getEast()]
      const y = [bounds.getNorth(), bounds.getSouth()]
      const envelope = [
        Math.min.apply(Math, x),
        Math.min.apply(Math, y),
        Math.max.apply(Math, x),
        Math.max.apply(Math, y),
      ]
      return envelope
    },
    initiateEnvelope() {
      // console.log('[initiateEnvelope]')
      const initBounds = this.$refs.myMap.mapObject.getBounds()
      this.bounds = initBounds
      this.envelope = this.defineEnvelope(initBounds)
      this.updateKnowledgeLevelGeojson()
      if (this.currentZoom >= 11) {
        this.updateEpocOdfOfficialGeojson()
        this.updateEpocOdfReserveGeojson()
      }
    },
    updateEnvelope(newBounds) {
      // console.log('[updateEnvelope]')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      this.updateKnowledgeLevelGeojson()
      if (this.currentZoom >= 11) {
        this.updateEpocOdfOfficialGeojson()
        this.updateEpocOdfReserveGeojson()
      }
      if (this.selectedSpecies) {
        this.updateSpeciesDistributionGeojson(this.selectedSpecies)
      }
    },
    updateZoom(newZoom) {
      // console.log('Old zoom : ' + this.currentZoom)
      // console.log('New zoom : ' + newZoom)
      this.currentZoom = newZoom
      if (this.currentZoom < 11) {
        this.$emit('clickedFeature', null)
        this.$emit('clickedEpocPoint', null)
      }
    },
    updateKnowledgeLevelGeojson() {
      // console.log('[updateGeojson]')
      // console.log('Ancien zoom : ' + this.oldZoomKnowledgeLevel)
      // console.log('Nouveau zoom : ' + this.currentZoom)
      // console.log(this.axiosSourceKnowledgeLevel)
      if (
        !(
          !this.isProgramaticZoom &&
          this.currentZoom > this.oldZoomKnowledgeLevel &&
          !this.axiosSourceKnowledgeLevel
        )
      ) {
        if (this.axiosSourceKnowledgeLevel) {
          this.axiosSourceKnowledgeLevel.cancel('Resquest has been canceled')
        }
        const cancelToken = this.$axios.CancelToken
        this.axiosSourceKnowledgeLevel = cancelToken.source()
        this.knowledgeLevelIsLoading = true
        this.$axios
          .$get(
            `/api/v1/area/knowledge_level/ATLAS_GRID?envelope=${this.envelope}`,
            {
              cancelToken: this.axiosSourceKnowledgeLevel.token,
            }
          )
          .then((data) => {
            this.knowledgeLevelGeojson = data
            // Pouvoir afficher le tableau de bord si c'est une maille qui est sélectionnée
            if (this.searchedFeatureId) {
              const clickedFeature = this.knowledgeLevelGeojson.features.filter(
                (feature) => {
                  return feature.id === this.searchedFeatureId.toString()
                }
              )
              if (clickedFeature.length > 0) {
                this.$emit('clickedFeature', clickedFeature[0])
                this.searchedFeatureId = null
              }
            }
            if (this.searchedFeatureCode) {
              const clickedFeature = this.knowledgeLevelGeojson.features.filter(
                (feature) => {
                  return (
                    feature.properties.area_code === this.searchedFeatureCode
                  )
                }
              )
              if (clickedFeature.length > 0) {
                this.$emit('clickedFeature', clickedFeature[0])
                this.searchedFeatureCode = null
              }
            }
          })
          .catch((error) => {
            // console.log(error)
            this.axiosErrorKnowledgeLevel = error
          })
          .finally(() => {
            if (!this.axiosErrorKnowledgeLevel) {
              this.axiosSourceKnowledgeLevel = null
              this.knowledgeLevelIsLoading = false
            }
            this.axiosErrorKnowledgeLevel = null
          })
      } else {
        // console.log('Pas de rechargement nécessaire')
      }
      this.oldZoomKnowledgeLevel = this.currentZoom
      this.isProgramaticZoom = false
    },
    updateSpeciesDistributionGeojson(species) {
      // console.log('[updateGeojson]')
      // console.log('Ancien zoom : ' + this.oldZoomSpeciesDistribution)
      // console.log('Nouveau zoom : ' + this.currentZoom)
      // console.log(this.axiosSourceSpeciesDistribution)
      if (
        !(
          !this.isProgramaticZoom &&
          this.currentZoom > this.oldZoomSpeciesDistribution &&
          this.currentZoom !== 11 &&
          !this.axiosSourceSpeciesDistribution
        )
      ) {
        if (this.axiosSourceSpeciesDistribution) {
          this.axiosSourceSpeciesDistribution.cancel(
            'Resquest has been canceled'
          )
        }
        const cancelToken = this.$axios.CancelToken
        this.axiosSourceSpeciesDistribution = cancelToken.source()
        this.speciesDistributionIsLoading = true
        this.noSpeciesData = false
        const grid = this.currentZoom >= 11
        this.$axios
          .$get(
            `/api/v1/taxa/${species.code}?period=${this.selectedSeason.value}_new&grid=${grid}&envelope=${this.envelope}`,
            {
              cancelToken: this.axiosSourceSpeciesDistribution.token,
            }
          )
          .then((data) => {
            this.speciesDistributionGeojson = data
            if (data.features.length === 0) {
              this.noSpeciesData = true
            }
          })
          .catch((error) => {
            // console.log(error)
            this.axiosErrorSpeciesDistribution = error
          })
          .finally(() => {
            if (!this.axiosErrorSpeciesDistribution) {
              this.axiosSourceSpeciesDistribution = null
              this.speciesDistributionIsLoading = false
            }
            this.axiosErrorSpeciesDistribution = null
          })
      } else {
        // console.log('Pas de rechargement nécessaire')
      }
      this.oldZoomSpeciesDistribution = this.currentZoom
      this.isProgramaticZoom = false
    },
    updateEpocOdfOfficialGeojson() {
      this.$axios
        .$get(`/api/v1/epoc?status=Officiel&envelope=${this.envelope}`)
        .then((data) => {
          this.epocOdfOfficialGeojson = data
        })
        .catch((error) => {
          console.log(error)
        })
    },
    updateEpocOdfReserveGeojson() {
      this.$axios
        .$get(`/api/v1/epoc?status=Reserve&envelope=${this.envelope}`)
        .then((data) => {
          this.epocOdfReserveGeojson = data
        })
        .catch((error) => {
          console.log(error)
        })
    },
    setFeatureColor(percent) {
      const featuresColors = this.selectedSeason.featuresColors
      return percent >= this.featuresClasses[3]
        ? featuresColors[4]
        : percent > this.featuresClasses[2]
        ? featuresColors[3]
        : percent > this.featuresClasses[1]
        ? featuresColors[2]
        : percent > this.featuresClasses[0]
        ? featuresColors[1]
        : featuresColors[0]
    },
    highlightFeature(event) {
      event.target.setStyle({
        weight: 3,
        color: '#262626',
      })
      event.target.bringToFront()
    },
    resetFeatureStyle(event) {
      event.target.setStyle({
        weight: 0.8,
        color:
          this.selectedLayer === 'Indice de complétude' ? '#FFFFFF' : '#C4C4C4',
      })
    },
    geolocate() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const center = L.latLng(
            position.coords.latitude,
            position.coords.longitude
          )
          this.isProgramaticZoom = true
          this.$refs.myMap.mapObject.setView(center, 12)
        })
        if (this.$route.query.area && this.$route.query.type) {
          this.$router.push({
            path: '/prospecting',
            query: { area: undefined, type: undefined },
          })
          this.$emit('clickedFeature', null)
        }
      }
    },
    zoomToFeature(event) {
      this.isProgramaticZoom = true
      this.$refs.myMap.mapObject.fitBounds(event.target.getBounds())
    },
    zoomToArea(bounds) {
      this.isProgramaticZoom = true
      this.$refs.myMap.mapObject.fitBounds(bounds)
    },
    deleteSelectedSpecies() {
      this.$emit('selectedSpecies', null)
    },
    deleteClickedEpocPoint() {
      this.$emit('clickedEpocPoint', null)
    },
    // MOBILE
    openMobileMapControl() {
      this.$emit('mobileMapControl', true)
    },
    openOrCloseSeasonsBox() {
      this.seasonIsOpen = !this.seasonIsOpen
    },
    closeSeasonsBox() {
      this.seasonIsOpen = false
    },
    updateSelectedSeason(season) {
      this.$emit('selectedSeason', season)
      this.seasonIsOpen = false
    },
    openOrCloseLayersBox() {
      this.layerIsOpen = !this.layerIsOpen
    },
    closeLayersBox() {
      this.layerIsOpen = false
    },
    updateSelectedLayer(layer) {
      this.$emit('selectedLayer', layer)
    },
    updateEpocOdfOfficial(value) {
      this.$emit('epocOdfOfficialIsOn', value)
    },
    updateEpocOdfReserve(value) {
      this.$emit('epocOdfReserveIsOn', value)
    },
    updatePlan(value) {
      this.$emit('planIsOn', value)
    },
    updatePlanOpacity(value) {
      this.$emit('planOpacity', value)
    },
    updateOrthophoto(value) {
      this.$emit('orthophotoIsOn', value)
    },
    updateOrthophotoOpacity(value) {
      this.$emit('orthophotoOpacity', value)
    },
    openOrCloseTerritoriesBox() {
      this.territoryIsOpen = !this.territoryIsOpen
    },
    closeTerritoriesBox() {
      this.territoryIsOpen = false
    },
  },
}
</script>

<style scoped>
#map-wrap {
  height: calc(100vh - 136px);
}
</style>
