<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <svg id="AltitudeChart" class="BarPlotSvg"></svg>
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
      }
    }
  },
  mounted() {
    // this.renderChart()

    const margin = { top: 10, right: 0, bottom: 24, left: 70 }
    this.width = Math.max(
      parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right,
      420
    )
    console.log('width', this.width)
    this.height =
      parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
      margin.top -
      margin.bottom

    console.log('height', this.height)

    this.chart = d3
      .select(this.$el)
      .select('.BarPlotSvg')
      .append('g')
      .attr('transform', `translate(${margin.left}, ${margin.top})`)
      .attr('width', this.width + margin.left + margin.right)
      .attr('height', this.height + margin.top + margin.bottom)

    this.x = d3.scaleLinear().range([0, this.width - 20])
    this.y = d3.scaleLinear().range([this.height, 0])

    console.log('this.x', this.x(0))

    this.xAxis = this.chart
      .append('g')
      .attr('class', 'xAxis')
      .attr('transform', `translate(0, ${this.height})`)
    console.log('this.xAxis', this.xAxis)
    this.yAxis = this.chart.append('g').attr('class', 'yAxis')

    // .call(
    //   d3.axisBottom(this.xAxis).tickFormat(function (d) {
    //     return `${d}%`
    //   })
    // )
    // .call((g) =>
    //   g
    //     .selectAll('text')
    //     .attr(
    //       'style',
    //       "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
    //     )
    // )
    // .call((g) => g.selectAll('line[y2]').style('opacity', 0))

    // this.chart
    //   .append('g')
    //   .attr('class', 'yAxis')
    //   .call(d3.axisLeft(this.yAxis).tickFormat(formatter))
    //   .call((g) =>
    //     g
    //       .selectAll('.tick line')
    //       .clone()
    //       .attr('x2', width)
    //       .attr('stroke-opacity', 0.1)
    //   )
    //   .call((g) =>
    //     g
    //       .selectAll('text')
    //       .attr(
    //         'style',
    //         "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 400; font-size: 12px; line-height: 13px; color: #000;"
    //       )
    //   )
    //   .call((g) => g.selectAll('line[x2="-6"]').style('opacity', 0))
    console.log('x,y', -(this.height / 2), -margin.left + 10)
    this.chart
      .append('text')
      .attr('transform', 'rotate(-90)')
      .attr('x', -(this.height / 2))
      .attr('y', -margin.left + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('Altitude (mètres)')
    // Delete axis lines
    this.chart.selectAll('path').style('opacity', 0)
    this.renderChart()
  },
  methods: {
    renderChart() {
      const formatter = d3
        .formatLocale({
          decimal: '.',
          thousands: ' ',
          grouping: [3],
          currency: ['', '']
        })
        .format(',.0f')
      this.x.domain([
        0,
        d3.max(this.formattedData.altitude.data, function (d) {
          return d.percentage
        })
      ])
      console.log('this.x4', this.x)
      this.y.domain([
        0,
        d3.max(this.formattedData.altitude.data, function (d) {
          return d.label
        })
      ])

      this.xAxis.call(d3.axisBottom(this.x))

      this.yAxis
        .call(d3.axisLeft(this.y).tickFormat(formatter))
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
      const x = this.x
      const y = this.y
      this.chart
        .append('g')
        .attr('class', 'bars')
        .selectAll('rect')
        .data(this.formattedData.altitude.data)
        .enter()
        .append('rect')
        .attr('class', 'bar')
        .attr('x', function (d) {
          return x(0)
        })
        .attr('y', function (d) {
          return y(d.label)
        })
        .attr('width', function (d) {
          return x(d.percentage)
        })
        .attr('height', 5)
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
            .x0(x(0))
            .x1(function (d) {
              return x(d.percentage)
            })
            .y(function (d) {
              return y(d.label)
            })
        )

      // Get bar plot size
      // const margin = { top: 10, right: 0, bottom: 24, left: 70 }
      // const width = Math.max(
      //   parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
      //     margin.left -
      //     margin.right,
      //   420
      // )
      // const height =
      //   parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
      //   margin.top -
      //   margin.bottom
      // Get bar plot svg and set size
      // d3.select(this.$el).selectAll('svg').remove()
      // Set X axis and add it
      // Set Y axis and add it
      // Set Y axis label
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
}
</style>
