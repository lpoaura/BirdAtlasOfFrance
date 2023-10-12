<template>
  <div v-if="idArea && chartData" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">
      Tailles de populations (CECI EST UN TEST QUI N'A RIEN À FAIRE ICI)
    </h4>
    <h5 class="black03 bottom-margin-40">
      Nombre d’individus comptabilisés au cours des années.
    </h5>

    <div class="ChartWrapper">
      <div class="Chart">
        <svg class="ChartSvg"></svg>
      </div>
      <div v-if="chartData.keys" class="ChartLegend">
        <h5 v-if="chartData.data[0].median" class="ChartLegendLabel">
          <i :style="{ background: chartData.colors[1] }"></i
          >{{ chartData.keys[1] }}
        </h5>
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.colors[0] }"></i
          >{{ chartData.keys[0] }}
        </h5>
      </div>
      <div v-else class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.color }"></i>{{ chartData.label }}
        </h5>
      </div>
    </div>
  </div>
</template>

<script>
import { dataPopulationsFake } from '~/test/fakeData'

const d3 = require('d3')

export default {
  data: () => ({
    chartData: dataPopulationsFake,
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
      const margin = { top: 10, right: 0, bottom: 24, left: 66 }
      const minWidth = this.chartData.keys
        ? this.chartData.data.length * 70 + margin.left + margin.right
        : 16 * 30 + margin.left + margin.right
      const chartWidth = Math.max(
        parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
          margin.left -
          margin.right,
        minWidth
      )
      const chartHeight =
        parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
        margin.top -
        margin.bottom
      // Get bar plot svg and set size
      const chartSvg = d3
        .select(this.$el)
        .select('.ChartSvg')
        .attr('width', chartWidth + margin.left + margin.right)
        .attr('height', chartHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left}, ${margin.top})`)
      if (this.chartData.keys) {
        // BOXPLOT
        // Set X axis and add it
        const xAxis = d3
          .scaleBand()
          .range([0, chartWidth])
          .paddingInner(1)
          .paddingOuter(0.5)
          .domain(
            this.chartData.data.map(function (d) {
              return d.label
            })
          )
        chartSvg
          .append('g')
          .attr('class', 'xAxis')
          .attr('transform', `translate(0, ${chartHeight})`)
          .call(d3.axisBottom(xAxis))
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
          .range([chartHeight, 0])
          .domain([
            0,
            d3.max(this.chartData.data, function (d) {
              return d.max
            }),
          ])
        chartSvg
          .append('g')
          .attr('class', 'yAxis')
          .call(d3.axisLeft(yAxis))
          .call((g) =>
            g
              .selectAll('.tick line')
              .clone()
              .attr('x2', chartWidth)
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
        chartSvg
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('x', -(chartHeight / 2))
          .attr('y', -margin.left + 10)
          .attr(
            'style',
            "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
          )
          .text(this.chartData.label)
        // Rectangles
        const boxWidth = 26
        chartSvg
          .append('g')
          .attr('class', 'boxes')
          .selectAll('rect')
          .data(this.chartData.data)
          .enter()
          .append('rect')
          .attr('class', 'box')
          .attr('x', function (d) {
            return xAxis(d.label) - boxWidth / 2
          })
          .attr('y', function (d) {
            return yAxis(d.max)
          })
          .attr('height', function (d) {
            return yAxis(d.min) - yAxis(d.max)
          })
          .attr('width', boxWidth)
          .attr('stroke', this.chartData.colors[0])
          .style('fill', this.chartData.colors[0])
        // Median
        if (this.chartData.data[0].median) {
          const medianWidth = 40
          chartSvg
            .append('g')
            .attr('class', 'medians')
            .selectAll('median')
            .data(this.chartData.data)
            .enter()
            .append('line')
            .attr('class', 'median')
            .attr('x1', function (d) {
              return xAxis(d.label) - medianWidth / 2
            })
            .attr('x2', function (d) {
              return xAxis(d.label) + medianWidth / 2
            })
            .attr('y1', function (d) {
              return yAxis(d.median)
            })
            .attr('y2', function (d) {
              return yAxis(d.median)
            })
            .attr('stroke', this.chartData.colors[1])
            .attr('stroke-width', 6)
        }
      } else {
        // BARPLOT
        // Set X axis and add it
        const bandWidth = chartWidth / this.chartData.data.length - 4
        const xAxis = d3
          .scaleLinear()
          .range([bandWidth / 2 + 8, chartWidth - bandWidth / 2])
          .domain([
            d3.min(this.chartData.data, function (d) {
              return d.label
            }),
            d3.max(this.chartData.data, function (d) {
              return d.label
            }),
          ])
        const formatter = d3
          .formatLocale({
            decimal: '.',
            thousands: '',
            grouping: [3],
            currency: ['', ''],
          })
          .format(',.0f')
        chartSvg
          .append('g')
          .attr('class', 'xAxis')
          .attr('transform', `translate(0, ${chartHeight})`)
          .call(d3.axisBottom(xAxis).tickFormat(formatter))
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
          .range([chartHeight, 0])
          .domain([
            0,
            d3.max(this.chartData.data, function (d) {
              return d.count_data
            }),
          ])
        chartSvg
          .append('g')
          .attr('class', 'yAxis')
          .call(d3.axisLeft(yAxis))
          .call((g) =>
            g
              .selectAll('.tick line')
              .clone()
              .attr('x2', chartWidth)
              .attr('stroke-opacity', 0.1)
          )
          .call((g) =>
            g
              .selectAll('text')
              .attr(
                'style',
                "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
              )
          )
          .call((g) => g.selectAll('line[x2="-6"]').style('opacity', 0))
        // Set Y axis label
        chartSvg
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('x', -(chartHeight / 2))
          .attr('y', -margin.left + 10)
          .attr(
            'style',
            "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
          )
          .text(this.chartData.label)
        // Bars
        chartSvg
          .append('g')
          .attr('class', 'bars')
          .selectAll('rect')
          .data(this.chartData.data)
          .enter()
          .append('rect')
          .attr('class', 'bar')
          .attr('x', function (d) {
            return xAxis(d.label) - bandWidth / 2
          })
          .attr('y', function (d) {
            return yAxis(d.count_data)
          })
          .attr('width', bandWidth)
          .attr('height', function (d) {
            return chartHeight - yAxis(d.count_data)
          })
          .attr('fill', this.chartData.color)
      }
      // Delete axis lines
      chartSvg.selectAll('path').style('opacity', 0)
    },
  },
}
</script>
