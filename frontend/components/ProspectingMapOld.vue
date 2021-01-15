<!-- Débuger initiateEnvelope() : le GeoJSON n'est pas chargé -->
<!-- Débuger la MaJ du GeoJSON quand on bouge la carte : async fetch -->
<template>
  <div>
    <span> Center : {{ center }} </span><br />
    <span> Bounds : {{ bounds }} </span><br />
    <span> Envelope : {{ envelope }} </span><br /><br />
    <div v-if="$fetchState.pending" id="loading">
      <v-progress-circular :indeterminate="indeterminate" />
      <span>Map loading...</span>
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
            :options="setGeojsonOptions"
            :options-style="setGeojsonStyle"
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
  },
  watch: {
    selectedTerritoryBounds(newVal) {
      this.zoomToTerritory(newVal)
    },
  },
  async fetch() {
    console.log('[async fetch]')
    this.axiosSource = this.$axios.CancelToken.source()
    // console.log('Source : ' + this.axiosSource)
    this.geojson = await this.$axios.$get(
      `http://127.0.0.1:8888/api/v1/area_knowledge_level/M10?envelope=${this.envelope}`,
      {
        cancelToken: this.axiosSource.token,
      }
    )
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
  }),
  computed: {
    setGeojsonStyle() {
      return (feature, layer) => {
        // console.log('[setGeojsonStyle]')
        return {
          fillColor: this.setAreaColor(
            feature.properties.breeding.percent_knowledge
          ),
          color: '#FFFFFF',
          weight: 0.8,
          opacity: 1,
          fillOpacity: 0.5,
        }
      }
    },
    setGeojsonOptions() {
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
    console.log('mounted')
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition((position) => {
        this.center = [position.coords.latitude, position.coords.longitude]
      })
    }
  },
  methods: {
    initiateEnvelope() {
      console.log('[initiateEnvelope]')
      const initBounds = this.$refs.myMap.mapObject.getBounds()
      this.bounds = initBounds
      this.envelope = this.defineEnvelope(initBounds)
      this.$fetch() // Ne fonctionne pas
    },
    updateEnvelope(newBounds) {
      console.log('[updateEnvelope]')
      // console.log('1/ pending ? ' + this.$fetchState.pending)
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      if (this.$refs.myMap.mapObject.getZoom() <= this.previousZoom) {
        if (this.$fetchState.pending) {
          console.log('Already loading...')
          // this.axiosSource.cancel('OPERATION CANCELED')
          // this.axiosSource = this.$axios.CancelToken.source()
        }
        // console.log('2/ pending ? ' + this.$fetchState.pending)
        // console.log('error ? ' + this.$fetchState.error)
        this.$fetch()
      }
      this.previousZoom = this.$refs.myMap.mapObject.getZoom()
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
    setAreaColor(percent) {
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
