<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <svg class="BarPlotSvg"></svg>
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
      required: true,
    },
  },
  mounted() {
    // Get bar plot size
    const margin = { top: 10, right: 0, bottom: 24, left: 70 }
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
    const xAxis = d3
      .scaleLinear()
      .range([0, barPlotWidth])
      .domain([
        0,
        d3.max(this.formattedData.altitude.data, function (d) {
          return d.altitude
        }),
      ])
    barPlotSvg
      .append('g')
      .attr('class', 'xAxis')
      .attr('transform', `translate(0, ${barPlotHeight})`)
      .call(
        d3.axisBottom(xAxis).tickFormat(function (d) {
          return `${d}%`
        })
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
        d3.max(this.formattedData.altitude.data, function (d) {
          return d.label
        }),
      ])
    const formatter = d3
      .formatLocale({
        decimal: '.',
        thousands: ' ',
        grouping: [3],
        currency: ['', ''],
      })
      .format(',.0f')
    barPlotSvg
      .append('g')
      .attr('class', 'yAxis')
      .call(d3.axisLeft(yAxis).tickFormat(formatter))
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
      .text('Altitude (mètres)')
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Bars
    barPlotSvg
      .append('g')
      .attr('class', 'bars')
      .selectAll('rect')
      .data(this.formattedData.altitude.data)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', function (d) {
        return xAxis(0)
      })
      .attr('y', function (d) {
        return yAxis(d.label)
      })
      .attr('width', function (d) {
        return xAxis(d.altitude)
      })
      .attr('height', 2)
      .attr('fill', this.formattedData.altitude.color)
    // Lines
    barPlotSvg
      .append('path')
      .attr('class', 'area')
      .datum(this.formattedData.globalAltitude.data)
      .attr('fill', this.formattedData.globalAltitude.color)
      .attr('stroke-width', 0)
      .attr(
        'd',
        d3
          .area()
          .x0(xAxis(0))
          .x1(function (d) {
            return xAxis(d.altitude)
          })
          .y(function (d) {
            return yAxis(d.label)
          })
      )
  },
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
