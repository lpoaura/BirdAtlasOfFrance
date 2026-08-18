<template>
  <v-container fluid class="fill-height">
    <v-col v-if="!hasData" class="no-data-info">Aucune donnée disponible pour ce territoire et cette période</v-col>
    <v-row v-if="hasData" class="fill-height ma-0">
      <v-col ref="mapBlock" cols="9" xs="12" sm="12" md="8">
        <commons-map-loading-control
          class="float-right"
          :loading="dataLoading"
        />
        <div id="map"></div>
        <div v-if="mapData.years.length > 1" class="temporal-control px-4 pb-4">
          <div class="temporal-control-header">
            <span class="black02 fw-500">Période affichée</span>
            <span class="black03 temporal-year">{{ selectedYear }}</span>
          </div>
          <div class="temporal-slider-wrapper">
            <div class="temporal-slider-track">
              <input
                type="range"
                class="temporal-slider"
                :min="0"
                :max="mapData.years.length - 1"
                :value="selectedYearIndex"
                :style="sliderTrackStyle"
                step="1"
                @input="onYearIndexChange($event.target.value)"
              />
              <div class="temporal-track-dots" aria-hidden="true">
                <button
                  v-for="(year, index) in mapData.years"
                  :key="`dot-${year}-${index}`"
                  type="button"
                  class="temporal-track-dot"
                  :class="{ active: index === selectedYearIndex }"
                  :style="getTickStyle(index)"
                  :title="year"
                  tabindex="-1"
                  @click="onYearIndexChange(index)"
                />
              </div>
            </div>
            <div class="temporal-labels">
              <span
                v-for="(year, index) in mapData.years"
                v-show="shouldShowYearLabel(index)"
                :key="`label-${year}-${index}`"
                class="temporal-tick-label"
                :class="{ active: index === selectedYearIndex }"
                :style="getTickStyle(index)"
              >
                {{ year }}
              </span>
            </div>
          </div>
        </div>
      </v-col>
      <v-col
        v-if="mapData"
        id="legend"
        class="align-stretch pa-0"
        cols="3"
        xs="12"
        sm="12"
        md="4"
      >
        <div id="legend-title" class="pa-5 black02 fw-bold">Légende</div>

        <div class="legend-body pa-5">
          <p class="legend-section-title black02 fw-500 mb-3">
            {{ presenceLegendTitle }}
          </p>
          <p v-if="legendInfo.unit" class="legend-unit black02 mb-3">
            {{ legendInfo.unit }}
          </p>
          <div
            v-if="legendInfo.unit"
            class="legend-gradient mb-2"
            :style="{ background: legendInfo.gradient }"
          />
          <div v-if="legendInfo.unit" class="legend-scale black03 mb-4">
            <span>{{ legendInfo.min }}</span>
            <span>{{ legendInfo.max }}</span>
          </div>
          <p class="legend-absence black02">
            <span class="float-left pr-5"
              ><svg
                width="22"
                height="22"
                viewBox="0 0 22 22"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M0.435809 4.38514C0.773309 2.36015 2.36015 0.773309 4.38514 0.435809C6.12541 0.145766 7.88666 0 9.65092 0H12.3491C14.1133 0 15.8746 0.145766 17.6149 0.435809C19.6399 0.773309 21.2267 2.36015 21.5642 4.38514C21.8542 6.12541 22 7.88666 22 9.65092V12.3491C22 14.1133 21.8542 15.8746 21.5642 17.6149C21.2267 19.6399 19.6399 21.2267 17.6149 21.5642C15.8746 21.8542 14.1133 22 12.3491 22H9.65092C7.88666 22 6.12541 21.8542 4.38514 21.5642C2.36015 21.2267 0.773309 19.6399 0.435809 17.6149C0.145766 15.8746 0 14.1133 0 12.3491V9.65092C0 7.88666 0.145766 6.12541 0.435809 4.38514Z"
                  fill="#CFCBD1"
                /></svg></span
            >Département où l'espèce est absente.
          </p>
          <div v-if="dataSources.length" class="legend-sources">
            <p
              v-for="(source, index) in dataSources"
              :key="index"
              class="legend-source black03 mb-0"
            >
              Source des données : {{ source }}
            </p>
          </div>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
const d3 = require('d3')

const UNIT_DISPLAY_ORDER = [
  'Couples territoriaux',
  'Couples reproducteurs',
  'Couples producteurs',
  "Jeunes à l'envol",
  "Nombre d'individus",
]
const PRIORITY_UNITS = UNIT_DISPLAY_ORDER

export default {
  data: () => ({
    mapData: null,
    apiRequestController: null,
    dataLoading: false,
    selectedYearIndex: 0,
    legendInfo: {
      unit: null,
      min: null,
      max: null,
      gradient: null,
    },
    dataSources: [],
    colorScale: null,
    gradientUnit: null,
    colors: {
      all_period: '#39765A',
      wintering: '#4C61F4',
      breeding: '#E65784',
    },
    width: 0,
    height: 0,
  }),
  computed: {
    idArea() {
      return this.$store.state.species.selectedTerritory.id_area
    },
    cdNom() {
      return this.$store.state.species.cdNom
    },
    selectedSeason() {
      return this.$store.state.species.selectedSeason
    },
    selectedYear() {
      return this.mapData?.years?.[this.selectedYearIndex] || null
    },
    hasData() {
      if (!this.mapData?.years?.length) return false
      return this.mapData.features.some(
        (feature) =>
          feature.properties?.data_by_year &&
          Object.keys(feature.properties.data_by_year).length > 0
      )
    },
    presenceLegendTitle() {
      const labels = {
        all_period: "Département où l'espèce est présente",
        breeding: "Département où l'espèce se reproduit",
        wintering: "Département où l'espèce hiverne",
      }
      return labels[this.selectedSeason.value] || labels.all_period
    },
    sliderTrackStyle() {
      const yearsCount = this.mapData?.years?.length || 0
      if (yearsCount <= 1) {
        return { '--slider-progress': '100%' }
      }
      const progress = (this.selectedYearIndex / (yearsCount - 1)) * 100
      return { '--slider-progress': `${progress}%` }
    },
    yearLabelStep() {
      const yearsCount = this.mapData?.years?.length || 0
      if (yearsCount <= 8) return 1
      if (yearsCount <= 16) return 2
      return 3
    },
  },
  watch: {
    idArea: {
      handler() {
        this.generateMap()
      },
    },
    selectedSeason: {
      handler() {
        this.generateMap()
      },
    },
  },
  mounted() {
    this.$nextTick(function () {
      this.generateMap()
    })
    window.addEventListener('resize', this.generateMap)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.generateMap)
  },
  methods: {
    generateMap() {
      this.getMapData().then(() => {
        d3.select('#map').selectAll('svg').remove()
        if (this.hasData) {
          this.selectedYearIndex = this.mapData.years.length - 1
          this.renderMap()
        } else {
          this.resetLegend()
        }
      })
    },
    resetLegend() {
      this.legendInfo = { unit: null, min: null, max: null, gradient: null }
      this.dataSources = []
      this.colorScale = null
      this.gradientUnit = null
    },
    onYearIndexChange(value) {
      this.selectedYearIndex = Number(value)
      this.updateMapForYear()
    },
    getTickStyle(index) {
      const lastIndex = this.mapData.years.length - 1
      if (lastIndex <= 0) {
        return { left: '0%' }
      }
      const thumbOffset = 6
      const trackRatio = index / lastIndex
      const left = `calc(${trackRatio * 100}% + ${thumbOffset - trackRatio * thumbOffset * 2}px)`
      return { left }
    },
    shouldShowYearLabel(index) {
      const yearsCount = this.mapData.years.length
      if (index === 0 || index === yearsCount - 1) return true
      if (index === this.selectedYearIndex) return true
      return index % this.yearLabelStep === 0
    },
    getYearData(properties) {
      if (!properties?.data_by_year || !this.selectedYear) return null
      const yearData = properties.data_by_year[this.selectedYear] || null
      return this.sortYearDataByUnit(yearData)
    },
    sortYearDataByUnit(yearData) {
      if (!yearData?.length) return yearData
      return [...yearData].sort((a, b) => {
        const indexA = UNIT_DISPLAY_ORDER.indexOf(a[0])
        const indexB = UNIT_DISPLAY_ORDER.indexOf(b[0])
        const orderA = indexA === -1 ? UNIT_DISPLAY_ORDER.length : indexA
        const orderB = indexB === -1 ? UNIT_DISPLAY_ORDER.length : indexB
        if (orderA !== orderB) return orderA - orderB
        return String(a[0]).localeCompare(String(b[0]), 'fr')
      })
    },
    parseSurveyValue(valueStr) {
      if (valueStr == null || valueStr === '') return null
      const str = String(valueStr)
      if (str.includes('-')) {
        const max = parseFloat(str.split('-').pop())
        return Number.isNaN(max) ? null : max
      }
      const value = parseFloat(str)
      return Number.isNaN(value) ? null : value
    },
    selectSurveyDataItem(data) {
      if (!data?.length) return null
      const units = [...new Set(data.map((item) => item[0]))]
      if (units.length === 1) {
        return data.find((item) => item[0] === units[0])
      }
      for (const unit of PRIORITY_UNITS) {
        const found = data.find((item) => item[0] === unit)
        if (found) return found
      }
      return null
    },
    getDepartmentValue(data) {
      const item = this.selectSurveyDataItem(data)
      if (!item) return null
      return this.parseSurveyValue(item[1])
    },
    resolveGradientUnit(features) {
      const units = new Set()
      features.forEach((feature) => {
        const dataByYear = feature.properties?.data_by_year
        if (!dataByYear) return
        Object.values(dataByYear).forEach((yearData) => {
          yearData?.forEach((item) => units.add(item[0]))
        })
      })
      if (!units.size) return null
      if (units.size === 1) return [...units][0]
      for (const unit of PRIORITY_UNITS) {
        if (units.has(unit)) return unit
      }
      return null
    },
    getValueFromYearData(yearData, gradientUnit) {
      if (!yearData) return null
      const item = gradientUnit
        ? yearData.find((entry) => entry[0] === gradientUnit)
        : null
      if (!item) return this.getDepartmentValue(yearData)
      return this.parseSurveyValue(item[1])
    },
    collectAllValues(features, gradientUnit) {
      const values = []
      features.forEach((feature) => {
        const dataByYear = feature.properties?.data_by_year
        if (!dataByYear) return
        Object.values(dataByYear).forEach((yearData) => {
          const value = this.getValueFromYearData(yearData, gradientUnit)
          if (value != null) values.push(value)
        })
      })
      return values
    },
    buildGlobalColorScale() {
      const baseColor = this.colors[this.selectedSeason.value]
      this.gradientUnit = this.resolveGradientUnit(this.mapData.features)
      const values = this.collectAllValues(
        this.mapData.features,
        this.gradientUnit
      )

      if (!values.length) {
        this.resetLegend()
        this.colorScale = () => '#CFCBD1'
        return
      }

      const scaleInfo = this.buildColorScale(values, baseColor)
      this.colorScale = scaleInfo.scale
      this.legendInfo = {
        unit: this.gradientUnit || 'Valeur',
        min: Math.round(scaleInfo.min),
        max: Math.round(scaleInfo.max),
        gradient: scaleInfo.gradient,
      }
    },
    buildColorScale(values, baseColor) {
      const min = Math.min(...values)
      const max = Math.max(...values)
      const lightColor = d3.interpolateRgb('#ffffff', baseColor)(0.2)
      if (min === max) {
        return {
          scale: () => baseColor,
          min,
          max,
          gradient: `linear-gradient(to right, ${lightColor}, ${baseColor})`,
        }
      }
      return {
        scale: d3
          .scaleLinear()
          .domain([min, max])
          .range([lightColor, baseColor])
          .clamp(true),
        min,
        max,
        gradient: `linear-gradient(to right, ${lightColor}, ${baseColor})`,
      }
    },
    collectSourcesForYear() {
      const sources = new Set()
      this.mapData.features.forEach((feature) => {
        const yearData = this.getYearData(feature.properties)
        yearData?.forEach((item) => {
          if (!item[3]) return
          item[3]
            .split(' ; ')
            .map((source) => source.trim())
            .filter(Boolean)
            .forEach((source) => sources.add(source))
        })
      })
      this.dataSources = [...sources].sort()
    },
    getDepartmentFill(properties) {
      const yearData = this.getYearData(properties)
      if (!yearData) return '#CFCBD1'

      const value = this.getValueFromYearData(yearData, this.gradientUnit)
      if (value == null || !this.colorScale) return '#CFCBD1'
      return this.colorScale(value)
    },
    updateMapForYear() {
      if (!this.mapData?.features?.length) return

      this.collectSourcesForYear()

      d3.select('#map')
        .selectAll('path.department')
        .style('fill', (d) => this.getDepartmentFill(d.properties))
    },
    async getMapData() {
      if (this.apiRequestController) {
        this.apiRequestController.cancel('Loading canceled')
      }
      this.apiRequestController = this.$axios.CancelToken.source()
      this.dataLoading = true
      const cancelToken = this.apiRequestController.token
      const url = `/api/v1/taxa/map/survey`
      const params = {
        cd_nom: this.cdNom,
        phenology_period: this.selectedSeason.value,
        id_area_atlas_territory: this.idArea,
      }
      const axios = this.$axios
      try {
        this.mapData = await this.$axios.$get(url, { params, cancelToken })
      } catch (thrown) {
        if (axios.isCancel(thrown)) {
          console.debug('Request canceled', thrown.message)
        }
      }
      this.dataLoading = false
    },
    renderMap() {
      this.buildGlobalColorScale()
      this.collectSourcesForYear()

      const path = d3.geoPath()
      const projection = d3
        .geoConicConformal()
        .center([2.454071, 46.279229])
        .scale(2600)
        .translate([600 / 2, 600 / 2])
      path.projection(projection)

      const svg = d3
        .select('#map')
        .append('svg')
        .attr('id', 'svg')
        .attr('width', 600)
        .attr('height', 570)

      const areas = svg.append('g')

      document.getElementById('map-tooltip')?.remove()

      const div = d3
        .select('body')
        .append('div')
        .attr('class', 'map-tooltip')
        .attr('id', 'map-tooltip')
        .style('opacity', 0)

      const component = this

      areas
        .selectAll('path')
        .data(this.mapData.features)
        .enter()
        .append('path')
        .attr('class', 'department')
        .attr('d', path)
        .style('fill', (d) => component.getDepartmentFill(d.properties))
        .style('stroke', 'white')
        .style('stroke-width', '2px')
        .on('mouseover', function (event, d) {
          const yearData = component.getYearData(d.properties)
          div.transition().duration(200).style('opacity', 0.9)
          div
            .html(
              `<p class="tooltip-title"><strong>${d.properties?.area_name} ${
                d.properties?.area_code
              }</strong></p>
            ${
              yearData
                ? yearData
                    .map(
                      (item) =>
                        `<p class="tooltip-values">${item[0]}&nbsp;:&nbsp;<strong>${item[1]}&nbsp;(${item[2]})</strong></p>`
                    )
                    .join('')
                : '<i class="no-data">Pas de données</i>'
            }`
            )
            .style('left', event.pageX + 30 + 'px')
            .style('top', event.pageY - 30 + 'px')
        })
        .on('mouseout', function () {
          div.style('opacity', 0)
          div.html('').style('left', '-500px').style('top', '-500px')
        })
    },
  },
}
</script>

<style>
#map {
  text-align: center;
}

.temporal-control {
  max-width: 600px;
  margin: 0 auto;
}

.temporal-control-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.temporal-year {
  font-size: 0.9rem;
}

.temporal-slider-wrapper {
  position: relative;
  padding-bottom: 8px;
}

.temporal-slider-track {
  position: relative;
  height: 24px;
  display: flex;
  align-items: center;
}

.temporal-slider-track::before {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  top: 50%;
  height: 4px;
  transform: translateY(-50%);
  background: rgba(38, 38, 38, 0.1);
  border-radius: 40px;
  z-index: 0;
}

.temporal-slider {
  appearance: none;
  position: relative;
  z-index: 2;
  width: 100%;
  height: 4px;
  margin: 0;
  background: transparent;
  border-radius: 40px;
  outline: none;
  cursor: pointer;
}

.temporal-slider::-webkit-slider-runnable-track {
  height: 4px;
  border-radius: 40px;
  background: linear-gradient(
    to right,
    #eece25 0%,
    #eece25 var(--slider-progress, 0%),
    rgba(38, 38, 38, 0.1) var(--slider-progress, 0%),
    rgba(38, 38, 38, 0.1) 100%
  );
}

.temporal-slider::-webkit-slider-thumb {
  appearance: none;
  width: 12px;
  height: 12px;
  margin-top: -4px;
  background: #fcfcfc;
  border-radius: 50%;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

.temporal-slider::-moz-range-thumb {
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border-radius: 50%;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

.temporal-track-dots {
  position: absolute;
  left: 0;
  right: 0;
  top: 50%;
  height: 0;
  z-index: 1;
  pointer-events: none;
}

.temporal-track-dot {
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 6px;
  height: 6px;
  padding: 0;
  border: none;
  border-radius: 50%;
  background: rgba(38, 38, 38, 0.35);
  cursor: pointer;
  pointer-events: auto;
}

.temporal-track-dot.active {
  width: 8px;
  height: 8px;
  background: #eece25;
  box-shadow: 0 0 0 2px rgba(238, 206, 37, 0.25);
}

.temporal-labels {
  position: relative;
  height: 28px;
  margin-top: 6px;
}

.temporal-tick-label {
  position: absolute;
  top: 0;
  transform: translateX(-50%);
  font-size: 0.7rem;
  line-height: 1.1;
  color: rgba(38, 38, 38, 0.55);
  white-space: nowrap;
}

.temporal-tick-label.active {
  color: #262626;
  font-weight: 600;
}

.map-tooltip {
  position: absolute;
  min-width: 250px;
  left: 0;
  top: -12px;
  background: #262626;
  border-radius: 8px;
  z-index: 1000;
  padding: 10px;
  pointer-events: none;
  color: white;
}

#legend {
  border-left: 1px solid rgba(57, 118, 90, 0.1);
  display: flex;
  flex-direction: column;
}

.legend-body {
  flex: 1;
  display: flex;
  flex-direction: column;
}

#legend-title {
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
}

.no-data {
  color: rgba(255, 255, 255, 0.5);
}

.tooltip-title {
  color: white;
  border-bottom: 1px solid white;
  padding-bottom: 2px;
  margin-bottom: 5px;
}

.tooltip-values {
  color: white;
}

.no-data-info {
  background-color: rgb(78, 78, 78, 0.2);
  border-radius: 10px;
  padding: 10px;
  margin: 0 10%;
}

.legend-section-title {
  line-height: 1.4;
}

.legend-unit {
  font-weight: 500;
}

.legend-absence {
  line-height: 1.4;
}

.legend-sources {
  margin-top: auto;
  padding-top: 24px;
  border-top: 1px solid rgba(57, 118, 90, 0.1);
}

.legend-source {
  font-size: 0.7rem;
  line-height: 1.35;
}

.legend-source + .legend-source {
  margin-top: 8px;
}

.legend-gradient {
  height: 14px;
  border-radius: 6px;
}

.legend-scale {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
}
</style>
