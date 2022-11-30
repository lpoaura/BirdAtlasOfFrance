<template>
  <div id="map-wrap">
    <div>selectedTerritory {{ selectedTerritory }}</div>
    <div>selectedSubject {{ selectedSubject }}</div>
    <div>selectedSeason {{ selectedSeason }}</div>
    <!-- <div>{{ selectedSubject.seasons.includes(selectedSeason.value) }}</div> -->
    <!-- MAP -->
    <l-map
      ref="myMap"
      :zoom="zoom"
      :center="center"
      :options="{ zoomControl: false }"
      style="z-index: 0"
      @ready="initiateEnvelope"
      @update:bounds="updateEnvelope"
    >
      <!-- LAYERS -->
      <l-tile-layer
        :url="osmUrl"
        :attribution="'© les contributeurs d’OpenStreetMap'"
      />

      <!-- MAP DATA -->
      <!-- <l-geo-json
        :geojson="speciesDistributionGeojson"
        :options="speciesDistributionGeojsonOptions"
        :options-style="speciesDistributionGeojsonStyle"
      /> -->
    </l-map>
  </div>
</template>

<script>
export default {
  props: {
    selectedTerritory: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true
    },
    selectedSubject: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true
    },
    selectedSeason: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true
    }
  },
  data: () => ({
    // CONFIGURATION DE LA CARTE
    zoom: 11,
    // currentZoom: 11,
    center: [48.85341, 2.3488],
    bounds: null,
    osmUrl:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    envelope: null,
    // CONFIGURATION DES GEOJSON
    // Emprises des territoires
    territoriesEnvelopes: null
  }),
  watch: {
    selectedTerritory(newVal) {
      if (newVal.area_code) {
        const territory = this.$L.geoJSON(
          this.territoriesEnvelopes.features.filter((item) => {
            return item.properties.area_code === newVal.area_code
          })
        )
        this.isProgramaticZoom = true
        this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
      }
    }
  },
  mounted() {
    this.$axios
      .$get('/api/v1/lareas/type/ATLAS_TERRITORY?bbox=true&only_enable=true')
      .then((data) => {
        this.territoriesEnvelopes = data
        // UPDATE NEEDED : centrer sur le territoire sélectionné (ne fonctionne pas actuellement)
        // const territory = this.$L.geoJSON(
        //   this.territoriesEnvelopes.features.filter((item) => {
        //     return (
        //       item.properties.area_code === this.selectedTerritory.area_code
        //     )
        //   })
        // )
        // this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
        // END UPDATE NEEDED
      })
      .catch((error) => {
        console.log(error)
      })
  },
  methods: {
    defineEnvelope(bounds) {
      const x = [bounds.getWest(), bounds.getEast()]
      const y = [bounds.getNorth(), bounds.getSouth()]
      const envelope = [
        Math.min.apply(Math, x),
        Math.min.apply(Math, y),
        Math.max.apply(Math, x),
        Math.max.apply(Math, y)
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
    }
  }
}
</script>

<style scoped>
#map-wrap {
  flex: 1;
}
</style>
