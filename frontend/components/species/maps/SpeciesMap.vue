<template>
  <div id="map-wrap" ref="test">
    <!-- <div>selectedTerritory {{ selectedTerritory }}</div>
    <div>selectedSubject {{ selectedSubject }}</div>
    <div>selectedSeason {{ selectedSeason }}</div> -->
    <!-- MAP -->
    <l-map
      ref="atlasMap"
      :zoom="zoom"
      :center="center"
      :options="{ zoomControl: false }"
      style="z-index: 0"
      @ready="initMap()"
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
  props: {},
  data: () => ({
    // CONFIGURATION DE LA CARTE
    zoom: 6,
    map: null,
    // currentZoom: 11,
    center: [46.4, 2.2],
    bounds: null,
    osmUrl:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    envelope: null,
    // CONFIGURATION DES GEOJSON
    // Emprises des territoires
    territoriesEnvelopes: {},
    speciesDistributionGeojson: null,
    apiRequestController: null,
    speciesDistributionIsLoading: false,
    defaultColor: '#336950',
  }),
  computed: {
    // selectedTab() {
    //   return this.$store.state.species.selectedTab
    // },
    cdNom() {
      return this.$store.state.species.cdNom
    },
    selectedSubject() {
      return this.$store.state.species.selectedSubject
    },
    selectedTerritory() {
      return this.$store.state.species.selectedTerritory
    },
    selectedSeason() {
      return this.$store.state.species.selectedSeason
    },
    speciesDistributionGeojsonOptions() {
      return {
        pointToLayer: this.speciesDistributionPointToLayer,
        onEachFeature: this.speciesDistributionOnEachFeature,
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
          layer.bindTooltip(`${feature.properties.status}`, {
            permanent: false,
            sticky: true,
          })
        }
      }
    },
    speciesDistributionGeojsonStyle() {
      return (feature, layer) => {
        if (this.selectedSeason.speciesDistributionColors) {
          if (!this.selectedSubject.slug.startsWith('compare')) {
            if (this.selectedSeason.value === 'breeding') {
              console.debug('CASE breeding')
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
              console.debug('CASE not breeding not diff ODF vs AOFM')
              return {
                weight: 1.4,
                color: this.selectedSeason.speciesDistributionColors[0],
                fillColor: this.selectedSeason.speciesDistributionColors[0],
                fillOpacity: 0.7,
              }
            }
          } else {
            console.debug('CASE compare ODFvsAOFM')
            return {
              weight: 0,
              color: 'rgba(0,0,0,0)',
              fillColor:
                feature.properties.status === 'ODF'
                  ? '#EB6A0A'
                  : feature.properties.status === 'AOFM'
                  ? '#4C61F4'
                  : '#D999EF',
              fillOpacity: 0.7,
            }
          }
        } else {
          console.debug('CASE default_case')
          return {
            weight: 1.4,
            color: this.defaultColor,
            fillColor: this.defaultColor,
            fillOpacity: 0.7,
          }
        }
      }
    },
  },
  watch: {
    envelope() {
      this.getSpecieData()
    },
    selectedTerritory(newVal) {
      if (newVal.area_code) {
        this.isProgramaticZoom = true
        this.setBounds()
      }
    },
    selectedSeason: {
      handler(newVal, oldVal) {
        if (newVal.value !== oldVal.value) {
          this.getSpecieData()
        }
      },
      deep: true,
    },
    selectedSubject: {
      handler(newVal, oldVal) {
        if (newVal.slug !== oldVal.slug) {
          this.getSpecieData()
        }
      },
      deep: true,
    },
  },
  methods: {
    initMap() {
      this.map = this.$refs.atlasMap.mapObject
      this.apiRequestController = this.$axios.CancelToken.source()
      this.getTerritory().then(() => {
        this.setBounds()
        this.initiateEnvelope()
      })
      this.getSpecieData()
      this.initiateEnvelope()
    },
    setBounds() {
      if (Object.keys(this.territoriesEnvelopes).includes('features')) {
        const geojson = this.territoriesEnvelopes.features.find((item) => {
          return item.properties.area_code === this.selectedTerritory.area_code
        })
        const territory = this.$L.geoJSON(geojson)
        this.map.invalidateSize()
        this.map.fitBounds(territory.getBounds())
        this.map.setMaxBounds(territory.getBounds())
        // this.$refs.atlasMap.mapObject.setMinZoom(
        //   this.$refs.atlasMap.mapObject.getZoom() - 1
        // )
      }
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
      const initBounds = this.map.getBounds()
      this.bounds = initBounds
      this.envelope = this.defineEnvelope(initBounds)
    },
    updateEnvelope(newBounds) {
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
    },

    async getTerritory() {
      this.territoriesEnvelopes = await this.$axios.$get(
        '/api/v1/lareas/type/ATLAS_TERRITORY?bbox=true&only_enable=true'
      )
    },
    async getSpecieData() {
      if (this.apiRequestController) {
        this.apiRequestController.cancel('Loading canceled')
      }
      this.apiRequestController = this.$axios.CancelToken.source()
      this.speciesDistributionIsLoading = true
      // Url Source selection
      let requestParams = {
        cd_nom: this.cdNom,
        phenology_period: this.selectedSeason.value,
        atlas_period: `new`,
        grid: true,
        envelope: this.envelope ? this.envelope.toString() : null,
      }
      let url = `/api/v1/taxa/distribution`
      if (this.selectedSubject.slug === 'odf') {
        console.debug('ODF data')
        url = `/api/v1/taxa/distribution`
        requestParams = { ...requestParams }
      } else if (this.selectedSubject.slug.startsWith('aofm')) {
        console.debug('AOFM data')
        url = `/api/v1/taxa/historic/atlas/data`
        requestParams = { ...requestParams }
        requestParams.atlas_period = this.selectedSubject.label
        requestParams.period = this.selectedSeason.value
      } else if (this.selectedSubject.slug.startsWith('compare')) {
        console.debug('ODF VS AOFM')
        url = `/api/v1/taxa/distribution`
        requestParams = { ...requestParams }
        requestParams.atlas_period = 'compare'
        requestParams.grid = false
      }
      const axios = this.$axios
      this.speciesDistributionGeojson = await this.$axios
        .$get(url, {
          params: requestParams,
          cancelToken: this.apiRequestController.token,
        })
        // .then((data) => (this.speciesDistributionGeojson = data))
        .catch(function (thrown) {
          if (axios.isCancel(thrown)) {
            console.debug('Request canceled', thrown.message)
          }
        })

      this.speciesDistributionIsLoading = false
    },
  },
}
</script>

<style scoped>
#map-wrap {
  flex: 1;
}
</style>
