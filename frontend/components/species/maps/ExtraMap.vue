<template>
  <v-container fluid class="fill-height">
    <v-col v-if="!hasData" class="no-data-info">Aucune donnée disponible pour ce territoire et cette période</v-col>
    <v-row v-if="hasData"  class="fill-height ma-0">
      <v-col ref="mapBlock" cols="9" xs="12" sm="12" md="8">
        <commons-map-loading-control
          class="float-right"
          :loading="dataLoading"
        />
        <div id="map"></div>
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
        
        <div class="pa-5">
          <p>
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
                  :fill="colors[selectedSeason.value]"
                /></svg></span
            >Existence de données de suivis
          </p>
          <p>
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
            >Absence de données de suivis
          </p>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
const d3 = require('d3')

export default {
  data: () => ({
    mapData: null,
    apiRequestController: null,
    dataLoading: false,
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
    hasData(){
      return !!this.mapData?.features.filter(i => i.properties.data != null).length
    }
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
  methods: {
    generateMap() {
      this.getMapData().then(() => {
        d3.select('#map').selectAll('svg').remove()
        console.log('hasData', this.hasData)
        if (this.hasData) {
          this.renderMap()
        }
      })
    },
    async getMapData() {
      if (this.apiRequestController) {
        this.apiRequestController.cancel('Loading canceled')
      }
      this.apiRequestController = this.$axios.CancelToken.source()
      this.dataLoading = true
      // Url Source selection
      const url = `/api/v1/taxa/map/survey`
      const params = {
        cd_nom: this.cdNom,
        phenology_period: this.selectedSeason.value,
        id_area_atlas_territory: this.idArea,
      }
      const axios = this.$axios
      this.mapData = await this.$axios
        .$get(url, {
          params,
          cancelToken: this.apiRequestController.token,
        })
        .catch(function (thrown) {
          if (axios.isCancel(thrown)) {
            console.debug('Request canceled', thrown.message)
          }
        })
      this.dataLoading = false
    },
    renderMap() {
      const color = this.colors[this.selectedSeason.value]
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
        .attr('height', 600)

      const areas = svg.append('g')

      document.getElementById('map-tooltip')?.remove()

      const div = d3
        .select('body')
        .append('div')
        .attr('class', 'map-tooltip')
        .attr('id', 'map-tooltip')
        .style('opacity', 0)

      areas
        .selectAll('path')
        .data(this.mapData.features)
        .enter()
        .append('path')
        .attr('class', 'department')
        .attr('d', path)
        .style('fill', function (d) {
          return d.properties.data ? color : '#CFCBD1'
        })
        .style('stroke', 'white')
        .style('stroke-width', '2px')
        .on('mouseover', function (event, d) {
          div.transition().duration(200).style('opacity', 0.9)
          div
            .html(
              `<p class="tooltip-title"><strong>${d.properties?.area_name} ${
                d.properties?.area_code
              }</strong></p>
            ${
              d.properties.data
                ? d.properties.data
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
        .on('mouseout', function (event, d) {
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
</style>
