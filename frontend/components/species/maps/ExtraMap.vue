<template>
  <div>
    <generic-map-loading-control :loading="speciesDistributionIsLoading" />
    <div id="map"></div>
  </div>
</template>

<script>
const d3 = require('d3')

export default {
  props: {
    selectedTerritory: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    selectedSubject: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    selectedSeason: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    cdnom: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    speciesDistributionGeojson: null,
    apiRequestController: null,
    speciesDistributionIsLoading: false,
    defaultColor: '#336950',
    width: 600,
    height: 600,
  }),
  mounted() {
    this.getSpecieData().then(() => this.generateMap())
  },
  methods: {
    async getSpecieData() {
      if (this.apiRequestController) {
        this.apiRequestController.cancel('Loading canceled')
      }
      this.apiRequestController = this.$axios.CancelToken.source()
      this.speciesDistributionIsLoading = true
      // Url Source selection
      const requestParams = {
        cd_nom: this.cdnom,
      }

      const axios = this.$axios
      this.speciesDistributionGeojson = await this.$axios
        .$get(`/api/v1/taxa/survey/map`, {
          params: requestParams,
          cancelToken: this.apiRequestController.token,
        })
        // .then((data) => (this.speciesDistributionGeojson = data))
        .catch(function (thrown) {
          if (axios.isCancel(thrown)) {
            console.log('Request canceled', thrown.message)
          }
        })
      console.log(this.speciesDistributionGeojson)
      this.speciesDistributionIsLoading = false
    },
    generateMap() {
      const path = d3.geoPath()
      const projection = d3
        .geoConicConformal()
        .center([2.454071, 46.279229])
        .scale(2600)
        .translate([this.width / 2, this.height / 2])
      path.projection(projection)

      const svg = d3
        .select('#map')
        .append('svg')
        .attr('id', 'svg')
        .attr('width', this.width)
        .attr('height', this.height)

      const areas = svg.append('g')

      const div = d3
        .select('body')
        .append('div')
        .attr('class', 'map-tooltip')
        .style('opacity', 0)

      areas
        .selectAll('path')
        .data(this.speciesDistributionGeojson.features)
        .enter()
        .append('path')
        .attr('class', 'department')
        .attr('d', path)
        .style('fill', function (d) {
          return d.properties.data ? '#E65784' : '#CFCBD1'
        })
        .style('stroke', 'white')
        .style('stroke-width', '2px')
        .on('mouseover', function (event, d) {
          div.transition().duration(200).style('opacity', 1)
          div
            .html(
              `
            <p><strong>${d.properties.area_name} ${
                d.properties.area_code
              }</strong></p>
            ${
              d.properties.data
                ? d.properties.data
                    .map((item) => `<p>${item[0]} ${item[1]}</p>`)
                    .join('')
                : 'Pas de données'
            }
            `
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
.map {
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
</style>
