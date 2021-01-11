<template>
  <div>
    <span> Center : {{ center }} </span><br />
    <span> Bounds : {{ bounds }} </span><br />
    <span> Envelope : {{ envelope }} </span>
    <div id="map-wrap" style="height: 100vh">
      <client-only>
        <l-map
          :zoom="zoom"
          :center="center"
          style="z-index: 0"
          @update:bounds="updateBounds"
        >
          <l-tile-layer :url="url" :attribution="attribution" />
          <l-geo-json :geojson="areasData" />
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
  props: {
    areasData: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    zoom: 12,
    center: [48.85341, 2.3488],
    bounds: null,
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: 'OSM',
    envelope: null,
    geojson: null,
  }),
  mounted() {
    // this.getEnvelope()
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition((position) => {
        this.center = [position.coords.latitude, position.coords.longitude]
      })
    }
  },
  methods: {
    updateBounds(bounds) {
      this.bounds = bounds
      const x = [bounds._southWest.lng, bounds._northEast.lng]
      const y = [bounds._northEast.lat, bounds._southWest.lat]
      this.envelope = [
        Math.min.apply(Math, x),
        Math.min.apply(Math, y),
        Math.max.apply(Math, x),
        Math.max.apply(Math, y),
      ]
      this.$emit('envelopeUpdated', this.envelope)
    },
    //   getEnvelope: () => {
    //     if (navigator.geolocation) {
    //       navigator.geolocation.getCurrentPosition((position) => {
    //         console.log(position.coords.latitude)
    //         console.log(position.coords.longitude)
    //         this.center = [position.coords.latitude, position.coords.longitude]
    //         console.log(this.center)
    //       })
    //     }
    //   },
  },
}
</script>
