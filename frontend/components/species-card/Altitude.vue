<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <!-- <svg class="BarPlotSvg"></svg> -->
    </div>
    <div class="ChartLegend">
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.altitude.color }"></i
        >{{ formattedData.altitude.label }}
      </h5>
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.globalAltitude.color }"></i
        >{{ formattedData.globalAltitude.label }}
      </h5>
    </div>
  </div>
</template>

<script>
const d3 = require('d3')
export default {
  props: {
    formattedData: {
      type: Object,
      required: true
    }
  },
  watch: {
    formattedData: {
      deep: true,
      handler() {
        this.renderChart()
        this.renderData()
      }
    }
  },
  mounted() {
    if (this.formattedData.altitude.data) {
      this.renderChart()
      this.renderData()
    }
  },
  methods: {
    renderData() {
      // Render x axis Scale using data max value
      this.xAxis.domain([
        0,
        d3.max(this.formattedData.altitude.data, function (d) {
          return d.value
        })
      ])

      // Render y axis Scale using data max value
      this.yAxis.domain([
        0,
        d3.max(this.formattedData.altitude.data, (d) => d.label)
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
          currency: ['', '']
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
        .data(this.formattedData.altitude.data)
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
        .attr('fill', this.formattedData.altitude.color)
      // Area

      this.chart
        .append('path')
        .attr('class', 'area')
        .datum(this.formattedData.globalAltitude.data)
        .attr('fill', this.formattedData.globalAltitude.color)
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
      d3.select(this.$el).select('.BarPlotSvg').remove()

      d3.select(this.$el)
        .select('.Chart')
        .append('svg')
        .attr('class', 'BarPlotSvg')
      // Get bar plot size
      this.margin = { top: 10, right: 0, bottom: 24, left: 70 }
      this.width = Math.max(
        parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
          this.margin.left -
          this.margin.right,
        420
      )
      this.height =
        parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
        this.margin.top -
        this.margin.bottom
      // Get bar plot svg and set size
      this.chart = d3
        .select(this.$el)
        .select('.BarPlotSvg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .append('g')
        .attr('transform', `translate(${this.margin.left}, ${this.margin.top})`)
      // Set X axis and add it
      this.xAxis = d3.scaleLinear().range([0, this.width - 20])
      this.yAxis = d3.scaleLinear().range([this.height, 0])
      // Bars
    }
  }
}
</script>

<style scoped>
/********** RESPONSIVE **********/

@media screen and (max-width: 510px) {
  .ChartLegend {
    display: grid !important;
    grid-template-columns: repeat(auto-fill, minmax(164px, 1fr));
    grid-gap: 16px;
  }

  .ChartLegendLabel {
    margin-right: 0 !important;
  }

  .ChartLegendLabel i {
    border: 5px solid red;
  }
}
</style>
