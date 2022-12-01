<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <svg class="BarPlotSvg"></svg>
    </div>
    <div class="ChartLegend">
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.colors[0] }"></i
        >{{ formattedData.atlasCodes[0] }}
      </h5>
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.colors[1] }"></i
        >{{ formattedData.atlasCodes[1] }}
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
    const atlasCodes = ['firstAtlasCode', 'secondAtlasCode']
    // Get bar plot size
    const margin = { top: 10, right: 0, bottom: 24, left: 66 }
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
      .padding(0.15)
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
    // Set Y axis and add it
    const firstMax = this.formattedData.data.reduce((oldVal, newVal) =>
      oldVal.firstAtlasCode > newVal.firstAtlasCode ? oldVal : newVal
    )
    const secondMax = this.formattedData.data.reduce((oldVal, newVal) =>
      oldVal.secondAtlasCode > newVal.secondAtlasCode ? oldVal : newVal
    )
    const reference = firstMax >= secondMax ? atlasCodes[0] : atlasCodes[1]
    const yAxis = d3
      .scaleLinear()
      .range([barPlotHeight, 0])
      .domain([
        0,
        d3.max(this.formattedData.data, function (d) {
          return d[reference]
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
      .text(this.formattedData.label)
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Bars
    const xAxisDecades = d3
      .scaleBand()
      .range([0, barPlotWidth])
      .padding(0.45)
      .domain(
        this.formattedData.data.map(function (d) {
          return d.label
        })
      )
    const xAxisAtlasCodes = d3
      .scaleBand()
      .range([0, xAxisDecades.bandwidth()])
      .padding(0.5)
      .domain(atlasCodes)
    const colors = d3
      .scaleOrdinal()
      .range(this.formattedData.colors)
      .domain(atlasCodes)
    barPlotSvg
      .append('g')
      .attr('class', 'bars')
      .selectAll('g')
      .data(this.formattedData.data)
      .enter()
      .append('g')
      .attr('class', 'bars-group')
      .attr('transform', function (d) {
        return 'translate(' + xAxisDecades(d.label) + ',0)'
      })
      .selectAll('rect')
      .data(function (d) {
        return atlasCodes.map(function (key) {
          return { key, value: d[key] }
        })
      })
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', function (d) {
        return xAxisAtlasCodes(d.key)
      })
      .attr('y', function (d) {
        return yAxis(d.value)
      })
      .attr('width', xAxisAtlasCodes.bandwidth())
      .attr('height', function (d) {
        return barPlotHeight - yAxis(d.value)
      })
      .attr('fill', function (d) {
        return colors(d.key)
      })
  },
}
</script>
