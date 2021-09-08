<template>
  <div id="map-wrap">
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
          class="MapControl epoc"
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
      </l-control>
      <l-control
        v-show="selectedLayer === 'Points EPOC' && currentZoom < 11"
        position="topleft"
      >
        <div class="InformationControl">
          <h5 class="black02 fw-500">
            Trop de points à afficher, zoomez à l’échelle d’une maille pour
            visualiser les points EPOC.
          </h5>
        </div>
      </l-control>
      <l-control
        v-show="
          (knowledgeLevelIsLoading &&
            selectedLayer === 'Indice de complétude') ||
          (speciesDistributionIsLoading &&
            selectedLayer === 'Répartition de l\'espèce')
        "
        position="topright"
      >
        <div class="InformationControl">
          <v-progress-circular
            :size="20"
            :width="3"
            :indeterminate="indeterminate"
            class="right-margin-8"
          />
          <h5 class="black02 fw-500">Chargement des données</h5>
        </div>
      </l-control>
      <l-control
        v-show="
          !speciesDistributionIsLoading &&
          noSpeciesData &&
          selectedLayer === 'Répartition de l\'espèce'
        "
        position="topright"
      >
        <div class="InformationControl">
          <h5 class="black02 fw-500">
            Pas de données pour la saison et l'emprise choisies.
          </h5>
        </div>
      </l-control>
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
  },
  props: {
    selectedArea: {
      type: Object,
      required: false,
      default: null,
    },
    selectedSpecies: {
      type: Object,
      required: false,
      default: null,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
    selectedLayer: {
      type: String,
      required: true,
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
    selectedTerritoryBounds: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data: () => ({
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
    disableScrollPropagation: true,
    knowledgeLevelGeojson: null,
    speciesDistributionGeojson: null,
    epocOdfOfficialGeojson: null,
    epocOdfReserveGeojson: null,
    axiosSourceKnowledgeLevel: null,
    axiosErrorKnowledgeLevel: null,
    axiosSourceSpeciesDistribution: null,
    axiosErrorSpeciesDistribution: null,
    knowledgeLevelIsLoading: false,
    speciesDistributionIsLoading: false,
    noSpeciesData: false,
    featuresClasses: [0.25, 0.5, 0.75, 1],
    clickedFeature: null,
    searchedFeatureId: null,
    searchedFeatureCode: null,
    clickedEpocPoint: null,
    indeterminate: true,
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
            this.clickedEpocPoint = null
            this.clickedFeature = JSON.parse(JSON.stringify(feature))
            this.zoomToFeature(event)
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
            this.clickedEpocPoint = feature
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
            this.clickedEpocPoint = feature
          },
        })
      }
    },
  },
  watch: {
    selectedArea(newVal) {
      if (newVal) {
        if (newVal.type_code === 'ATLAS_GRID') {
          this.searchedFeatureId = newVal.id
        }
        this.zoomToArea(newVal.bounds)
        this.clickedFeature = null
        this.clickedEpocPoint = null
      }
    },
    selectedSpecies(newVal) {
      if (newVal) {
        this.clickedFeature = null
        this.clickedEpocPoint = null
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
        this.clickedFeature = null
      }
      this.clickedEpocPoint = null
    },
    selectedTerritoryBounds(newVal) {
      this.zoomToTerritory(newVal)
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
      // console.log('New zoom : ' + newZoom)
      this.currentZoom = newZoom
      if (this.currentZoom < 11) {
        this.clickedFeature = null
        this.clickedEpocPoint = null
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
            if (this.searchedFeatureId) {
              const clickedFeature = this.knowledgeLevelGeojson.features.filter(
                (feature) => {
                  return feature.id === this.searchedFeatureId.toString()
                }
              )
              if (clickedFeature.length > 0) {
                this.clickedFeature = clickedFeature[0]
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
                this.clickedFeature = clickedFeature[0]
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
        this.$axios
          .$get(
            `/api/v1/taxa/${species.code}?period=${this.selectedSeason.value}_new&envelope=${this.envelope}`,
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
          this.clickedFeature = null
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
    // À SUPPRIMER lorsque les emprises de région/DOM-TOM seront dispos
    zoomToTerritory(bounds) {
      const firstCorner = L.latLng(bounds._northEast.lat, bounds._northEast.lng)
      const secondCorner = L.latLng(
        bounds._southWest.lat,
        bounds._southWest.lng
      )
      const latLngBounds = L.latLngBounds(firstCorner, secondCorner)
      this.isProgramaticZoom = true
      this.$refs.myMap.mapObject.fitBounds(latLngBounds)
    },
    deleteSelectedSpecies() {
      this.$emit('selectedSpecies', null)
    },
    deleteClickedEpocPoint() {
      this.clickedEpocPoint = null
    },
  },
}
</script>

<style scoped>
#map-wrap {
  height: calc(100vh - 136px);
}

.MapControl.epoc {
  width: 506px;
  max-height: calc(100vh - 156px);
}
</style>
