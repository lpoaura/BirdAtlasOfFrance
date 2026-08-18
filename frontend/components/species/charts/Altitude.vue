<template>
  <div v-if="idArea && hasValidChartData" id="altitude" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">
      Répartition altitudinale des observations
    </h4>
    <h5 class="black03 bottom-margin-40">
      Proportion des observations en fonction de l’altitude du territoire.
    </h5>
    <div class="ChartWrapper">
      <div class="Chart"></div>
      <div class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.altitude?.color }"></i
          >{{ chartData.altitude?.label }}
        </h5>
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.globalAltitude?.color }"></i
          >{{ chartData.globalAltitude?.label }}
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
    fetchId: 0,
  }),
  computed: {
    idArea() {
      return this.$store.state.species.selectedTerritory.id_area
    },
    cdNom() {
      return this.$store.state.species.cdNom
    },
    selectedSeason() {
      return this.$store.state.species.selectedSeason?.value
    },
    hasValidChartData() {
      return (
        this.chartData &&
        this.chartData.altitude?.data?.length > 0 &&
        this.chartData.globalAltitude?.data?.length > 0
      )
    },
  },
  watch: {
    idArea: {
      handler() {
        this.generateChart()
      },
    },
    selectedSeason: {
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
    async generateChart() {
      const currentFetchId = ++this.fetchId
      if (!this.idArea) {
        this.chartData = null
        return
      }
      await this.getChartData(currentFetchId)
      if (currentFetchId !== this.fetchId) return

      try {
        if (this.hasValidChartData) {
          // Attendre que le v-if ait monté le DOM avant d'appeler D3
          await this.$nextTick()
          if (currentFetchId !== this.fetchId) return
          if (this.$el?.querySelector?.('.Chart')) {
            this.renderChart()
            this.renderData()
          }
        }
      } finally {
        if (currentFetchId === this.fetchId) {
          this.$store.commit('species/pushSubjectsList', {
            label: 'Répartition altitudinale',
            slug: 'altitude',
            position: 6,
            status: !!this.hasValidChartData,
          })
        }
      }
    },
    async getChartData(fetchId) {
      const url = `/api/v1/taxa/chart/altitude`
      const params = {
        cd_nom: this.cdNom,
        id_area: this.idArea,
        period: this.selectedSeason,
      }
      const data = await this.$axios
        .$get(url, {
          params,
        })
        .catch((error) => {
          console.debug(`${error}`)
          return null
        })
      if (fetchId === this.fetchId) {
        this.chartData = data
      }
    },
    renderData() {
      const divId = 'altitude-chart-tooltip'
      document.getElementById(divId)?.remove()
      const div = d3
        .select('body')
        .append('div')
        .attr('class', 'chart-tooltip')
        .attr('id', divId)
        .style('opacity', 0)

      // Render x axis Scale using data max value
      this.xAxis.domain([
        0,
        d3.max(this.chartData.altitude.data, function (d) {
          return d.value
        }),
      ])

      // Render y axis Scale using data max value
      this.yAxis.domain([
        0,
        d3.max(this.chartData.altitude.data, (d) => d.label),
      ])

      this.chart
        .append('g')
        .attr('class', 'xAxis')
        .attr('transform', `translate(0, ${this.height})`)
        .call(d3.axisBottom(this.xAxis).tickFormat((d) => `${d}%`))
        .call((g) =>
          g
            .selectAll('text')
            .attr(
              'style',
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
            )
        )
      // .call((g) => g.selectAll('line[y2]').style('opacity', 0))
      // Set Y axis and add it

      const formatter = d3
        .formatLocale({
          decimal: '.',
          thousands: ' ',
          grouping: [3],
          currency: ['', ''],
        })
        .format(',.0f')
      this.chart
        .append('g')
        .attr('class', 'yAxis')
        .call(d3.axisLeft(this.yAxis).tickFormat(formatter))
        .call((g) =>
          g
            .selectAll('.tick line')
            .clone()
            .attr('x2', this.width)
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
      this.chart
        .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('x', -(this.height / 2))
        .attr('y', -this.margin.left + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text('Altitude (mètres)')
      // Delete axis lines
      this.chart.selectAll('path').style('opacity', 0)

      const that = this
      this.chart
        .append('g')
        .attr('class', 'bars')
        .selectAll('rect')
        .data(this.chartData.altitude.data)
        .enter()
        .append('rect')
        .attr('class', 'bar')
        .attr('x', function (d) {
          return that.xAxis(0)
        })
        .attr('y', function (d) {
          return that.yAxis(d.label)
        })
        .attr('width', function (d) {
          return that.xAxis(d.value)
        })
        .attr('height', 6)
        .attr('fill', this.chartData.altitude?.color)
        .on('mouseover', function (event, d) {
          console.log('mousover')
          div.transition().duration(200).style('opacity', 0.9)
          div
            .html(
              `<strong>Nombre de données</strong>&nbsp;: ${d.value.toFixed(
                2
              )} %`
            )
            .style('left', event.pageX + 30 + 'px')
            .style('top', event.pageY - 30 + 'px')
        })
        .on('mouseout', function (event, d) {
          div.style('opacity', 0)
          div.html('').style('left', '-500px').style('top', '-500px')
        })
      // Area

      this.chart
        .append('path')
        .attr('class', 'area')
        .datum(this.chartData.globalAltitude.data)
        .attr('fill', this.chartData.globalAltitude?.color)
        .attr('stroke-width', 0)
        .attr(
          'd',
          d3
            .area()
            .curve(d3.curveBasis)
            .x0(this.xAxis(0))
            .x1(function (d) {
              return that.xAxis(d.value)
            })
            .y(function (d) {
              return that.yAxis(d.label)
            })
        )
    },
    renderChart() {
      const root = this.$el
      if (!root?.querySelector) return

      d3.select(root).select('.BarPlotSvg').remove()

      d3.select(root).select('.Chart').append('svg').attr('class', 'BarPlotSvg')
      // Get bar plot size
      this.margin = { top: 10, right: 0, bottom: 24, left: 70 }
      const chartEl = d3.select(root).select('.Chart').node()
      const chartRect = chartEl?.getBoundingClientRect?.()
      const chartWidth = chartRect?.width ?? 0
      const chartHeight = chartRect?.height ?? 0

      this.width = Math.max(
        chartWidth - this.margin.left - this.margin.right,
        0
      )
      this.height = Math.max(
        chartHeight - this.margin.top - this.margin.bottom,
        0
      )
      // Get bar plot svg and set size
      this.chart = d3
        .select(root)
        .select('.BarPlotSvg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .append('g')
        .attr('transform', `translate(${this.margin.left}, ${this.margin.top})`)
      // Set X axis and add it
      this.xAxis = d3.scaleLinear().range([0, this.width])
      this.yAxis = d3.scaleLinear().range([this.height, 0])
      // Bars
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
