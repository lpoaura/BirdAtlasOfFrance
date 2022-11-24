<template>
  <div class="ChartWrapper">
    <div class="Chart">
      <svg class="BarPlotSvg"></svg>
    </div>
    <div class="ChartLegend">
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.phenology.color }"></i
        >{{ formattedData.phenology.label }}
      </h5>
      <h5 class="ChartLegendLabel">
        <i
          class="round"
          :style="{ background: formattedData.frequency.color }"
        ></i
        >{{ formattedData.frequency.label }}
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
  mounted() {
    console.log('ChartPhenoAllPeriod', this.formattedData)
    // Get bar plot size
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
        'Déc'
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
    // Set left Y axis and add it
    const yAxisLeft = d3
      .scaleLinear()
      .range([barPlotHeight, 0])
      .domain([
        0,
        d3.max(this.formattedData.phenology.data, function (d) {
          return d.value
        })
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
      .text(this.formattedData.phenology.label)
    // Set right Y axis and add it
    const yAxisRight = d3
      .scaleLinear()
      .range([barPlotHeight, 0])
      .domain([
        0,
        d3.max(this.formattedData.frequency.data, function (d) {
          return d.value
        }) > 0
          ? d3.max(this.formattedData.frequency.data, function (d) {
              return d.value
            })
          : 1
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
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Bars
    const xAxisDecades = d3
      .scaleBand()
      .range([0, barPlotWidth])
      .padding(0.9)
      .domain(
        this.formattedData.phenology.data.map(function (d) {
          return d.label
        })
      )
    barPlotSvg
      .append('g')
      .attr('class', 'bars')
      .selectAll('rect')
      .data(this.formattedData.phenology.data)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', function (d) {
        return xAxisDecades(d.label)
      })
      .attr('y', function (d) {
        console.log(d.value, yAxisLeft(d.value))
        return yAxisLeft(d.value)
      })
      .attr('width', xAxisDecades.bandwidth())
      .attr('height', function (d) {
        return barPlotHeight - yAxisLeft(d.value)
      })
      .attr('fill', this.formattedData.phenology.color)
    // Lines and points
    barPlotSvg
      .append('path')
      .attr('class', 'line')
      .datum(this.formattedData.frequency.data)
      .attr('fill', 'none')
      .attr('stroke', this.formattedData.frequency.color)
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
      .data(this.formattedData.frequency.data)
      .enter()
      .append('circle')
      .attr('cx', function (d) {
        return xAxisDecades(d.label)
      })
      .attr('cy', function (d) {
        return yAxisRight(d.value)
      })
      .attr('r', 4)
      .attr('fill', this.formattedData.frequency.color)
  }
}
</script>
