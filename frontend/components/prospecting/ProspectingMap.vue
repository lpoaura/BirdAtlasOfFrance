<!-- La carte doit s'actualiser sur la métropole entière (manque API emprises) -->
<!-- Initier this.center et this.zoom sur la métropole -->
<!-- Ouvrir le tableau de bord de la maille au démarrage -->
<!-- Ne pas considérer les mailles liées aux mers/océans -->
<template>
  <div id="map-wrap">
    <!-- <span> Center : {{ center }} </span><br />
    <span> Bounds : {{ bounds }} </span><br />
    <span> Envelope : {{ envelope }} </span><br />
    <span> GeoJSON : {{ geojson }}</span><br /><br /> -->
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
      <l-tile-layer :url="url" :attribution="attribution" />
      <l-geo-json
        v-if="
          selectedLayer === 'Indice de complétude' ||
          (selectedLayer === 'Points EPOC' && zoom >= 11)
        "
        :geojson="knowledgeLevelGeojson"
        :options="knowledgeLevelGeojsonOptions"
        :options-style="knowledgeLevelGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Points EPOC' && epocOdfOfficialIsOn && zoom >= 11
        "
        :geojson="epocOdfOfficialGeojson"
        :options="epocOdfOfficialGeojsonOptions"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Points EPOC' && epocOdfReserveIsOn && zoom >= 11
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
          :features-colors="featuresColors"
          @selectedSeason="updateSelectedSeason"
        />
        <feature-dashboard-control
          v-if="selectedLayer === 'Indice de complétude' && clickedFeature"
          :clicked-feature="clickedFeature"
          :selected-season="selectedSeason"
        />
        <epoc-dashboard-control
          v-if="selectedLayer === 'Points EPOC' && clickedEpocPoint"
          :clicked-epoc-point="clickedEpocPoint"
        />
      </l-control>
      <l-control
        v-show="selectedLayer === 'Points EPOC' && zoom < 11"
        position="topright"
      >
        <div class="EPOCPointsControl">
          Trop de points à afficher, zoomez à l’échelle d’une maille pour
          visualiser les points EPOC !
        </div>
      </l-control>
      <l-control
        v-show="isLoading && selectedLayer === 'Indice de complétude'"
        position="topright"
      >
        <div class="MapControl">
          <v-progress-circular :indeterminate="indeterminate" />
          <span>Loading</span>
        </div>
      </l-control>
      <l-control-zoom position="bottomright"></l-control-zoom>
      <l-control position="bottomright">
        <div class="GeolocationControl" @click="geolocate">
          <img class="Icon" src="/geolocation.svg" />
        </div>
      </l-control>
    </l-map>
  </div>
</template>

<script>
import L from 'leaflet'
import { LMap, LGeoJson, LControl } from 'vue2-leaflet'
// import 'leaflet/dist/leaflet.css'
import KnowledgeLevelControl from '~/components/prospecting/KnowledgeLevelControl.vue'
import FeatureDashboardControl from '~/components/prospecting/FeatureDashboardControl.vue'
import EpocDashboardControl from '~/components/prospecting/EpocDashboardControl.vue'

export default {
  components: {
    LMap,
    LGeoJson,
    LControl,
    'knowledge-level-control': KnowledgeLevelControl,
    'feature-dashboard-control': FeatureDashboardControl,
    'epoc-dashboard-control': EpocDashboardControl,
  },
  props: {
    selectedMunicipalityBounds: {
      type: Array,
      required: false,
      default: null,
    },
    selectedSpecies: {
      type: Object,
      required: false,
      default: null,
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
    selectedTerritoryBounds: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data: () => ({
    zoom: 12,
    previousZoom: 100,
    isProgramaticZoom: false,
    center: [48.85341, 2.3488],
    bounds: null,
    // url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    url:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    attribution: 'OSM',
    envelope: null,
    disableScrollPropagation: true,
    knowledgeLevelGeojson: null,
    axiosSource: null,
    axiosError: null,
    isLoading: false,
    selectedSeason: { label: 'Toutes saisons', value: 'all_period' },
    featuresClasses: [0.25, 0.5, 0.75, 1],
    featuresColors: {
      allPeriod: [
        'rgba(51, 105, 80, 0.2)',
        'rgba(51, 105, 80, 0.4)',
        'rgba(51, 105, 80, 0.6)',
        'rgba(51, 105, 80, 0.8)',
        '#336950',
      ],
      breeding: ['#FFEDA0', '#FED976', '#FEB24C', '#FD8D3C', '#FC4E2A'],
      wintering: ['#90E0EF', '#00B4D8', '#0077B6', '#023E8A', '#03045E'],
    },
    clickedFeature: null,
    clickedEpocPoint: null,
    epocOdfOfficialGeojson: null,
    epocOdfReserveGeojson: null,
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
        // console.log('[onEachFeature]', feature.properties)
        layer.on({
          mouseover: (event) => {
            this.highlightFeature(event)
          },
          mouseout: (event) => {
            this.resetFeatureStyle(event)
          },
          click: (event) => {
            if (this.selectedLayer === 'Indice de complétude') {
              this.clickedFeature = feature
            }
            // console.log('Maille : ' + this.clickedFeature.properties)
            this.zoomToFeature(event)
          },
        })
      }
    },
    knowledgeLevelGeojsonStyle() {
      let season = this.selectedSeason // Nécessaire pour déclencher le changement de style
      let selectedLayer = this.selectedLayer
      return (feature, layer) => {
        // console.log('[setGeojsonStyle]')
        selectedLayer = this.selectedLayer
        if (selectedLayer === 'Indice de complétude') {
          season = this.selectedSeason // À améliorer
          return {
            weight: 0.8,
            color: '#FFFFFF',
            opacity: 1,
            fillColor: this.setFeatureColor(
              season === 'breeding'
                ? feature.properties.breeding.percent_knowledge
                : season === 'wintering'
                ? feature.properties.wintering.percent_knowledge
                : feature.properties.all_period.percent_knowledge
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
    selectedMunicipalityBounds(newVal) {
      if (newVal != null) {
        this.zoomToArea(newVal)
        this.clickedFeature = null
        this.clickedEpocPoint = null
      }
    },
    selectedSpecies(newVal) {
      if (newVal != null) {
        console.log('Espèce : ' + newVal)
        this.clickedFeature = null
        this.clickedEpocPoint = null
      }
    },
    selectedLayer(newVal) {
      this.clickedFeature = null
      this.clickedEpocPoint = null
    },
    selectedTerritoryBounds(newVal) {
      this.zoomToTerritory(newVal)
    },
  },
  mounted() {
    // console.log('mounted')
    if (this.$route.query.area && this.$route.query.type) {
      // console.log(this.$route.query.area)
      // console.log(this.$route.query.type)
      this.$axios
        .$get(
          `/api/v1/lareas/${this.$route.query.type}/${this.$route.query.area}`
        )
        .then((data) => {
          const area = L.geoJSON(data)
          this.isProgramaticZoom = true
          this.$refs.myMap.mapObject.fitBounds(area.getBounds())
        })
        .catch((error) => {
          console.log(error)
        })
    }
    if (this.$route.query.species) {
      // À REVOIR
      console.log('Espèce détectée : ' + this.$route.query.species)
    } else {
      // À REVOIR
      navigator.geolocation.getCurrentPosition((position) => {
        this.center = [position.coords.latitude, position.coords.longitude]
      })
    }
  },
  methods: {
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
      this.updateknowledgeLevelGeojson()
      if (this.zoom >= 11) {
        this.updateEpocOdfOfficialGeojson()
        this.updateEpocOdfReserveGeojson()
      }
    },
    updateEnvelope(newBounds) {
      // console.log('[updateEnvelope]')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      this.updateknowledgeLevelGeojson()
      if (this.zoom >= 11) {
        this.updateEpocOdfOfficialGeojson()
        this.updateEpocOdfReserveGeojson()
      }
    },
    updateZoom(newZoom) {
      // console.log(newZoom)
      this.zoom = newZoom
      if (this.zoom < 11) {
        this.clickedFeature = null
        this.clickedEpocPoint = null
      }
    },
    updateknowledgeLevelGeojson() {
      // console.log('[updateGeojson]')
      if (this.axiosSource != null) {
        this.axiosSource.cancel('Resquest has been canceled')
      }
      const cancelToken = this.$axios.CancelToken
      this.axiosSource = cancelToken.source()
      if (
        !(
          this.isProgramaticZoom === false &&
          this.$refs.myMap.mapObject.getZoom() > this.previousZoom
        )
      ) {
        this.isLoading = true
        this.$axios
          .$get(`/api/v1/area/knowledge_level/M10?envelope=${this.envelope}`, {
            cancelToken: this.axiosSource.token,
          })
          .then((data) => {
            this.knowledgeLevelGeojson = data
          })
          .catch((error) => {
            // console.log(error)
            this.axiosError = error
          })
          .finally(() => {
            if (this.axiosError === null) {
              this.isLoading = false
            }
            this.axiosError = null
          })
      }
      this.previousZoom = this.$refs.myMap.mapObject.getZoom()
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
      const featuresColors =
        this.selectedSeason.value === 'breeding'
          ? this.featuresColors.breeding
          : this.selectedSeason.value === 'wintering'
          ? this.featuresColors.wintering
          : this.featuresColors.allPeriod
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
          this.selectedLayer === 'Indice de complétude'
            ? '#FFFFFF'
            : 'rgba(0,0,0,0)',
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
    updateSelectedSeason(season) {
      this.selectedSeason = season
    },
  },
}
</script>

<style scoped>
#map-wrap {
  height: calc(100vh - 136px);
}

.EPOCPointsControl {
  background: #fff;
  padding: 10px;
  border: 2px solid #eece25;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.04);
  border-radius: 8px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
  color: #000;
}
</style>
