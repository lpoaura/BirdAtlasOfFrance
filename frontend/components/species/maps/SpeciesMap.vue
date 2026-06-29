<template>
  <div id="map-wrap" ref="test"> <!-- Conteneur principal de la carte -->
    <!-- Composant Leaflet pour la carte avec respectivement 
            - la référence pour accéder à l'objet carte dans les méthodes
            - le niveau de zoom initial de la carte
            - le centre initial de la carte
            - désactive le contrôle de zoom par défaut
            - appelle la méthode initMap lorsque la carte est prête
            - met à jour l'enveloppe lorsque les limites de la carte changent
     -->
    <l-map
      ref="atlasMap" 
      :zoom="zoom"
      :center="center"
      :options="{ zoomControl: false }"
      style="z-index: 0"
      @ready="initMap()"
      @update:bounds="updateEnvelope"
    >
      <!-- Ajoute une couche de tuiles OpenStreetMap -->
      <l-tile-layer
        :url="osmUrl"
        :attribution="'© les contributeurs d’OpenStreetMap'"
      />
      <!-- Ajoute une couche GeoJSON pour afficher les données de distribution des espèces -->
      <l-geo-json
        v-if="speciesDistributionGeojson"
        :geojson="speciesDistributionGeojson"
        :options="speciesDistributionGeojsonOptions"
        :options-style="speciesDistributionGeojsonStyle"
      />
      <!-- Ajoute des contrôles personnalisés à la carte (chargement et légende) -->
      <l-control position="topright" :disable-scroll-propagation="true">
        <commons-map-loading-control :loading="speciesDistributionIsLoading" />
      </l-control>
      <l-control position="topleft" :disable-scroll-propagation="true">
        <species-maps-legend />
      </l-control>
    </l-map>
  </div>
</template>

<script>
// Définit le composant Vue
export default {
  props: {},
  // Données réactives du composant
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
    speciesDistributionIsLoading: true,
    defaultColor: '#336950',
  }),

  // Propriétés calculées :
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
            // Cas standard (breeding, wintering, etc.)
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
          } 
          // Comparaison ODF vs Prospection (obsolète)
          // else if (this.selectedSubject.slug === 'compare-aofm-odf') {
          //   console.debug('CASE compare ODFvsAOFM')
          //   return {
          //     weight: 0,
          //     color: 'rgba(0,0,0,0)',
          //     fillColor:
          //       feature.properties.status === 'ODF'
          //         ? '#EB6A0A'
          //         : feature.properties.status === 'AOFM'
          //         ? '#4C61F4'
          //         : '#D999EF',
          //     fillOpacity: 0.7,
          //   }
          // } 
          else if (this.selectedSubject.slug === 'compare-aofm-odf') {
            // NOUVELLE COMPARAISON: 2009-2012 vs 2019-2023
            console.debug('CASE compare Historic Atlases')
            return {
              weight: 0,
              color: 'rgba(0,0,0,0)',
              fillColor:
                feature.properties.status === 'NEW'
                  ? '#EB6A0A'  // Orange: uniquement 2019-2023
                  : feature.properties.status === 'OLD'
                  ? '#4C61F4'  // Bleu: uniquement 2009-2012
                  : '#D999EF', // Rose: les deux
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

  // Observateurs pour réagir aux changements de certaines propriétés qui déclenchent des actions lorsque ces valeurs changent :
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

  // Méthodes du composant :
  methods: {
    // Initialise la carte et charge les données
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
    
    // Définit les limites de la carte en fonction du territoire sélectionné
    setBounds() {
      if (this.territoriesEnvelopes?.features) {
        const geojson = this.territoriesEnvelopes.features.find((item) => {
          return item.properties.area_code === this.selectedTerritory.area_code
        })
        console.log('TERRITORY', geojson, this.selectedTerritory.area_code)
        const territory = this.$L.geoJSON(geojson)
        this.map.invalidateSize()
        this.map.fitBounds(territory.getBounds())
        // this.map.setMaxBounds(territory.getBounds())
        // this.$refs.atlasMap.mapObject.setMinZoom(
        //   this.$refs.atlasMap.mapObject.getZoom() - 1
        // )
      }
    },

    // Gèrent l'enveloppe géographique :
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

    // Récupère les données des territoires
    async getTerritory() {
      const params = {
        bbox: true,
        only_enable: true,
      }
      this.territoriesEnvelopes = await this.$axios.$get(
        '/api/v1/lareas/type/ATLAS_TERRITORY_SIMPLIFY',
        { params }
      )
    },

    // Récupère les données de distribution des espèces en fonction des paramètres sélectionnés
    async getSpecieData() {
      console.log('/api/v1/taxa/map/distribution', this.speciesDistributionIsLoading )
      this.speciesDistributionIsLoading = true

      if (this.apiRequestController) {
        this.apiRequestController.cancel('Loading canceled')
      }
      this.apiRequestController = this.$axios.CancelToken.source()

      // Url Source selection
      let params = {
        cd_nom: this.cdNom,
        phenology_period: this.selectedSeason.value,
        atlas_period: `new`,
        grid: true,
        envelope: this.envelope ? this.envelope.toString() : null,
      }
      let url = null

      // Atlas ODF standard :
      if (this.selectedSubject.slug === 'odf') {
        console.debug('ODF data')
        url = `/api/v1/taxa/map/distribution`
        params = { ...params }
      } 
      // Atlas historiques :
      else if (this.selectedSubject.slug.startsWith('aofm') || this.selectedSubject.slug.startsWith('odf')) { 
          console.debug('Historic atlas data')
          url = `/api/v1/taxa/map/historic/atlas`
          params = { ...params }
          params.atlas_period = this.selectedSubject.label
          params.period = this.selectedSeason.value
          params.id_area = this.selectedTerritory.id_area
      } 
      // NOUVELLE COMPARAISON: AOFM/ODF (2009-2012 vs 2019-2023) :
      else if (this.selectedSubject.slug === 'compare-aofm-odf') {
        console.debug('Compare Historic Atlases 2009-2012 vs 2019-2023')
        url = `/api/v1/taxa/map/compare/historic/atlas`
        params = {
          cd_nom: this.cdNom,
          period: this.selectedSeason.value,
          id_area: this.selectedTerritory.id_area,
          atlas_period_1: '2009-2012',
          atlas_period_2: '2019-2023',
        }
      }
      // // Comparaison AOFM vs Prospection :
      // else if (this.selectedSubject.slug === 'compare-aofm-prospection') {
      //   console.debug('ODF VS AOFM')
      //   url = `/api/v1/taxa/map/distribution`
      //   params = { ...params }
      //   params.atlas_period = 'compare'
      //   params.grid = false
      // } 

      const axios = this.$axios
      this.speciesDistributionGeojson = await this.$axios
        .$get(url, {
          params,
          cancelToken: this.apiRequestController.token,
        })
        // .then((data) => (this.speciesDistributionGeojson = data))
        .catch(function (thrown) {
          if (axios.isCancel(thrown)) {
            console.debug('Request canceled', thrown.message)
          }
        })
      if (this.speciesDistributionGeojson) {
        this.speciesDistributionIsLoading = false
      }
    },
  },
}
</script>

<style scoped>
#map-wrap {
  flex: 1;
}
</style>
