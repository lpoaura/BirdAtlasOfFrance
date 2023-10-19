<template>
  <div v-if="idArea && chartData && (hasFreqData || hasNbData)" id="phenology-all-period" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
    <h5 class="black03 bottom-margin-40">
      Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au 31
      décembre de l'année dernière.
    </h5>
    <div class="ChartWrapper">
      <div class="Chart"></div>
      <div class="ChartLegend">
        <h5 class="ChartLegendLabel">
          <i :style="{ background: chartData.phenology.color }"></i>{{ chartData.phenology.label }}
        </h5>
        <h5 class="ChartLegendLabel">
          <i class="round" :style="{ background: chartData.frequency.color }"></i>{{ chartData.frequency.label }}
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
    hasNbData() {
      return (
        this.chartData?.phenology.data.filter((i) => i.value > 0).length > 0
      )
    },
    hasFreqData() {
      return (
        this.chartData?.frequency.data.filter((i) => i.value > 0).length > 0
      )
    },
  },
  watch: {
    idArea(newVal) {
      if (newVal) {
        this.generateChart()
      }
    },
    // chartData(newVal) {
    //   if (!newVal) {
    //     this.$store.commit('species/removeSubjectsList', this.subject)
    //   }
    // },
  },
  mounted() {
    this.$nextTick(function () {
      this.generateChart()
    })
  },
  methods: {
    generateChart() {
      this.getChartData().then(() => {
        if (this.chartData && (this.hasFreqData || this.hasNbData)) {
          this.renderChart()
        }
        console.log('pheno allperiod', !!this.chartData, this.hasFreqData, this.hasNbData)
        this.$store.commit('species/pushSubjectsList', {
          label: 'Phénologie',
          slug: 'phenology-all-period',
          position: 1,
          status: !!this.chartData && (this.hasFreqData || this.hasNbData),
        })
      })
    },
    async getChartData() {
      if (this.idArea) {
        const requestParams = {
          cd_nom: this.cdNom,
          id_area: this.idArea,
          period: 'all_period',
        }
        const url = `/api/v1/taxa/chart/phenology`
        this.chartData = await this.$axios
          .$get(url, {
            params: requestParams,
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
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

      // Bars
      const xAxisDecades = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.9)
        .domain(
          this.chartData.phenology.data.map(function (d) {
            return d.label
          })
        )
      // Set left Y axis and add it
      if (this.hasNbData) {
        const yAxisLeft = d3
          .scaleLinear()
          .range([barPlotHeight, 0])
          .domain([
            0,
            d3.max(this.chartData.phenology.data, function (d) {
              return d.value
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
          .text(this.chartData.phenology.label)

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
            return yAxisLeft(d.value)
          })
          .attr('width', xAxisDecades.bandwidth())
          .attr('height', function (d) {
            return barPlotHeight - yAxisLeft(d.value)
          })
          .attr('fill', this.chartData.phenology.color)
      }
      // Set right Y axis and add it
      if (this.hasFreqData) {
        const yAxisRight = d3
          .scaleLinear()
          .range([barPlotHeight, 0])
          .domain([
            0,
            d3.max(this.chartData.frequency.data, function (d) {
              return d.value
            }) > 0
              ? d3.max(this.chartData.frequency.data, function (d) {
                return d.value
              })
              : 1,
          ])
        const ticksNumber = Math.round(
          d3.selectAll('.yAxisLeft .tick')._groups[0].length / 2
        )
        barPlotSvg
          .append('g')
          .attr('class', 'yAxisRight')
          .attr('transform', `translate(${barPlotWidth}, 0)`)
          // .call(d3.axisRight(yRight).tickValues([0, 5, 10, 15, 20, 25, 30]))
          .call(d3.axisRight(yAxisRight).ticks(ticksNumber))
          .call((g) =>
            g
              .selectAll('text')
              .attr(
                'style',
                "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
              )
          )
          .call((g) => g.selectAll('line[x2="6"]').style('opacity', 0))
        // Set right Y axis label
        barPlotSvg
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('x', -(barPlotHeight / 2))
          .attr('y', barPlotWidth + margin.right - 5)
          .attr(
            'style',
            "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
          )
          .text('Fréquence (%)')

        barPlotSvg
          .append('path')
          .attr('class', 'line')
          .datum(this.chartData.frequency.data)
          .attr('fill', 'none')
          .attr('stroke', this.chartData.frequency.color)
          .attr('stroke-width', 2)
          // .attr('stroke-linecap', 'round')
          // .attr('stroke-linejoin', 'round')
          .attr(
            'd',
            d3
              .line()
              // .curve(d3.curveBumpX)
              .curve(d3.curveNatural)
              .x(function (d) {
                return xAxisDecades(d.label)
              })
              .y(function (d) {
                return yAxisRight(d.value)
              })
          )
        barPlotSvg
          .append('g')
          .attr('class', 'dots')
          .selectAll('dot')
          .data(this.chartData.frequency.data)
          .enter()
          .append('circle')
          .attr('cx', function (d) {
            return xAxisDecades(d.label)
          })
          .attr('cy', function (d) {
            return yAxisRight(d.value)
          })
          .attr('r', 4)
          .attr('fill', this.chartData.frequency.color)
      }
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
