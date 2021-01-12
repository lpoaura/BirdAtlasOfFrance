<!-- Débuger initiateEnvelope() -->
<!-- Reste à développer : Au clic sur une maille, centrage sur la maille -->
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
          <l-geo-json :geojson="geojson" :options-style="setGeojsonStyle" />
        </l-map>
      </client-only>
    </div>
  </div>
</template>

<script>
// import L from 'leaflet'
import { LMap, LTileLayer, LGeoJson } from 'vue2-leaflet'
import 'leaflet/dist/leaflet.css'

export default {
  components: {
    LMap,
    LTileLayer,
    LGeoJson,
  },
  // props: {
  //   areasData: {
  //     type: Object,
  //     required: true,
  //   },
  // },
  async fetch() {
    console.log('pass')
    this.geojson = await this.$axios.$get(
      `http://127.0.0.1:8888/api/v1/area_knowledge_level/M10?envelope=${this.envelope}`
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
  }),
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
      console.log('initiateEnvelope')
      const initBounds = this.$refs.myMap.mapObject.getBounds()
      this.bounds = initBounds
      this.envelope = this.defineEnvelope(initBounds)
      this.$fetch() // Ne fonctionne pas
    },
    updateEnvelope(newBounds) {
      console.log('updateEnvelope')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      if (this.$refs.myMap.mapObject.getZoom() <= this.previousZoom) {
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
  },
  computed: {
    setGeojsonStyle() {
      return (feature, layer) => {
        console.log('setGeojsonStyle')
        return {
          fillColor: this.setAreaColor(
            feature.properties.breeding.percent_knowledge
          ),
          color: '#f00',
          weight: 0.2,
          opacity: 1,
          fillOpacity: 0.5,
        }
      }
    },
  },
}
</script>
