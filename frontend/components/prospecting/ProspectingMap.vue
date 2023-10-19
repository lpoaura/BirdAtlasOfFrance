<template>
  <div id="map-wrap">
    <!-- MAP -->
    <l-map
      ref="myMap"
      :zoom="zoom"
      :center="center"
      :options="{ zoomControl: false }"
      style="z-index: 0"
      @ready="initiateEnvelope"
      @update:bounds="updateEnvelope"
      @update:zoom="updateZoom"
      @update:center="updateCenter"
    >
      <!-- LAYERS -->
      <!-- v-if="['none', 'epoc'].includes(selectedLayer.value) && plan.isOn" -->
      <l-tile-layer
        v-if="plan.isOn"
        :url="plan.url"
        :opacity="Number(plan.opacity) / 100"
        :z-index="plan.zIndex"
        :attribution="plan.attribution"
      />
      <!-- v-if="['none', 'epoc'].includes(selectedLayer.value) && orthophoto.isOn" -->
      <l-tile-layer
        v-if="orthophoto.isOn"
        :url="orthophoto.url"
        :opacity="Number(orthophoto.opacity) / 100"
        :z-index="orthophoto.zIndex"
        :attribution="orthophoto.attribution"
      />
      <!-- <l-wms-tile-layer
        :key="clcWms.name"
        :base-url="clcWms.url"
        :layers="clcWms.layers"
        :name="clcWms.name"
        :z-index="3"
        :attribution="clcWms.attribution"
        format="image/png"
        layer-type="base"
      >
      </l-wms-tile-layer> -->
      <!-- v-if="!['none', 'epoc'].includes(selectedLayer.value) || (['none', 'epoc'].includes(selectedLayer.value) && !plan.isOn && !orthophoto.isOn)" -->
      <l-tile-layer
        v-if="!plan.isOn && !orthophoto.isOn"
        :url="osmUrl"
        :attribution="'© les contributeurs d’OpenStreetMap'"
      />
      <!-- GEOJSON -->
      <l-geo-json
        v-if="currentZoom <= 8"
        :geojson="territoriesGeojson"
        :options-style="territoriesGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedSpecies &&
          selectedLayer.value === 'species-distribution' &&
          speciesDistributionGeojson
        "
        :geojson="speciesDistributionGeojson"
        :options="speciesDistributionGeojsonOptions"
        :options-style="speciesDistributionGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer.value === 'knowledge-level' ||
          selectedLayer.value === 'species-number' ||
          (selectedLayer.value === 'epoc' && currentZoom >= 9)
        "
        :geojson="knowledgeLevelGeojson"
        :options="knowledgeLevelGeojsonOptions"
        :options-style="knowledgeLevelGeojsonStyle"
      />
      <l-geo-json
        v-if="
          selectedLayer.value === 'epoc' &&
          epocRealizedIsOn &&
          currentZoom >= 11
        "
        :geojson="epocRealizedGeojson"
        :options="epocRealizedGeojsonOptions"
      />
      <l-geo-json
        v-if="selectedLayer.value === 'epoc' && epocOdfIsOn && currentZoom >= 9"
        :geojson="epocOdfGeojson"
        :options="epocOdfGeojsonOptions"
      />
      <!-- MAP CONTROLS -->
      <!-- Top left -->
      <l-control position="topleft" :disable-scroll-propagation="true">
        <prospecting-knowledge-level-control
          v-show="selectedLayer.value === 'knowledge-level' && !clickedFeature"
          :current-territory="currentTerritory"
          :selected-season="selectedSeason"
        />
        <prospecting-count-taxa-control
          v-show="selectedLayer.value === 'species-number' && !clickedFeature"
          :current-territory="currentTerritory"
          :count-taxa-classes="countTaxaClasses"
          :selected-season="selectedSeason"
        />
        <prospecting-feature-dashboard-control
          v-if="
            ['knowledge-level', 'species-number', 'epoc'].includes(
              selectedLayer.value
            ) &&
            clickedFeature &&
            !clickedEpocPoint
          "
          :clicked-feature="clickedFeature"
          :selected-season="selectedSeason"
        />
        <prospecting-species-dashboard-control
          v-if="
            selectedLayer.value === 'species-distribution' && selectedSpecies
          "
          :selected-species="selectedSpecies"
          :selected-season="selectedSeason"
          @selectedSpecies="deleteSelectedSpecies"
        />
        <section
          v-if="selectedLayer.value === 'epoc' && clickedEpocPoint"
          class="MapControl"
        >
          <div
            v-if="clickedFeature"
            class="MapControlComeBack"
            @click="deleteClickedEpocPoint"
          >
            <img class="MapControlComeBackIcon" src="/previous.svg" />
            <span class="fw-500">{{
              clickedFeature.properties.area_name
            }}</span>
          </div>
          <prospecting-epoc-dashboard-control
            :clicked-epoc-point="clickedEpocPoint"
          />
        </section>
        <!-- Apparaît si au moins une des conditions précédentes est remplie -->
        <div
          v-show="
            (selectedLayer.value === 'knowledge-level' && !clickedFeature) ||
            (selectedLayer.value === 'species-number' && !clickedFeature) ||
            (['knowledge-level', 'species-number', 'epoc'].includes(
              selectedLayer.value
            ) &&
              clickedFeature &&
              !clickedEpocPoint) ||
            (selectedLayer.value === 'species-distribution' &&
              selectedSpecies) ||
            (selectedLayer.value === 'epoc' && clickedEpocPoint)
          "
          class="MiniMapControl mobile"
          @click="openMobileMapControl"
        >
          <img class="Icon" src="/information.svg" />
        </div>
      </l-control>
      <!-- Top right -->
      <l-control position="topright" :disable-scroll-propagation="true">
        <commons-map-loading-control
          :loading="
            (knowledgeLevelIsLoading &&
              ['knowledge-level', 'species-number'].includes(
                selectedLayer.value
              )) ||
            (speciesDistributionIsLoading &&
              selectedLayer.value === 'species-distribution')
          "
        />

        <div
          v-show="
            selectedLayer.value === 'epoc' &&
            currentZoom < 11 &&
            currentZoom >= 9
          "
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Trop de points EPOC réalisés, zoomez à l’échelle d’une maille pour
            visualiser ces points.
          </h5>
        </div>
        <div
          v-show="selectedLayer.value === 'epoc' && currentZoom < 9"
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Trop de points à afficher, zoomez à l’échelle d’une maille pour
            visualiser les points EPOC.
          </h5>
        </div>
        <div
          v-show="
            !speciesDistributionIsLoading &&
            noSpeciesData &&
            selectedLayer.value === 'species-distribution'
          "
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Pas de données pour la saison et l'emprise choisies.
          </h5>
        </div>
        <div class="MapSelectors">
          <div v-click-outside="closeSeasonsBox" class="MapSelectorWrapper">
            <div
              class="MiniMapControl"
              :class="seasonIsOpen ? 'selected' : ''"
              @click="openOrCloseSeasonsBox"
            >
              <img class="Icon" src="/calendar.svg" />
            </div>
            <commons-selectors-seasons
              :select-is-open="seasonIsOpen"
              :selected-season="selectedSeason"
              @selectedSeason="updateSelectedSeason"
            />
          </div>
          <div v-click-outside="closeLayersBox" class="MapSelectorWrapper">
            <div
              class="MiniMapControl"
              :class="layerIsOpen ? 'selected' : ''"
              @click="openOrCloseLayersBox"
            >
              <img class="Icon" src="/layers.svg" />
            </div>
            <commons-selectors-layers
              :select-is-open="layerIsOpen"
              :selected-layer="selectedLayer"
              :selected-species="selectedSpecies"
              @selectedLayer="updateSelectedLayer"
              @epocRealizedIsOn="updateEpocRealized"
              @epocOdfIsOn="updateEpocOdf"
              @planIsOn="updatePlan"
              @planOpacity="updatePlanOpacity"
              @orthophotoIsOn="updateOrthophoto"
              @orthophotoOpacity="updateOrthophotoOpacity"
            />
          </div>
          <div v-click-outside="closeTerritoriesBox" class="MapSelectorWrapper">
            <div
              class="MiniMapControl"
              :class="territoryIsOpen ? 'selected' : ''"
              @click="openOrCloseTerritoriesBox"
            >
              <img class="Icon" src="/location.svg" />
            </div>
            <commons-selectors-territories
              :select-is-open="territoryIsOpen"
              :selected-territory="selectedTerritory"
              @selectedTerritory="updateSelectedTerritory"
            />
          </div>
        </div>
      </l-control>
      <!-- Bottom left -->
      <l-control position="bottomleft">
        <div
          v-show="
            (knowledgeLevelIsLoading &&
              ['knowledge-level', 'species-number'].includes(
                selectedLayer.value
              )) ||
            (speciesDistributionIsLoading &&
              selectedLayer.value === 'species-distribution')
          "
          class="InformationControl"
          style="position: relative"
        >
          <div class="Progress"></div>
          <h5 class="black02 fw-500 bottom-margin-38">
            Chargement des données
          </h5>
        </div>
        <div
          v-show="
            selectedLayer.value === 'epoc' &&
            currentZoom < 11 &&
            currentZoom >= 9
          "
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Trop de points EPOC réalisés, zoomez à l’échelle d’une maille pour
            visualiser ces points.
          </h5>
        </div>
        <div
          v-show="selectedLayer.value === 'epoc' && currentZoom < 9"
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Trop de points à afficher, zoomez à l’échelle d’une maille pour
            visualiser les points EPOC.
          </h5>
        </div>
        <div
          v-show="
            !speciesDistributionIsLoading &&
            noSpeciesData &&
            selectedLayer.value === 'species-distribution'
          "
          class="InformationControl"
        >
          <h5 class="black02 fw-500">
            Pas de données pour la saison et l'emprise choisies.
          </h5>
        </div>
      </l-control>
      <!-- Bottom right -->
      <l-control-zoom position="bottomright"></l-control-zoom>
      <l-control position="bottomright">
        <div class="MiniMapControl" @click="geolocate">
          <img class="Icon" src="/geolocation.svg" />
        </div>
      </l-control>
    </l-map>
  </div>
</template>

<script>
export default {
  props: {
    selectedArea: {
      // Zonage sélectionné dans la barre de recherche
      type: Object,
      required: false,
      default: null,
    },
    selectedSpecies: {
      // Espèce sélectionnée dans la barre de recherche
      type: Object,
      required: false,
      default: null,
    },
    selectedSeason: {
      // Saison sélectionnée
      type: Object,
      required: true,
    },
    selectedLayer: {
      // Couche sélectionnée
      type: Object,
      required: true,
    },
    selectedTerritory: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    currentTerritory: {
      // Territoire sur lequel est centrée la carte (peut être non défini)
      type: Object,
      required: true,
    },
    countTaxaClasses: {
      // Classes pour la couche "Nb d'espèces par maille"
      type: Object,
      required: true,
    },
    clickedFeature: {
      // On clique sur une maille
      type: Object,
      required: false,
      default: null,
    },
    clickedEpocPoint: {
      // On clique sur un point EPOC
      type: Object,
      required: false,
      default: null,
    },
    epocRealizedIsOn: {
      type: Boolean,
      required: true,
    },
    epocOdfIsOn: {
      type: Boolean,
      required: true,
    },
    plan: {
      type: Object,
      required: true,
    },
    orthophoto: {
      type: Object,
      required: true,
    },
    // MOBILE
    mobileMapControlIsOpen: {
      type: Boolean,
      required: true,
    },
  },
  data: () => ({
    // CONFIGURATION DE LA CARTE
    zoom: 11,
    currentZoom: 11,
    oldZoomKnowledgeLevel: 100,
    oldZoomSpeciesDistribution: 100,
    isProgramaticZoom: false,
    center: [48.85341, 2.3488],
    bounds: null,
    // url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    osmUrl:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    envelope: null,
    // CONFIGURATION DES GEOJSON
    // Limites des territoires
    territoriesGeojson: null,
    // Emprises des territoires
    territoriesEnvelopes: null,
    // Indice de complétude
    knowledgeLevelGeojson: null,
    axiosSourceKnowledgeLevel: null,
    axiosErrorKnowledgeLevel: null,
    knowledgeLevelIsLoading: false,
    // Répartition de l'espèce
    speciesDistributionGeojson: null,
    axiosSourceSpeciesDistribution: null,
    axiosErrorSpeciesDistribution: null,
    speciesDistributionIsLoading: false,
    // Points EPOC
    epocRealizedGeojson: null,
    epocOdfGeojson: null,
    // CONFIGURATION DES MAPCONTROLS
    noSpeciesData: false,
    knowledgeLevelClasses: [0, 0.25, 0.5, 0.75, 1],
    searchedFeatureId: null, // Le zonage sélectionné est une maille (recherche depuis la carte de Prospection)
    searchedFeatureCode: null, // Le zonage sélectionné est une maille (recherche depuis l'URL)
    // MOBILE
    seasonIsOpen: false,
    layerIsOpen: false,
    territoryIsOpen: false,
  }),
  computed: {
    territoriesGeojsonStyle() {
      return {
        weight: 2,
        color: '#262626',
        opacity: 1,
        fillOpacity: 0,
        interactive: false,
      }
    },
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
            this.$emit('clickedEpocPoint', null)
            this.$emit('clickedFeature', JSON.parse(JSON.stringify(feature)))
            this.zoomToFeature(event)
            this.openMobileMapControl()
          },
        })
      }
    },
    knowledgeLevelGeojsonStyle() {
      let selectedLayer = this.selectedLayer
      let season = this.selectedSeason.value // Nécessaire pour déclencher le changement de style
      return (feature, layer) => {
        selectedLayer = this.selectedLayer
        if (selectedLayer.value === 'knowledge-level') {
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
        }
        if (selectedLayer.value === 'species-number') {
          season = this.selectedSeason.value // À améliorer
          return {
            weight: 0.8,
            color: '#FFFFFF',
            opacity: 1,
            fillColor: this.setFeatureColor(
              feature.properties[season].new_count
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
        return this.$L.circle(latlng, {
          radius: geojsonPoint.properties.radius || 4800,
        })
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
            this.updateSpeciesDistributionGeojson(this.selectedSpecies)
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
    epocRealizedGeojsonOptions() {
      return {
        pointToLayer: this.epocRealizedPointToLayer,
        onEachFeature: this.epocRealizedOnEachFeature,
      }
    },
    epocRealizedPointToLayer() {
      return (geojsonPoint, latlng) => {
        const epocRealizedIcon = new this.$L.Icon({
          iconUrl:
            geojsonPoint.properties.project_code === 'EPOC'
              ? '/prospecting/epoc-realized.svg'
              : '/prospecting/epoc-ODF-realized.svg',
          iconSize: [32, 39],
          iconAnchor: [16, 35.5],
        })
        return this.$L.marker(latlng, {
          icon: epocRealizedIcon,
        })
      }
    },
    epocRealizedOnEachFeature() {
      return (feature, layer) => {
        layer.bindTooltip(
          `${feature.properties.project_code.replace('-', ' ')} réalisé`,
          {
            direction: 'right',
            offset: [14, -18],
            permanent: false,
            opacity: 1,
            className: 'LeafletTooltip',
          }
        )
        layer.on({
          click: (event) => {
            this.$emit('clickedEpocPoint', feature)
            this.openMobileMapControl()
          },
        })
      }
    },
    epocOdfGeojsonOptions() {
      return {
        pointToLayer: this.epocOdfPointToLayer,
        onEachFeature: this.epocOdfOnEachFeature,
      }
    },
    epocOdfPointToLayer() {
      return (geojsonPoint, latlng) => {
        const epocOdfIcon = new this.$L.Icon({
          iconUrl:
            geojsonPoint.properties.status === 'Officiel'
              ? '/prospecting/epoc-ODF-Official.svg'
              : '/prospecting/epoc-ODF-Reserve.svg',
          iconSize: [32, 39],
          iconAnchor: [16, 35.5],
        })
        return this.$L.marker(latlng, {
          icon: epocOdfIcon,
        })
      }
    },
    epocOdfOnEachFeature() {
      return (feature, layer) => {
        layer.bindTooltip(
          `EPOC ODF ${
            feature.properties.status === 'Officiel' ? 'officiel' : 'de réserve'
          }`,
          {
            direction: 'right',
            offset: [14, -18],
            permanent: false,
            opacity: 1,
            className: 'LeafletTooltip',
          }
        )
        layer.on({
          click: (event) => {
            this.$emit('clickedEpocPoint', feature)
            this.openMobileMapControl()
          },
        })
      }
    },
  },
  watch: {
    selectedArea(newVal) {
      if (newVal) {
        if (newVal.type_code === 'ATLAS_GRID') {
          // Pouvoir afficher le tableau de bord si c'est une maille qui est sélectionnée
          this.searchedFeatureId = newVal.id
        }
        this.zoomToArea(newVal.bounds)
        this.$emit('clickedFeature', null)
        this.$emit('clickedEpocPoint', null)
      }
    },
    selectedSpecies(newVal) {
      if (newVal) {
        this.$emit('clickedFeature', null)
        this.$emit('clickedEpocPoint', null)
        this.oldZoomSpeciesDistribution = 101
        this.updateSpeciesDistributionGeojson(newVal)
      }
    },
    selectedSeason(newVal) {
      if (this.selectedSpecies) {
        this.updateSpeciesDistributionGeojson(this.selectedSpecies)
      }
    },
    selectedLayer(newVal) {
      if (newVal.value === 'none') {
        this.$emit('clickedFeature', null)
      }
      this.$emit('clickedEpocPoint', null)
    },
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
    },
  },
  beforeMount() {
    if (this.$detectMobile()) {
      // First we get the viewport height and we multiple it by 1% to get a value for a vh unit
      const vh = window.innerHeight * 0.01
      // Then we set the value in the --vh custom property to the root of the document
      document.documentElement.style.setProperty('--vh', `${vh}px`)
      window.addEventListener('resize', this.listener)
    }
  },
  mounted() {
    // console.debug('mounted')
    if (this.$route.query.area && this.$route.query.type) {
      this.$axios
        .$get(
          `/api/v1/lareas/${this.$route.query.type}/${this.$route.query.area}`
        )
        .then((data) => {
          if (this.$route.query.type === 'ATLAS_GRID') {
            this.searchedFeatureCode = this.$route.query.area
          }
          const area = this.$L.geoJSON(data)
          this.isProgramaticZoom = true
          this.$refs.myMap.mapObject.fitBounds(area.getBounds())
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
    } else {
      if (navigator.geolocation) {
        // La géolocalisation est supportée par le navigateur
        navigator.geolocation.getCurrentPosition(
          this.setGeolocation,
          this.catchGeolocationError
        )
      } else {
        const params = {
          coordinates: [2.3488, 48.85341].toString(),
          type_code: 'ATLAS_TERRITORY',
          bbox: true,
          only_enable: true,
        }
        // La géolocalisation N'EST PAS supportée par le navigateur
        this.$axios
          .$get('/api/v1/lareas/position', { params })
          .then((data) => {
            const territory = this.$L.geoJSON(data)
            this.isProgramaticZoom = true
            this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
      }
      if (this.$route.query.species) {
        this.$axios
          .$get(`/api/v1/search/taxa?cd_nom=${this.$route.query.species}`)
          .then((data) => {
            this.$emit('selectedSpecies', data[0])
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
      }
    }
    this.$axios
      .$get('/api/v1/lareas/type/ATLAS_TERRITORY_SIMPLIFY', {
        params: {
          bbox: false,
          only_enable: true,
        },
      })
      .then((data) => {
        this.territoriesGeojson = data
      })
      .catch((error) => {
        console.debug(`${error}`)
      })
    this.$axios
      .$get('/api/v1/lareas/type/ATLAS_TERRITORY_SIMPLIFY', {
        params: {
          bbox: true,
          only_enable: true,
        },
      })
      .then((data) => {
        this.territoriesEnvelopes = data
      })
      .catch((error) => {
        console.debug(`${error}`)
      })
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.listener)
  },
  methods: {
    setGeolocation(position) {
      this.isProgramaticZoom = true
      this.center = [position.coords.latitude, position.coords.longitude]
    },
    catchGeolocationError() {
      // Si l'utilisateur a désactivé la géolocalisation (ou tout autre problème), alors on centre sur la France métropolitaine
      this.$axios
        .$get(
          '/api/v1/lareas/position?coordinates=2.3488,48.85341&type_code=ATLAS_TERRITORY&bbox=true&only_enable=true'
        )
        .then((data) => {
          const territory = this.$L.geoJSON(data)
          this.isProgramaticZoom = true
          this.$refs.myMap.mapObject.fitBounds(territory.getBounds())
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
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
      // console.debug('[initiateEnvelope]')
      const initBounds = this.$refs.myMap.mapObject.getBounds()
      this.bounds = initBounds
      this.envelope = this.defineEnvelope(initBounds)
      this.updateCenter({ lat: this.center[0], lng: this.center[1] })
      this.updateKnowledgeLevelGeojson()
      if (this.currentZoom >= 11) {
        this.updateEpocRealizedGeojson()
      }
      if (this.currentZoom >= 9) {
        this.updateEpocOdfGeojson()
      }
    },
    updateEnvelope(newBounds) {
      // console.debug('[updateEnvelope]')
      this.bounds = newBounds
      this.envelope = this.defineEnvelope(newBounds)
      this.updateKnowledgeLevelGeojson()
      if (this.currentZoom >= 11) {
        this.updateEpocRealizedGeojson()
      }
      if (this.currentZoom >= 9) {
        this.updateEpocOdfGeojson()
      }
      if (this.selectedSpecies) {
        this.updateSpeciesDistributionGeojson(this.selectedSpecies)
      }
    },
    updateZoom(newZoom) {
      // console.debug('Old zoom : ' + this.currentZoom)
      // console.debug('New zoom : ' + newZoom)
      this.currentZoom = newZoom
      if (this.currentZoom < 11) {
        this.$emit('clickedFeature', null)
        this.$emit('clickedEpocPoint', null)
      }
    },
    updateCenter(newCenter) {
      this.$axios
        .$get(
          `/api/v1/lareas/position?coordinates=${newCenter.lng},${newCenter.lat}&type_code=ATLAS_TERRITORY&bbox=true&only_enable=true`
        )
        .then((data) => {
          if (
            data && // console.debug('[updateGeojson]')
            // console.debug('Ancien zoom : ' + this.oldZoomSpeciesDistribution)
            // console.debug('Nouveau zoom : ' + this.currentZoom)
            // console.debug(this.axiosSourceSpeciesDistribution)
            data.properties.area_code !== this.currentTerritory.area_code
          ) {
            this.$emit('currentTerritory', {
              id: data.id,
              area_code: data.properties.area_code,
              area_name: data.properties.area_name,
            })
          }
          if (!data && this.currentTerritory.area_code) {
            this.$emit('currentTerritory', {
              id: null,
              area_code: null,
              area_name: null,
            })
          }
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
    },
    updateKnowledgeLevelGeojson() {
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
        const params = {
          envelope: this.envelope ? this.envelope.toString() : null,
        }
        this.$axios
          .$get(`/api/v1/area/knowledge_level/ATLAS_GRID`, {
            cancelToken: this.axiosSourceKnowledgeLevel.token,
            params,
          })
          .then((data) => {
            if (data) {
              this.knowledgeLevelGeojson = data
              // Pouvoir afficher le tableau de bord si c'est une maille qui est sélectionnée
              if (this.searchedFeatureId) {
                const clickedFeature =
                  this.knowledgeLevelGeojson.features.filter((feature) => {
                    return feature.id === this.searchedFeatureId.toString()
                  })
                if (clickedFeature.length > 0) {
                  this.$emit('clickedFeature', clickedFeature[0])
                  this.openMobileMapControl()
                  this.searchedFeatureId = null
                }
              }
              if (this.searchedFeatureCode) {
                const clickedFeature =
                  this.knowledgeLevelGeojson.features.filter((feature) => {
                    return (
                      feature.properties.area_code === this.searchedFeatureCode
                    )
                  })
                if (clickedFeature.length > 0) {
                  this.$emit('clickedFeature', clickedFeature[0])
                  this.openMobileMapControl()
                  this.searchedFeatureCode = null
                }
              }
            } else {
              this.knowledgeLevelGeojson = {
                type: 'FeatureCollection',
                features: [],
              }
            }
          })
          .catch((error) => {
            // console.debug(`${error}`)
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
        // console.debug('Pas de rechargement nécessaire')
      }
      this.oldZoomKnowledgeLevel = this.currentZoom
      this.isProgramaticZoom = false
    },
    updateSpeciesDistributionGeojson(species) {
      if (
        !(
          !this.isProgramaticZoom &&
          this.currentZoom > this.oldZoomSpeciesDistribution &&
          this.currentZoom !== 11 &&
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
        this.noSpeciesData = false
        const grid = this.currentZoom >= 11
        const params = {
          cd_nom: species.code,
          phenology_period: this.selectedSeason.value,
          atlas_period: 'new',
          grid,
          envelope: this.envelope ? this.envelope.toString() : null,
        }
        this.$axios
          .$get(`/api/v1/taxa/map/distribution`, {
            cancelToken: this.axiosSourceSpeciesDistribution.token,
            params,
          })
          .then((data) => {
            if (data && data.features) {
              this.speciesDistributionGeojson = data
            } else {
              this.speciesDistributionGeojson = {
                type: 'FeatureCollection',
                features: [],
              }
              this.noSpeciesData = true
            }
          })
          .catch((error) => {
            // console.debug(`${error}`)
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
        // console.debug('Pas de rechargement nécessaire')
      }
      this.oldZoomSpeciesDistribution = this.currentZoom
      this.isProgramaticZoom = false
    },
    updateEpocRealizedGeojson() {
      const params = {
        envelope: this.envelope ? this.envelope.toString() : null,
      }
      this.$axios
        .$get(`/api/v1/epoc/realized`, { params })
        .then((data) => {
          if (data) {
            this.epocRealizedGeojson = data
          } else {
            this.epocRealizedGeojson = {
              type: 'FeatureCollection',
              features: [],
            }
          }
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
    },
    updateEpocOdfGeojson() {
      const params = {
        envelope: this.envelope ? this.envelope.toString() : null,
      }
      this.$axios
        .$get(`/api/v1/epoc`, { params })
        .then((data) => {
          if (data) {
            this.epocOdfGeojson = data
          } else {
            this.epocOdfGeojson = { type: 'FeatureCollection', features: [] }
          }
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
    },
    setFeatureColor(number) {
      const featuresColors = this.selectedSeason.featuresColors
      if (this.selectedLayer.value === 'knowledge-level') {
        return number >= this.knowledgeLevelClasses[4]
          ? featuresColors[5]
          : number >= this.knowledgeLevelClasses[3]
          ? featuresColors[4]
          : number >= this.knowledgeLevelClasses[2]
          ? featuresColors[3]
          : number >= this.knowledgeLevelClasses[1]
          ? featuresColors[2]
          : featuresColors[1]
      }
      if (this.selectedLayer.value === 'species-number') {
        if (this.countTaxaClasses.all_period.length > 0) {
          return number >=
            this.countTaxaClasses[this.selectedSeason.value][4].min
            ? featuresColors[5]
            : number >= this.countTaxaClasses[this.selectedSeason.value][3].min
            ? featuresColors[4]
            : number >= this.countTaxaClasses[this.selectedSeason.value][2].min
            ? featuresColors[3]
            : number >= this.countTaxaClasses[this.selectedSeason.value][1].min
            ? featuresColors[2]
            : number > 0
            ? featuresColors[1]
            : featuresColors[0]
        } else {
          return featuresColors[0]
        }
      }
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
        color: ['knowledge-level', 'species-number'].includes(
          this.selectedLayer.value
        )
          ? '#FFFFFF'
          : '#C4C4C4',
      })
    },
    geolocate() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const center = this.$L.latLng(
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
          this.$emit('clickedFeature', null)
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
    deleteSelectedSpecies() {
      this.$emit('selectedSpecies', null)
    },
    deleteClickedEpocPoint() {
      this.$emit('clickedEpocPoint', null)
    },
    // MOBILE
    openMobileMapControl() {
      this.$emit('mobileMapControl', true)
    },
    openOrCloseSeasonsBox() {
      this.seasonIsOpen = !this.seasonIsOpen
      console.info('this.seasonIsOpen', this.seasonIsOpen)
    },
    closeSeasonsBox() {
      this.seasonIsOpen = false
    },
    updateSelectedSeason(season) {
      this.$emit('selectedSeason', season)
      this.seasonIsOpen = false
    },
    openOrCloseLayersBox() {
      this.layerIsOpen = !this.layerIsOpen
    },
    closeLayersBox() {
      this.layerIsOpen = false
    },
    updateSelectedLayer(layer) {
      this.$emit('selectedLayer', layer)
    },
    updateEpocRealized(value) {
      this.$emit('epocRealizedIsOn', value)
    },
    updateEpocOdf(value) {
      this.$emit('epocOdfIsOn', value)
    },
    updatePlan(value) {
      this.$emit('planIsOn', value)
    },
    updatePlanOpacity(value) {
      this.$emit('planOpacity', value)
    },
    updateOrthophoto(value) {
      this.$emit('orthophotoIsOn', value)
    },
    updateOrthophotoOpacity(value) {
      this.$emit('orthophotoOpacity', value)
    },
    openOrCloseTerritoriesBox() {
      this.territoryIsOpen = !this.territoryIsOpen
    },
    closeTerritoriesBox() {
      this.territoryIsOpen = false
    },
    updateSelectedTerritory(territory) {
      this.$emit('selectedTerritory', territory)
      this.territoryIsOpen = false
    },
    listener() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      const vh = window.innerHeight * 0.01
      document.documentElement.style.setProperty('--vh', `${vh}px`)
    },
  },
}
</script>

<style scoped>
#map-wrap {
  height: calc(100vh - 136px);
  height: calc(calc(var(--vh, 1vh) * 100) - 136px);
}
</style>
