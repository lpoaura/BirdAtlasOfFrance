<template>
  <div>
    <!-- <span> Center : {{ center }} </span><br />
    <span> Bounds : {{ bounds }} </span><br />
    <span> Envelope : {{ envelope }} </span><br />
    <span> GeoJSON : {{ geojson }}</span><br />
    <span>{{ selectedSeason }}</span><br /><br /> -->
    <div v-if="isLoading" id="loading">
      <v-progress-circular :indeterminate="indeterminate" />
      <span>Map is loading...</span>
    </div>
    <div id="map-wrap" style="height: 100vh">
      <client-only>
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
        </l-map>
      </client-only>
    </div>
  </div>
</template>

<script>
import L from 'leaflet'
import { LMap, LTileLayer, LGeoJson } from 'vue2-leaflet'
import 'leaflet/dist/leaflet.css'

export default {
  components: {
    LMap,
    LTileLayer,
    LGeoJson,
  },
  props: {
    selectedTerritoryBounds: {
      type: Object,
      required: false,
    },
    selectedSeason: {
      type: String,
      required: true,
      default: 'breeding',
    },
  },
  watch: {
    envelope(newVal) {
      this.updateGeojson(newVal)
    },
    selectedTerritoryBounds(newVal) {
      this.zoomToTerritory(newVal)
    },
  },
  data: () => ({
    zoom: 12,
    previousZoom: 100,
    center: [48.85341, 2.3488],
    bounds: null,
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: 'OSM',
    envelope: null,
    geojson: null,
    indeterminate: true,
    axiosSource: null,
    axiosError: null,
    isLoading: false,
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
          fillColor:
            season === 'breeding'
              ? this.setFeatureColorBreeding(
                  feature.properties.breeding.percent_knowledge
                )
              : season === 'wintering'
              ? this.setFeatureColorWintering(
                  feature.properties.wintering.percent_knowledge
                )
              : this.setFeatureColorAllPeriod(
                  feature.properties.all_period.percent_knowledge
                ),
          fillOpacity: 0.5,
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
        // console.log('[onEachFeature]')
        layer.on({
          click: this.zoomToFeature.bind(this),
        })
      }
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
    },
    updateEnvelope(newBounds) {
      // console.log('[updateEnvelope]')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
    },
    updateGeojson(envelope) {
      // console.log('[updateGeojson]')
      if (this.$refs.myMap.mapObject.getZoom() <= this.previousZoom) {
        if (this.axiosSource != null) {
          this.axiosSource.cancel('Resquest has been canceled')
        }
        const cancelToken = this.$axios.CancelToken
        this.axiosSource = cancelToken.source()
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
    },
    setFeatureColorBreeding(percent) {
      return percent >= 1
        ? '#FC4E2A'
        : percent > 0.5
        ? '#FD8D3C'
        : percent > 0.2
        ? '#FEB24C'
        : percent > 0.1
        ? '#FED976'
        : '#FFEDA0'
    },
    setFeatureColorWintering(percent) {
      return percent >= 1
        ? '#03045E'
        : percent > 0.5
        ? '#023E8A'
        : percent > 0.2
        ? '#0077B6'
        : percent > 0.1
        ? '#00B4D8'
        : '#90E0EF'
    },
    setFeatureColorAllPeriod(percent) {
      return percent >= 1
        ? '#1b4332'
        : percent > 0.5
        ? '#2d6a4f'
        : percent > 0.2
        ? '#52b788'
        : percent > 0.1
        ? '#95d5b2'
        : '#d8f3dc'
    },
    zoomToFeature(event) {
      this.$refs.myMap.mapObject.fitBounds(event.target.getBounds())
    },
    zoomToTerritory(bounds) {
      const firstCorner = L.latLng(bounds._northEast.lat, bounds._northEast.lng)
      const secondCorner = L.latLng(
        bounds._southWest.lat,
        bounds._southWest.lng
      )
      const latLngBounds = L.latLngBounds(firstCorner, secondCorner)
      this.$refs.myMap.mapObject.fitBounds(latLngBounds)
    },
  },
}
</script>
