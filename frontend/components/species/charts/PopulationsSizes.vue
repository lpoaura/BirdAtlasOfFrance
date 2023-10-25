<template>
  <div v-if="idArea && !!chartData?.length" id="population-size" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">Taille de population</h4>
    <h5 class="black03 bottom-margin-40">
      Effectifs cumulés par années
    </h5>
    <div class="ChartWrapper">
      <div class="Chart"></div>
      <div class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i style="background: #435EF2"></i>{{ chartData[0].unit }}
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
// import { dataPopulationsFake } from '~/test/fakeData'
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
    phenologyPeriod() {
      return this.$store.state.species.selectedSeason?.value
    },
    hasMinMaxValues() {
      return !!this.chartData?.filter(i => i.data.val_min || i.val_max).length
    },
    hasValues() {
      return !!this.chartData?.filter(i => i.data.val).length
    }
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
        if (this.chartData?.length) {
          if (this.hasValues && !this.hasMinMaxValues) {
            this.renderBarChart()
          }
        }
        this.$store.commit('species/pushSubjectsList', {
          label: "Taille de population",
          slug: 'population-size',
          position: 4,
          status: !!this.chartData?.length,
        })
      })
    },
    async getChartData() {
      if (this.idArea) {
        const url = `api/v1/taxa/chart/survey`
        const requestParams = {
          cd_nom: this.cdNom,
          id_area: this.idArea,
          phenology_period: this.phenologyPeriod,
          chart_type: 'pop_size',
        }
        this.chartData = await this.$axios
          .$get(url, {
            params: requestParams,
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
      }
    },
    isRoundYear(year){
      return year % 5 ===0
    },
    renderBarChart() {
      d3.select(this.$el).select('.barPlotSvg').remove()
      d3.select(this.$el)
        .select('.Chart')
        .append('svg')
        .attr('class', 'barPlotSvg')
      console.debug('init SVG')
      const data = this.chartData.map((i) => {
        return { label: i.year, val: i.data.val, min: i.data.val_min, max: i.data.val_max }
      })
      // Get bar plot size
      const margin = { top: 10, right: 0, bottom: 24, left: 66 }
      // const minWidth = data.length * 30 + margin.left + margin.right
      // const barPlotWidth = Math.max(
      //   parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
      //   margin.left -
      //   margin.right,
      //   minWidth
      // )
      const barPlotWidth = parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right
      const barPlotHeight =
        parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
        margin.top -
        margin.bottom
      // Get bar plot svg and set size
      const barPlotSvg = d3
        .select(this.$el)
        .select('.barPlotSvg')
        .attr('width', barPlotWidth + margin.left + margin.right)
        .attr('height', barPlotHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left}, ${margin.top})`)
      // Set X axis and add it
      // const xAxis = d3
      //   .scaleLinear()
      //   .range([20, barPlotWidth - 20])
      //   .domain([
      //     d3.min(data, function (d) {
      //       console.log('label', d.label)
      //       return d.label
      //     }),
      //     d3.max(data, function (d) {
      //       console.log('lablemax', d.label)
      //       return d.label
      //     }),
      //   ])
      const xAxisYears = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.4)
        .domain(
          data.map(d => d.label)
        )
        
      const xAxis5Years = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.4)
        .domain(
          data.filter(d => this.isRoundYear(d.label)).map(function (d) {
            return d.label
          })
        )
      barPlotSvg
        .append('g')
        .attr('class', 'xAxis')
        .attr('transform', `translate(0, ${barPlotHeight})`)
        .call(d3.axisBottom(xAxis5Years))
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
        .range([barPlotHeight - 10, 0])
        .domain([
          d3.min(data, function (d) {
            return Math.min(...[d.min, d.max, d.val])
          }),
          d3.max(data, function (d) {
            return Math.max(...[d.min, d.max, d.val])
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
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
            )
        )
        .call((g) => g.selectAll('line[x2="-6"]').style('opacity', 0))
      // Set Y axis label
      barPlotSvg
        .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('x', -(barPlotWidth / 2))
        .attr('y', -margin.left + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text("Indice d'abondance")
      // Delete axis lines
      barPlotSvg.selectAll('path').style('opacity', 0)
      // Lines and points
      barPlotSvg
        .append('g')
        .attr('class', 'bars')
        .selectAll('rect')
        .data(data)
        .enter()
        .append('rect')
        .attr('class', 'bar')
        .attr('x', function (d) {
          return xAxisYears(d.label)
        })
        .attr('y', function (d) {
          console.log(d.val)
          return yAxis(d.val)
        })
        .attr('width', xAxisYears.bandwidth()+5)
        .attr('height', function (d) {
          return barPlotHeight - yAxis(d.val)
        })
        .attr('fill', '#435EF2')
      // barPlotSvg
      //   .append('g')
      //   .attr('class', 'dots')
      //   .selectAll('dot')
      //   .data(data)
      //   .enter()
      //   .append('circle')
      //   .attr('cx', function (d) {
      //     return xAxisYears(d.label)
      //   })
      //   .attr('cy', function (d) {
      //     return yAxis(d.val)
      //   })
      //   .attr('r', 4)
      //   .attr('fill', '#435EF2')
    },
  },
}
</script>
