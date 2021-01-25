<template>
  <div id="map-wrap" style="height: 80vh">
    <!-- <span> Center : {{ center }} </span><br />
    <span> Bounds : {{ bounds }} </span><br />
    <span> Envelope : {{ envelope }} </span><br />
    <span> GeoJSON : {{ geojson }}</span><br /><br /> -->
    <l-map
      ref="myMap"
      :zoom="zoom"
      :center="center"
      style="z-index: 0"
      @ready="initiateEnvelope"
      @update:bounds="updateEnvelope"
    >
      <l-tile-layer :url="url" :attribution="attribution" />
      <l-geo-json
        :geojson="geojson"
        :options="geojsonOptions"
        :options-style="geojsonStyle"
      />
      <l-control v-if="isLoading" :position="'topright'">
        <div class="mapControl">
          <v-progress-circular :indeterminate="indeterminate" />
          <span>Loading</span>
        </div>
      </l-control>
      <l-control :position="'bottomright'">
        <legend-content
          :features-colors="
            selectedSeason === 'breeding'
              ? breedingFeaturesColors
              : selectedSeason === 'wintering'
              ? winteringFeaturesColors
              : allPeriodFeaturesColors
          "
        />
      </l-control>
    </l-map>
  </div>
</template>

<script>
import L from 'leaflet'
import { LMap, LTileLayer, LGeoJson, LControl } from 'vue2-leaflet'
import 'leaflet/dist/leaflet.css'
import LegendContent from '~/components/LegendContent.vue'

export default {
  components: {
    LMap,
    LTileLayer,
    LGeoJson,
    LControl,
    LegendContent,
  },
  props: {
    selectedSeason: {
      type: String,
      required: true,
      default: 'breeding',
    },
    selectedCityBounds: {
      type: Array,
      required: false,
      default: null,
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
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: 'OSM',
    envelope: null,
    geojson: null,
    axiosSource: null,
    axiosError: null,
    isLoading: false,
    featuresClasses: [0.1, 0.2, 0.5, 1],
    breedingFeaturesColors: [
      '#FFEDA0',
      '#FED976',
      '#FEB24C',
      '#FD8D3C',
      '#FC4E2A',
    ],
    winteringFeaturesColors: [
      '#90E0EF',
      '#00B4D8',
      '#0077B6',
      '#023E8A',
      '#03045E',
    ],
    allPeriodFeaturesColors: [
      '#d8f3dc',
      '#95d5b2',
      '#52b788',
      '#2d6a4f',
      '#1b4332',
    ],
    clickedFeature: null,
    indeterminate: true,
  }),
  computed: {
    geojsonStyle() {
      let season = this.selectedSeason // Nécessaire pour déclencher le changement de style
      return (feature, layer) => {
        // console.log('[setGeojsonStyle]')
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
      }
    },
    geojsonOptions() {
      return {
        onEachFeature: this.onEachFeature,
      }
    },
    onEachFeature() {
      return (feature, layer) => {
        // console.log('[onEachFeature]', feature.properties)
        layer.on({
          click: (event) => {
            this.clickedFeature = feature.properties
            this.$emit('clickedFeature', this.clickedFeature)
            // this.highlightFeature(event)
            this.zoomToFeature(event)
          },
        })
      }
    },
  },
  watch: {
    selectedCityBounds(newVal) {
      if (newVal != null) {
        this.zoomToArea(newVal)
      }
    },
    selectedTerritoryBounds(newVal) {
      this.zoomToTerritory(newVal)
    },
  },
  mounted() {
    // console.log('mounted')
    if (navigator.geolocation) {
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
      this.updateGeojson(this.envelope)
    },
    updateEnvelope(newBounds) {
      // console.log('[updateEnvelope]')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      this.updateGeojson(this.envelope)
    },
    updateGeojson(envelope) {
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
          .$get(
            `http://127.0.0.1:8888/api/v1/area_knowledge_level/M10?envelope=${this.envelope}`,
            {
              cancelToken: this.axiosSource.token,
            }
          )
          .then((data) => {
            this.geojson = data
          })
          .catch((error) => {
            // console.log(error)
            this.axiosError = error
          })
          .finally(() => {
            if (this.axiosError == null) {
              this.isLoading = false
            }
            this.axiosError = null
          })
      }
      this.previousZoom = this.$refs.myMap.mapObject.getZoom()
      this.isProgramaticZoom = false
    },
    setFeatureColor(percent) {
      const featuresColors =
        this.selectedSeason === 'breeding'
          ? this.breedingFeaturesColors
          : this.selectedSeason === 'wintering'
          ? this.winteringFeaturesColors
          : this.allPeriodFeaturesColors
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
        color: '#323232',
        weight: 5,
      })
      event.target.bringToFront()
    },
    zoomToFeature(event) {
      this.isProgramaticZoom = true
      this.$refs.myMap.mapObject.fitBounds(event.target.getBounds())
    },
    zoomToArea(bounds) {
      this.isProgramaticZoom = true
      this.$refs.myMap.mapObject.fitBounds(bounds)
    },
    // À supprimer lorsque les emprises de région/DOM-TOM seront dispos
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
  },
}
</script>
