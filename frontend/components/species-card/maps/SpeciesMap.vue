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
      <l-geo-json
        v-if="speciesDistributionGeojson"
        :geojson="speciesDistributionGeojson"
        :options="speciesDistributionGeojsonOptions"
        :options-style="speciesDistributionGeojsonStyle"
      />
      <l-control position="topright" :disable-scroll-propagation="true">
        <generic-map-loading-control :loading="speciesDistributionIsLoading" />
      </l-control>
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
    },
    cdnom: {
      type: String,
      required: true
    }
  },
  data: () => ({
    // CONFIGURATION DE LA CARTE
    zoom: 6,
    // currentZoom: 11,
    center: [46.4, 2.2],
    bounds: null,
    osmUrl:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    envelope: null,
    // CONFIGURATION DES GEOJSON
    // Emprises des territoires
    territoriesEnvelopes: null,
    speciesDistributionGeojson: null,
    apiRequestController: null,
    speciesDistributionIsLoading: false
  }),
  watch: {
    envelope() {
      this.getSpecieData()
    },
    selectedTerritory(newVal) {
      if (newVal.area_code) {
        // const territory = this.$L.geoJSON(
        //   this.territoriesEnvelopes.features.filter((item) => {
        //     return item.properties.area_code === newVal.area_code
        //   })
        // )
        this.isProgramaticZoom = true
        // this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
        this.setBounds()
      }
    },
    selectedSeason: {
      handler(newVal, oldVal) {
        if (newVal.value !== oldVal.value) {
          this.getSpecieData()
        }
      },
      deep: true
    },
    selectedSubject: {
      handler(newVal, oldVal) {
        if (newVal.slug !== oldVal.slug) {
          this.getSpecieData()
        }
      },
      deep: true
    }
  },
  mounted() {
    this.apiRequestController = this.$axios.CancelToken.source()
    this.getTerritory().then(() => this.setBounds())
    this.getSpecieData()
  },
  methods: {
    setBounds() {
      console.log('this.territoriesEnvelopes', this.territoriesEnvelopes)

      const territory = this.$L.geoJSON(
        this.territoriesEnvelopes.features.find((item) => {
          return item.properties.area_code === this.selectedTerritory.area_code
        })
      )
      this.$refs.myMap.mapObject.invalidateSize()
      this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
      this.$refs.myMap.mapObject.setMaxBounds(territory.getBounds())
      console.log(this.$refs.myMap.mapObject.getZoom())
    },
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
    },
    speciesDistributionGeojsonOptions() {
      return {
        pointToLayer: this.speciesDistributionPointToLayer,
        onEachFeature: this.speciesDistributionOnEachFeature
      }
    },
    speciesDistributionPointToLayer() {
      return (geojsonPoint, latlng) => {
        return this.$L.circle(latlng, { radius: 4800 })
      }
    },
    speciesDistributionOnEachFeature() {
      return (feature, layer) => {
        if (feature.properties && feature.properties.status) {
          layer.bindTooltip(
            `<div>Status : ${feature.properties.status} </div>`,
            { permanent: false, sticky: true }
          )
        }
      }
    },
    speciesDistributionGeojsonStyle() {
      const selectedSeason = this.selectedSeason
      return (feature, layer) => {
        if (this.selectedSeason.value === 'breeding') {
          console.debug(feature.properties.status)
          return {
            weight: 1.4,
            color:
              feature.properties.status === 'Nicheur possible'
                ? selectedSeason.speciesDistributionColors[0]
                : feature.properties.status === 'Nicheur probable'
                ? selectedSeason.speciesDistributionColors[1]
                : selectedSeason.speciesDistributionColors[2],
            fillColor:
              feature.properties.status === 'Nicheur possible'
                ? selectedSeason.speciesDistributionColors[0]
                : feature.properties.status === 'Nicheur probable'
                ? selectedSeason.speciesDistributionColors[1]
                : selectedSeason.speciesDistributionColors[2],
            fillOpacity: 0.7
          }
        } else {
          return {
            weight: 1.4,
            color: selectedSeason.speciesDistributionColors[0],
            fillColor: selectedSeason.speciesDistributionColors[0],
            fillOpacity: 0.7
          }
        }
      }
    },
    async getTerritory() {
      this.territoriesEnvelopes = await this.$axios.$get(
        '/api/v1/lareas/type/ATLAS_TERRITORY?bbox=true&only_enable=true'
      )
    },
    async getSpecieData() {
      if (this.apiRequestController) {
        this.apiRequestController.cancel('Operation canceled')
      }
      this.apiRequestController = this.$axios.CancelToken.source()
      this.speciesDistributionIsLoading = true
      // Url Source selection
      let url = `/api/v1/taxa/distribution?cd_nom=${this.cdnom}&period=${this.selectedSeason.value}_new&grid=true`
      if (this.selectedSubject && this.selectedSubject.slug === 'odf') {
        console.debug('ODF data')
        url = `/api/v1/taxa/distribution?cd_nom=${this.cdnom}&period=${this.selectedSeason.value}_new&grid=true`
      } else if (
        this.selectedSubject &&
        this.selectedSubject.slug.startsWith('aofm')
      ) {
        console.debug('AOFM data')
        url = `/api/v1/taxa/historic/atlas/data?cd_nom=${this.cdnom}&atlas_period=${this.selectedSubject.label}&period=${this.selectedSeason.value}&grid=true`
      } else {
        console.log('else')
      }
      url = this.envelope ? `${url}&envelope=${this.envelope}` : url

      this.speciesDistributionGeojson = await this.$axios.$get(url, {
        cancelToken: this.apiRequestController.token
      })
      this.speciesDistributionIsLoading = false

      setTimeout(() => {
        this.apiRequestController.cancel('Abort test')
      }, 200)
    }
  }
}
</script>

<style scoped>
#map-wrap {
  flex: 1;
}
</style>
