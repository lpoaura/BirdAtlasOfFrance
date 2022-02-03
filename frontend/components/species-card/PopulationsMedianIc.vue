<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <svg class="BoxPlotSvg"></svg>
    </div>
    <div class="ChartLegend">
      <h5 v-if="formattedData.data[0].median" class="ChartLegendLabel">
        <i :style="{ background: formattedData.colors[1] }"></i
        >{{ formattedData.keys[1] }}
      </h5>
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.colors[0] }"></i
        >{{ formattedData.keys[0] }}
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
    const minWidth =
      this.formattedData.data.length * 72 + margin.left + margin.right
    const boxPlotWidth = Math.max(
      parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right,
      minWidth
    )
    const boxPlotHeight =
      parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
      margin.top -
      margin.bottom
    // Get bar plot svg and set size
    const boxPlotSvg = d3
      .select(this.$el)
      .select('.BoxPlotSvg')
      .attr('width', boxPlotWidth + margin.left + margin.right)
      .attr('height', boxPlotHeight + margin.top + margin.bottom)
      .append('g')
      .attr('transform', `translate(${margin.left}, ${margin.top})`)
    // Set X axis and add it
    const xAxis = d3
      .scaleBand()
      .range([0, boxPlotWidth])
      .paddingInner(1)
      .paddingOuter(0.5)
      .domain(
        this.formattedData.data.map(function (d) {
          return d.label
        })
      )
    boxPlotSvg
      .append('g')
      .attr('class', 'xAxis')
      .attr('transform', `translate(0, ${boxPlotHeight})`)
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
      .range([boxPlotHeight, 0])
      .domain([
        0,
        d3.max(this.formattedData.data, function (d) {
          return d.max
        }),
      ])
    boxPlotSvg
      .append('g')
      .attr('class', 'yAxis')
      .call(d3.axisLeft(yAxis))
      .call((g) =>
        g
          .selectAll('.tick line')
          .clone()
          .attr('x2', boxPlotWidth)
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
    boxPlotSvg
      .append('text')
      .attr('transform', 'rotate(-90)')
      .attr('x', -(boxPlotHeight / 2))
      .attr('y', -margin.left + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text(this.formattedData.label)
    // Delete axis lines
    boxPlotSvg.selectAll('path').style('opacity', 0)
    // Rectangles
    const boxWidth = 26
    boxPlotSvg
      .append('g')
      .attr('class', 'boxes')
      .selectAll('rect')
      .data(this.formattedData.data)
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
      .attr('stroke', this.formattedData.colors[0])
      .style('fill', this.formattedData.colors[0])
    // Median
    if (this.formattedData.data[0].median) {
      const medianWidth = 40
      boxPlotSvg
        .append('g')
        .attr('class', 'medians')
        .selectAll('median')
        .data(this.formattedData.data)
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
        .attr('stroke', this.formattedData.colors[1])
        .attr('stroke-width', 6)
    }
  },
}
</script>
