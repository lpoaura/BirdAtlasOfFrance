<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <svg class="BarPlotSvg"></svg>
    </div>
    <div class="ChartLegend">
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.color }"></i
        >{{ formattedData.label }}
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
      required: true,
    },
  },
  mounted() {
    // Get bar plot size
    const margin = { top: 10, right: 0, bottom: 24, left: 66 }
    const minWidth = 16 * 30 + margin.left + margin.right
    const barPlotWidth = Math.max(
      parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right,
      minWidth
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
    const bandWidth = barPlotWidth / this.formattedData.data.length - 4
    const xAxis = d3
      .scaleLinear()
      .range([bandWidth / 2 + 8, barPlotWidth - bandWidth / 2])
      .domain([
        d3.min(this.formattedData.data, function (d) {
          return d.label
        }),
        d3.max(this.formattedData.data, function (d) {
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
    barPlotSvg
      .append('g')
      .attr('class', 'xAxis')
      .attr('transform', `translate(0, ${barPlotHeight})`)
      .call(
        d3
          .axisBottom(xAxis)
          .tickFormat(formatter)
      )
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
        d3.max(this.formattedData.data, function (d) {
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
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
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
      .text(this.formattedData.label)
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Bars
    barPlotSvg
      .append('g')
      .attr('class', 'bars')
      .selectAll('rect')
      .data(this.formattedData.data)
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
        return barPlotHeight - yAxis(d.count_data)
      })
      .attr('fill', this.formattedData.color)
  },
}
</script>
