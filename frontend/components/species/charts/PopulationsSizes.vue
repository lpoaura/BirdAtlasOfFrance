<template>
  <div
    v-if="idArea && chartData && hasNbData"
    id="phenology-all-period"
    class="ChartCard"
  >
    <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
    <h5 class="black03 bottom-margin-40">
      Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au 31
      décembre de l'année dernière.
    </h5>
    <div class="ChartWrapper">
      <div class="Chart"></div>
      <div class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i :style="{ background: blue }"></i>{{ chartData.year }}
        </h5>
        <!-- <h5 class="ChartLegendLabel">
          <i
            class="round"
            :style="{ background: chartData. }"
          ></i
          >{{ chartData.frequency.label }}
        </h5> -->
      </div>
    </div>
  </div>
</template>

<script>
import { dataPopulationsFake } from '~/test/fakeData'
const d3 = require('d3')

export default {
  data: () => ({
    chartData: null,
    subject: {
      label: 'Taille de population',
      slug: 'population-size',
      position: 1,
    },
  }),
  computed: {
    idArea() {
      return this.$store.state.species.selectedTerritory.id_area
    },
    cdNom() {
      return this.$store.state.species.cdNom
    },
    phenologyPeriod() {
      return this.$store.state.species.selectedSeason?.value
    },
    hasNbData() {
      return this.chartData?.length > 0
    },
  },
  watch: {
    idArea(newVal) {
      if (newVal) {
        this.generateChart()
      }
    },
    phenologyPeriod: {
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
        if (this.chartData && this.hasNbData) {
          this.renderChart()
          this.$store.commit('species/pushSubjectsList', this.subject)
        }
      })
    },
    async getChartData() {
      if (this.idArea) {
        // const requestParams = {
        //   cd_nom: this.cdNom,
        //   id_area: this.idArea,
        //   phenology_period: this.phenologyPeriod,
        // }
        // const url = `api/v1/taxa/chart/survey`
        // this.chartData = await this.$axios
        //   .$get(url, {
        //     params: requestParams,
        //   })
        //   .catch((error) => {
        //     console.debug(`${error}`)
        //   })
        const sleep = (m) => new Promise((resolve) => setTimeout(resolve, m))
        await sleep(100)
        this.chartData = dataPopulationsFake
        console.log(this.chartData)
      }
    },
    renderChart() {
      d3.select(this.$el).select('.BarPlotSvg').remove()

      d3.select(this.$el)
        .select('.Chart')
        .append('svg')
        .attr('class', 'BarPlotSvg')
      const margin = { top: 10, right: 60, bottom: 24, left: 66 }
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
        .padding(0.3)
        .domain(this.chartData.map((item) => item.year))

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

      // Bars
      const xAxisDecades = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.9)
        .domain(this.chartData.map((item) => item.year))
      // Set left Y axis and add it
      if (this.hasNbData) {
        const yAxisLeft = d3
          .scaleLinear()
          .range([barPlotHeight, 0])
          .domain([
            0,
            d3.max(this.chartData, function (d) {
              return d.data.val
            }),
          ])
        barPlotSvg
          .append('g')
          .attr('class', 'yAxisLeft')
          .call(d3.axisLeft(yAxisLeft))
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
                "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
              )
          )
          .call((g) => g.selectAll('line[x2="-6"]').style('opacity', 0))
        // Set left Y axis label
        barPlotSvg
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('x', -(barPlotHeight / 2))
          .attr('y', -margin.left + 10)
          .attr(
            'style',
            "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
          )
          .text(this.chartData.unit)

        barPlotSvg
          .append('g')
          .attr('class', 'bars')
          .selectAll('rect')
          .data(this.chartData)
          .enter()
          .append('rect')
          .attr('class', 'bar')
          .attr('x', function (d) {
            return xAxisDecades(d.year)
          })
          .attr('y', function (d) {
            return yAxisLeft(d.data.val)
          })
          .attr('width', xAxisDecades.bandwidth())
          .attr('height', function (d) {
            return barPlotHeight - yAxisLeft(d.data.val)
          })
        // .attr('fill', this.chartData.phenology.color)
      }
      // Set right Y axis and add it
      // Delete axis lines
      barPlotSvg
        .selectAll('.yAxisLeft,.yAxisRight,.xAxis')
        .selectAll('path')
        .style('opacity', 0)

      // Lines and points
    },
  },
}
</script>
