<!-- La carte doit s'actualiser sur la métropole entière (manque API emprises) -->
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
          selectedSpecies &&
          selectedLayer === 'Répartition de l\'espèce' &&
          speciesDistributionGeojson
        "
        :geojson="speciesDistributionGeojson"
        :options="speciesDistributionGeojsonOptions"
        :options-style="speciesDistributionGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Indice de complétude' ||
          (selectedLayer === 'Points EPOC' && currentZoom >= 11)
        "
        :geojson="knowledgeLevelGeojson"
        :options="knowledgeLevelGeojsonOptions"
        :options-style="knowledgeLevelGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Points EPOC' &&
          epocOdfOfficialIsOn &&
          currentZoom >= 11
        "
        :geojson="epocOdfOfficialGeojson"
        :options="epocOdfOfficialGeojsonOptions"
      />
      <l-geo-json
        v-if="
          selectedLayer === 'Points EPOC' &&
          epocOdfReserveIsOn &&
          currentZoom >= 11
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
          @selectedSeason="updateSelectedSeason"
        />
        <feature-dashboard-control
          v-if="
            ['Indice de complétude', 'Points EPOC'].includes(selectedLayer) &&
            clickedFeature &&
            !clickedEpocPoint
          "
          :clicked-feature="clickedFeature"
          :selected-season="selectedSeason"
        />
        <species-dashboard-control
          v-if="selectedLayer === 'Répartition de l\'espèce' && selectedSpecies"
          :selected-species="selectedSpecies"
          :selected-season="selectedSeason"
          @selectedSeason="updateSelectedSeason"
          @selectedSpecies="deleteSelectedSpecies"
        />
        <section
          v-if="selectedLayer === 'Points EPOC' && clickedEpocPoint"
          class="EpocDashboardControl"
        >
          <div
            v-if="clickedFeature"
            class="FeatureComeBack"
            @click="deleteClickedEpocPoint"
          >
            <img class="FeatureComeBackIcon" src="/previous.svg" />
            <span class="FeatureComeBackLabel">{{
              clickedFeature.properties.area_name
            }}</span>
          </div>
          <epoc-dashboard-control :clicked-epoc-point="clickedEpocPoint" />
        </section>
      </l-control>
      <l-control
        v-show="selectedLayer === 'Points EPOC' && currentZoom < 11"
        position="topright"
      >
        <div class="EpocGeojsonControl">
          Trop de points à afficher, zoomez à l’échelle d’une maille pour
          visualiser les points EPOC !
        </div>
      </l-control>
      <l-control
        v-show="
          (knowledgeLevelIsLoading &&
            selectedLayer === 'Indice de complétude') ||
          (speciesDistributionIsLoading &&
            selectedLayer === 'Répartition de l\'espèce')
        "
        position="topright"
      >
        <div class="EpocGeojsonControl">
          <v-progress-circular
            :size="20"
            :width="3"
            :indeterminate="indeterminate"
          />
          <span style="margin-left: 5px">Chargement des données</span>
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
import SpeciesDashboardControl from '~/components/prospecting/SpeciesDashboardControl.vue'
import EpocDashboardControl from '~/components/prospecting/EpocDashboardControl.vue'

export default {
  components: {
    LMap,
    LGeoJson,
    LControl,
    'knowledge-level-control': KnowledgeLevelControl,
    'feature-dashboard-control': FeatureDashboardControl,
    'epoc-dashboard-control': EpocDashboardControl,
    'species-dashboard-control': SpeciesDashboardControl,
  },
  props: {
    selectedArea: {
      type: Object,
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
    currentZoom: 12,
    oldZoomKnowledgeLevel: 100,
    oldZoomSpeciesDistribution: 100,
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
    speciesDistributionGeojson: null,
    epocOdfOfficialGeojson: null,
    epocOdfReserveGeojson: null,
    axiosSourceKnowledgeLevel: null,
    axiosErrorKnowledgeLevel: null,
    axiosSourceSpeciesDistribution: null,
    axiosErrorSpeciesDistribution: null,
    knowledgeLevelIsLoading: false,
    speciesDistributionIsLoading: false,
    selectedSeason: {
      label: 'Toutes saisons',
      value: 'all_period',
      featuresColors: [
        'rgba(51, 105, 80, 0.2)',
        'rgba(51, 105, 80, 0.4)',
        'rgba(51, 105, 80, 0.6)',
        'rgba(51, 105, 80, 0.8)',
        '#336950',
      ],
      speciesDistributionColors: ['#336950'],
    },
    featuresClasses: [0.25, 0.5, 0.75, 1],
    clickedFeature: null,
    searchedFeatureId: null,
    searchedFeatureCode: null,
    clickedEpocPoint: null,
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
        layer.on({
          mouseover: (event) => {
            this.highlightFeature(event)
          },
          mouseout: (event) => {
            this.resetFeatureStyle(event)
          },
          click: (event) => {
            this.clickedEpocPoint = null
            this.clickedFeature = feature
            this.zoomToFeature(event)
          },
        })
      }
    },
    knowledgeLevelGeojsonStyle() {
      let selectedLayer = this.selectedLayer
      let season = this.selectedSeason.value // Nécessaire pour déclencher le changement de style
      return (feature, layer) => {
        selectedLayer = this.selectedLayer
        if (selectedLayer === 'Indice de complétude') {
          season = this.selectedSeason.value // À améliorer
          return {
            weight: 0.8,
            color: '#FFFFFF',
            opacity: 1,
            fillColor: this.setFeatureColor(
              feature.properties[season].percent_knowledge
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
    speciesDistributionGeojsonOptions() {
      return {
        pointToLayer: this.speciesDistributionPointToLayer,
        onEachFeature: this.speciesDistributionOnEachFeature,
      }
    },
    speciesDistributionPointToLayer() {
      return (geojsonPoint, latlng) => {
        return L.circle(latlng, { radius: 4800 })
      }
    },
    speciesDistributionOnEachFeature() {
      return (feature, layer) => {
        layer.on({
          // mouseover: (event) => {
          //   this.highlightFeature(event)
          // },
          // mouseout: (event) => {
          //   this.resetFeatureStyle(event)
          // },
          click: (event) => {
            this.zoomToFeature(event)
          },
        })
      }
    },
    speciesDistributionGeojsonStyle() {
      return (feature, layer) => {
        if (this.selectedSeason.value === 'breeding') {
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
          return {
            weight: 1.4,
            color: this.selectedSeason.speciesDistributionColors[0],
            fillColor: this.selectedSeason.speciesDistributionColors[0],
            fillOpacity: 0.7,
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
    selectedArea(newVal) {
      if (newVal) {
        if (newVal.type_code === 'M10') {
          this.searchedFeatureId = newVal.id
        }
        this.zoomToArea(newVal.bounds)
        this.clickedFeature = null
        this.clickedEpocPoint = null
      }
    },
    selectedSpecies(newVal) {
      if (newVal) {
        this.clickedFeature = null
        this.clickedEpocPoint = null
        this.oldZoomSpeciesDistribution = 101
        this.updateSpeciesDistributionGeojson(newVal)
      }
    },
    selectedLayer(newVal) {
      if (newVal === 'Aucune') {
        this.clickedFeature = null
      }
      this.clickedEpocPoint = null
    },
    selectedSeason(newVal) {
      if (this.selectedSpecies) {
        this.updateSpeciesDistributionGeojson(this.selectedSpecies)
      }
    },
    selectedTerritoryBounds(newVal) {
      this.zoomToTerritory(newVal)
    },
  },
  mounted() {
    // console.log('mounted')
    if (this.$route.query.area && this.$route.query.type) {
      this.$axios
        .$get(
          `/api/v1/lareas/${this.$route.query.type}/${this.$route.query.area}`
        )
        .then((data) => {
          const area = L.geoJSON(data)
          if (this.$route.query.type === 'M10') {
            this.searchedFeatureCode = this.$route.query.area
          }
          this.isProgramaticZoom = true
          this.$refs.myMap.mapObject.fitBounds(area.getBounds())
        })
        .catch((error) => {
          console.log(error)
        })
    }
    if (this.$route.query.species) {
      navigator.geolocation.getCurrentPosition((position) => {
        this.center = [position.coords.latitude, position.coords.longitude]
      })
      this.$axios
        .$get(`/api/v1/search_taxa?cd_nom=${this.$route.query.species}`)
        .then((data) => {
          this.$emit('selectedSpecies', data[0])
        })
        .catch((error) => {
          console.log(error)
        })
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
      this.updateKnowledgeLevelGeojson()
      if (this.currentZoom >= 11) {
        this.updateEpocOdfOfficialGeojson()
        this.updateEpocOdfReserveGeojson()
      }
    },
    updateEnvelope(newBounds) {
      // console.log('[updateEnvelope]')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      this.updateKnowledgeLevelGeojson()
      if (this.currentZoom >= 11) {
        this.updateEpocOdfOfficialGeojson()
        this.updateEpocOdfReserveGeojson()
      }
      if (this.selectedSpecies) {
        this.updateSpeciesDistributionGeojson(this.selectedSpecies)
      }
    },
    updateZoom(newZoom) {
      // console.log('New zoom : ' + newZoom)
      this.currentZoom = newZoom
      if (this.currentZoom < 11) {
        this.clickedFeature = null
        this.clickedEpocPoint = null
      }
    },
    updateKnowledgeLevelGeojson() {
      // console.log('[updateGeojson]')
      // console.log('Ancien zoom : ' + this.oldZoomKnowledgeLevel)
      // console.log('Nouveau zoom : ' + this.currentZoom)
      // console.log(this.axiosSourceKnowledgeLevel)
      if (
        !(
          !this.isProgramaticZoom &&
          this.currentZoom > this.oldZoomKnowledgeLevel &&
          !this.axiosSourceKnowledgeLevel
        )
      ) {
        if (this.axiosSourceKnowledgeLevel) {
          this.axiosSourceKnowledgeLevel.cancel('Resquest has been canceled')
        }
        const cancelToken = this.$axios.CancelToken
        this.axiosSourceKnowledgeLevel = cancelToken.source()
        this.knowledgeLevelIsLoading = true
        this.$axios
          .$get(`/api/v1/area/knowledge_level/M10?envelope=${this.envelope}`, {
            cancelToken: this.axiosSourceKnowledgeLevel.token,
          })
          .then((data) => {
            this.knowledgeLevelGeojson = data
            if (this.searchedFeatureId) {
              const clickedFeature = this.knowledgeLevelGeojson.features.filter(
                (feature) => {
                  return feature.id === this.searchedFeatureId.toString()
                }
              )
              if (clickedFeature.length > 0) {
                this.clickedFeature = clickedFeature[0]
                this.searchedFeatureId = null
              }
            }
            if (this.searchedFeatureCode) {
              const clickedFeature = this.knowledgeLevelGeojson.features.filter(
                (feature) => {
                  return (
                    feature.properties.area_code === this.searchedFeatureCode
                  )
                }
              )
              if (clickedFeature.length > 0) {
                this.clickedFeature = clickedFeature[0]
                this.searchedFeatureCode = null
              }
            }
          })
          .catch((error) => {
            // console.log(error)
            this.axiosErrorKnowledgeLevel = error
          })
          .finally(() => {
            if (!this.axiosErrorKnowledgeLevel) {
              this.axiosSourceKnowledgeLevel = null
              this.knowledgeLevelIsLoading = false
            }
            this.axiosErrorKnowledgeLevel = null
          })
      } else {
        // console.log('Pas de rechargement nécessaire')
      }
      this.oldZoomKnowledgeLevel = this.currentZoom
      this.isProgramaticZoom = false
    },
    updateSpeciesDistributionGeojson(species) {
      // console.log('[updateGeojson]')
      // console.log('Ancien zoom : ' + this.oldZoomSpeciesDistribution)
      // console.log('Nouveau zoom : ' + this.currentZoom)
      // console.log(this.axiosSourceSpeciesDistribution)
      if (
        !(
          !this.isProgramaticZoom &&
          this.currentZoom > this.oldZoomSpeciesDistribution &&
          !this.axiosSourceSpeciesDistribution
        )
      ) {
        if (this.axiosSourceSpeciesDistribution) {
          this.axiosSourceSpeciesDistribution.cancel(
            'Resquest has been canceled'
          )
        }
        const cancelToken = this.$axios.CancelToken
        this.axiosSourceSpeciesDistribution = cancelToken.source()
        this.speciesDistributionIsLoading = true
        this.$axios
          .$get(
            `/api/v1/taxa/${species.code}?period=${this.selectedSeason.value}_new&envelope=${this.envelope}`,
            {
              cancelToken: this.axiosSourceSpeciesDistribution.token,
            }
          )
          .then((data) => {
            this.speciesDistributionGeojson = data
          })
          .catch((error) => {
            // console.log(error)
            this.axiosErrorSpeciesDistribution = error
          })
          .finally(() => {
            if (!this.axiosErrorSpeciesDistribution) {
              this.axiosSourceSpeciesDistribution = null
              this.speciesDistributionIsLoading = false
            }
            this.axiosErrorSpeciesDistribution = null
          })
      } else {
        // console.log('Pas de rechargement nécessaire')
      }
      this.oldZoomSpeciesDistribution = this.currentZoom
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
      const featuresColors = this.selectedSeason.featuresColors
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
          this.selectedLayer === 'Indice de complétude' ? '#FFFFFF' : '#C4C4C4',
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
    deleteSelectedSpecies() {
      this.$emit('selectedSpecies', null)
    },
    deleteClickedEpocPoint() {
      this.clickedEpocPoint = null
    },
  },
}
</script>

<style scoped>
#map-wrap {
  height: calc(100vh - 136px);
}

section.EpocDashboardControl {
  background: #fcfcfc;
  width: 506px;
  max-height: calc(100vh - 156px);
  padding: 16px 0 16px 16px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
}

.FeatureComeBack {
  margin-bottom: 10px;
  display: flex;
  cursor: pointer;
}

.FeatureComeBackIcon {
  width: 12px;
  margin-right: 10px;
}

.FeatureComeBackLabel {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #262626;
}

.EpocGeojsonControl {
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
