<template>
  <div v-if="chartData" id="phenology-breeding" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
    <h5 class="black03 bottom-margin-40">
      Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au 31
      décembre de l'année dernière.
    </h5>
    <div class="ChartWrapper">
      <div class="Chart">
        <svg class="BarPlotSvg"></svg>
      </div>
      <div class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.breeding_start?.color }"></i
          >{{ chartData.breeding_start.label }}
        </h5>
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.breeding_end?.color }"></i
          >{{ chartData.breeding_end?.label }}
        </h5>
      </div>
    </div>
  </div>
</template>

<script>
const d3 = require('d3')

export default {
  data: () => ({
    chartData: null,
  }),
  computed: {
    idArea() {
      return this.$store.state.species.selectedTerritory.id_area
    },
    cdNom() {
      return this.$store.state.species.cdNom
    },
  },
  watch: {
    idArea: {
      handler() {
        this.generateChart()
      },
    },
  },
  mounted() {
    this.$nextTick(function () {
      this.generateChart()
    })
  },
  methods: {
    generateChart() {
      this.getChartData().then(() => {
        if (this.chartData) {
          this.renderChart()
          this.$store.commit('species/pushSubjectsList', {
            label: 'Phénologie',
            slug: 'phenology-breeding',
            position: 3,
          })
        }
      })
    },
    async getChartData() {
      const url = `/api/v1/taxa/chart/phenology/breeding`
      const params = {
        cd_nom: this.cdNom,
        id_area: this.idArea,
      }
      this.chartData = await this.$axios
        .$get(url, {
          params,
        })
        .catch((error) => {
          console.error(error)
        })
    },
    renderChart() {
      // Get bar plot size
      const margin = { top: 10, right: 0, bottom: 24, left: 66 }
      const barPlotWidth = Math.max(
        parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
          margin.left -
          margin.right,
        400
      )
      const barPlotHeight =
        parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
        margin.top -
        margin.bottom
      // Get bar plot svg and set size
      const barPlotSvg = d3
        .select(this.$el)
        .select('.BarPlotSvg')
        .attr('width', barPlotWidth + margin.left + margin.right)
        .attr('height', barPlotHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left}, ${margin.top})`)
      // Set X axis and add it
      const xAxisMonths = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.15)
        .domain([
          'Jan',
          'Fév',
          'Mars',
          'Avril',
          'Mai',
          'Juin',
          'Juil',
          'Août',
          'Sept',
          'Oct',
          'Nov',
          'Déc',
        ])
      barPlotSvg
        .append('g')
        .attr('class', 'xAxis')
        .attr('transform', `translate(0, ${barPlotHeight})`)
        .call(d3.axisBottom(xAxisMonths))
        .call((g) =>
          g
            .selectAll('text')
            .attr(
              'style',
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
            )
        )
        .call((g) => g.selectAll('line[y2]').style('opacity', 0))
      // Set Y axis and add it
      const breedingStartMaxValue = this.chartData.breeding_start.data.reduce(
        (oldVal, newVal) => (oldVal.value > newVal.value ? oldVal : newVal)
      )
      const breedingEndMaxValue = this.chartData.breeding_end.data.reduce(
        (oldVal, newVal) => (oldVal.value > newVal.value ? oldVal : newVal)
      )
      const yAxis = d3
        .scaleLinear()
        .range([barPlotHeight, 0])
        .domain([
          0,
          d3.max([breedingStartMaxValue.value, breedingEndMaxValue.value]),
        ])
      barPlotSvg
        .append('g')
        .attr('class', 'yAxis')
        .call(d3.axisLeft(yAxis))
        .call((g) =>
          g
            .selectAll('.tick line')
            .clone()
            .attr('x2', barPlotWidth)
            .attr('stroke-opacity', 0.1)
        )
        .call((g) =>
          g
            .selectAll('text')
            .attr(
              'style',
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 400; font-size: 12px; line-height: 13px; color: #000;"
            )
        )
        .call((g) => g.selectAll('line[x2="-6"]').style('opacity', 0))
      // Set Y axis label
      barPlotSvg
        .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('x', -(barPlotHeight / 2))
        .attr('y', -margin.left + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('Nombre de données')
      // Delete axis lines
      barPlotSvg.selectAll('path').style('opacity', 0)
      // Bars
      const xAxisDecades = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.45)
        .domain(
          this.chartData.breeding_start.data.map(function (d) {
            return d.label
          })
        )
      // INFO: display Breeding start data
      barPlotSvg
        .append('g')
        .attr('class', 'bars')
        .selectAll('rect')
        .data(this.chartData.breeding_start.data)
        .enter()
        .append('rect')
        .attr('class', 'bar-group')
        .attr('x', function (d) {
          return xAxisDecades(d.label)
        })
        .attr('y', function (d) {
          return yAxis(d.value)
        })
        .attr('width', xAxisDecades.bandwidth() / 2)
        .attr('height', function (d) {
          return barPlotHeight - yAxis(d.value)
        })
        .attr('fill', this.chartData.breeding_start.color)
      // INFO: display Breeding end data
      barPlotSvg
        .append('g')
        .attr('class', 'bars')
        .selectAll('rect')
        .data(this.chartData.breeding_end.data)
        .enter()
        .append('rect')
        .attr('class', 'bar')
        .attr('x', function (d) {
          return xAxisDecades(d.label) - 5
        })
        .attr('y', function (d) {
          return yAxis(d.value)
        })
        .attr('width', xAxisDecades.bandwidth() / 2)
        .attr('height', function (d) {
          return barPlotHeight - yAxis(d.value)
        })
        .attr('fill', this.chartData.breeding_end.color)
    },
  },
}
</script>
