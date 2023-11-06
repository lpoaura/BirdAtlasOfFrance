<template>
  <div v-if="idArea && chartData?.length > 1" id="trend" class="ChartCard">
    <h4 class="black02 fw-bold bottom-margin-8">Tendance d'évolution</h4>
    <h5 class="black03 bottom-margin-40">
      Évolution de l’indice d’abondance en fonction des années.
    </h5>
    <div class="ChartWrapper">
      <!-- <div class="TrendsWrapper">
        <div class="TrendCard">
          <h5 class="black02 fw-500">Long terme 1980-2020</h5>
          <h5 class="black02">Forte augmentation<br />+8.0% p.a. ±ES0.2%</h5>
        </div>
        <div class="TrendCard">
          <h5 class="black02 fw-500">Court terme 2009-2020</h5>
          <h5 class="black02">Augmentation modérée<br />+2.5% p.a. ±ES0.5%</h5>
        </div>
      </div> -->
      <div class="Chart">
        <svg class="LinePlotSvg"></svg>
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
    phenologyPeriod() {
      return this.$store.state.species.selectedSeason?.value
    },
  },
  watch: {
    idArea: {
      handler() {
        this.generateChart()
      },
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
        if (this.chartData?.length > 1) {
          this.renderChart()
        }
        this.$store.commit('species/pushSubjectsList', {
          label: "Tendance d'évolution",
          slug: 'trend',
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
          chart_type: 'trend',
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
    renderChart() {
      // const divId = 'trend-chart-tooltip'
      // document.getElementById(divId)?.remove()
      // const div = d3
      //   .select('body')
      //   .append('div')
      //   .attr('class', 'chart-tooltip')
      //   .attr('id', divId)
      //   .style('opacity', 0)

      d3.select(this.$el).select('.LinePlotSvg').remove()
      d3.select(this.$el)
        .select('.Chart')
        .append('svg')
        .attr('class', 'LinePlotSvg')
      const data = this.chartData.map((i) => {
        return {
          label: i.year,
          min: i.data.val_min,
          max: i.data.val_max,
          val: i.data.val,
        }
      })
      // Get bar plot size
      const margin = { top: 10, right: 0, bottom: 24, left: 66 }
      // const minWidth = trend.length * 30 + margin.left + margin.right
      // const linePlotWidth = Math.max(
      //   parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
      //     margin.left -
      //     margin.right,
      //   minWidth
      // )
      const linePlotWidth =
        parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right
      const linePlotHeight =
        parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
        margin.top -
        margin.bottom
      // Get bar plot svg and set size
      const linePlotSvg = d3
        .select(this.$el)
        .select('.LinePlotSvg')
        .attr('width', linePlotWidth + margin.left + margin.right)
        .attr('height', linePlotHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left}, ${margin.top})`)
      // Set X axis and add it
      const xAxisYears = d3
        .scaleBand()
        .range([0, linePlotWidth])
        .padding(0.4)
        .domain(data.map((d) => d.label))

      const xAxis5Years = d3
        .scaleBand()
        .range([0, linePlotWidth])
        .padding(0.4)
        .domain(
          data
            .filter((d) => d.label % 5 === 0)
            .map(function (d) {
              return d.label
            })
        )
      linePlotSvg
        .append('g')
        .attr('class', 'xAxis')
        .attr('transform', `translate(0, ${linePlotHeight})`)
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
        .range([linePlotHeight - 10, 0])
        .domain([
          d3.min(data, function (d) {
            return Math.min(...[d.min, d.max, d.val])
          }),
          d3.max(data, function (d) {
            return Math.max(...[d.min, d.max, d.val])
          }),
        ])
      linePlotSvg
        .append('g')
        .attr('class', 'yAxis')
        .call(d3.axisLeft(yAxis))
        .call((g) =>
          g
            .selectAll('.tick line')
            .clone()
            .attr('x2', linePlotWidth)
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
      linePlotSvg
        .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('x', -(linePlotHeight / 2))
        .attr('y', -margin.left + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text("Indice d'abondance")
      // Delete axis lines
      linePlotSvg.selectAll('path').style('opacity', 0)
      // Lines and points
      linePlotSvg
        .append('path')
        .attr('class', 'line')
        .datum(data)
        .attr('fill', 'none')
        .attr('stroke', '#435EF2')
        .attr('stroke-width', 2)
        .attr(
          'd',
          d3
            .line()
            .x(function (d) {
              return xAxisYears(d.label)
            })
            .y(function (d) {
              return yAxis(d.val)
            })
        )
        

      linePlotSvg
        .append('g')
        .attr('class', 'dots')
        .selectAll('circle')
        .data(data)
        .enter()
        .append('circle')
        .attr('cx', function (d) {
          return xAxisYears(d.label)
        })
        .attr('cy', function (d) {
          return yAxis(d.val)
        })
        .attr('r', 4)
        .attr('fill', '#435EF2')
        // .on('mouseover', function (event, d, i) {
        //   div.transition().duration(200).style('opacity', 0.9)
        //   console.log(event, d, i)
        //   div
        //     .html(
        //       `<p class="tooltip-title"><strong>${d.label}</strong></p>
        //         ${d.unit}&nbsp;: ${d.val}`
        //     )
        //     .style('left', event.pageX + 30 + 'px')
        //     .style('top', event.pageY - 30 + 'px')
        // })
        // .on('mouseout', function (event, d) {
        //   div.style('opacity', 0)
        //   div.html('').style('left', '-500px').style('top', '-500px')
        // })

        
      // Area
      linePlotSvg
        .append('path')
        .attr('class', 'area')
        .datum(data)
        .attr('fill', 'rgba(67, 94, 242, 0.1)')
        .attr('stroke-width', 0)
        .attr(
          'd',
          d3
            .area()
            .x(function (d) {
              return xAxisYears(d.label)
            })
            .y0(function (d) {
              return yAxis(d.min)
            })
            .y1(function (d) {
              return yAxis(d.max)
            })
        )
    },
  },
}
</script>

<style scoped>
.TrendsWrapper {
  margin-bottom: 16px;
  display: grid !important;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  grid-gap: 16px;
}

.TrendCard {
  min-width: 200px;
  background: linear-gradient(
    93.58deg,
    rgba(100, 120, 226, 0.1) 0%,
    rgba(67, 94, 242, 0.1) 100%
  );
  padding: 12px 16px;
  border-radius: 8px;
  white-space: nowrap;
}
</style>
