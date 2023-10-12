<template>
  <div v-if="idArea && chartData" id="phenology-migration" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">Phénologie de migration</h4>
    <h5 class="black03 bottom-margin-24">
      Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au 31
      décembre de l'année dernière.
    </h5>
    <div class="ChartWrapper">
      <div class="Chart">
        <svg class="BarPlotSvg"></svg>
      </div>
      <div class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.phenology?.color }"></i
          >{{ chartData.phenology?.label }}
        </h5>
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.prenuptial?.colors.quantile }"></i
          >{{ chartData.prenuptial?.label }}
        </h5>
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.postnuptial?.colors.quantile }"></i
          >{{ chartData.postnuptial?.label }}
        </h5>
      </div>
    </div>
  </div>
</template>

<script>
import { dataPhenologyMigration } from '~/test/fakeData'

const d3 = require('d3')

export default {
  data: () => ({
    chartData: dataPhenologyMigration,
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
            label: 'Phénologie de migration',
            slug: 'phenology-migration',
            position: 2,
          })
        }
      })
    },
    async getChartData() {
      // const url = `/api/v1/taxa/phenology/migration/${this.idArea}/${this.cdNom}`
      // this.chartData = await this.$axios.$get(url).catch((error) => {
      //   console.error(error)
      // })
    },
    renderChart() {
      // Get bar plot size
      const margin = { top: 20, right: 0, bottom: 24, left: 66 }
      const barPlotWidth = Math.max(
        parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
          margin.left -
          margin.right,
        500
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
        .padding(0.3)
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
      const yAxis = d3
        .scaleLinear()
        .range([barPlotHeight, 0])
        .domain([
          0,
          d3.max(this.chartData.phenology.data, function (d) {
            return d.count_data
          }),
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
      // Quantiles
      const xAxisDecades = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.9)
        .domain(
          this.chartData.phenology.data.map(function (d) {
            return d.label
          })
        )
      barPlotSvg
        .append('rect')
        .attr('class', 'quantiles')
        .attr(
          'x',
          xAxisDecades(this.chartData.prenuptial.data[0]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', 0)
        .attr(
          'width',
          xAxisDecades(this.chartData.prenuptial.data[2]) -
            xAxisDecades(this.chartData.prenuptial.data[0])
        )
        .attr('height', barPlotHeight)
        .attr('fill', this.chartData.prenuptial.colors.quantile)
      barPlotSvg
        .append('line')
        .attr('class', 'median')
        .attr(
          'x1',
          xAxisDecades(this.chartData.prenuptial.data[1]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr(
          'x2',
          xAxisDecades(this.chartData.prenuptial.data[1]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y1', 0)
        .attr('y2', barPlotHeight)
        .attr('stroke-width', 4)
        .style('stroke-dasharray', '4,5')
        .style('stroke', '#39765A')
      barPlotSvg
        .append('text')
        .attr(
          'x',
          xAxisDecades(this.chartData.prenuptial.data[0]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', -margin.top + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('5%')
      barPlotSvg
        .append('text')
        .attr(
          'x',
          xAxisDecades(this.chartData.prenuptial.data[1]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', -margin.top + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('Médiane')
      barPlotSvg
        .append('text')
        .attr(
          'x',
          xAxisDecades(this.chartData.prenuptial.data[2]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', -margin.top + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('95%')
      barPlotSvg
        .append('rect')
        .attr('class', 'quantiles')
        .attr(
          'x',
          xAxisDecades(this.chartData.postnuptial.data[0]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', 0)
        .attr(
          'width',
          xAxisDecades(this.chartData.postnuptial.data[2]) -
            xAxisDecades(this.chartData.postnuptial.data[0])
        )
        .attr('height', barPlotHeight)
        .attr('fill', this.chartData.postnuptial.colors.quantile)
      barPlotSvg
        .append('line')
        .attr('class', 'median')
        .attr(
          'x1',
          xAxisDecades(this.chartData.postnuptial.data[1]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr(
          'x2',
          xAxisDecades(this.chartData.postnuptial.data[1]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y1', 0)
        .attr('y2', barPlotHeight)
        .attr('stroke-width', 4)
        .style('stroke-dasharray', '4,5')
        .style('stroke', '#EB6A0A')
      barPlotSvg
        .append('text')
        .attr(
          'x',
          xAxisDecades(this.chartData.postnuptial.data[0]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', -margin.top + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('5%')
      barPlotSvg
        .append('text')
        .attr(
          'x',
          xAxisDecades(this.chartData.postnuptial.data[1]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', -margin.top + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('Médiane')
      barPlotSvg
        .append('text')
        .attr(
          'x',
          xAxisDecades(this.chartData.postnuptial.data[2]) +
            xAxisDecades.bandwidth() / 2
        )
        .attr('y', -margin.top + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('95%')
      // Bars
      barPlotSvg
        .append('g')
        .attr('class', 'bars')
        .selectAll('rect')
        .data(this.chartData.phenology.data)
        .enter()
        .append('rect')
        .attr('class', 'bar')
        .attr('x', function (d) {
          return xAxisDecades(d.label)
        })
        .attr('y', function (d) {
          return yAxis(d.count_data)
        })
        .attr('width', xAxisDecades.bandwidth())
        .attr('height', function (d) {
          return barPlotHeight - yAxis(d.count_data)
        })
        .attr('fill', this.chartData.phenology.color)
    },
  },
}
</script>

<style scoped>
/********** RESPONSIVE **********/

@media screen and (width <= 510px) {
  .ChartLegend {
    display: grid !important;
    grid-template-columns: repeat(auto-fill, minmax(164px, 1fr));
    grid-gap: 16px;
  }

  .ChartLegendLabel {
    margin-right: 0 !important;
  }
}
</style>
