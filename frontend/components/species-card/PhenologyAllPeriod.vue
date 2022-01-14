<template>
  <div class="PhenologyAllPeriodBarPlot">
    <svg class="BarPlotSvg"></svg>
  </div>
</template>

<script>
const d3 = require('d3')

export default {
  data: () => ({
    formattedData: [
      { label: 'D1', count_data: 0 },
      { label: 'D2', count_data: 0 },
      { label: 'D3', count_data: 0 },
      { label: 'D4', count_data: 0 },
      { label: 'D5', count_data: 0 },
      { label: 'D6', count_data: 0 },
      { label: 'D7', count_data: 0 },
      { label: 'D8', count_data: 10 },
      { label: 'D9', count_data: 20 },
      { label: 'D10', count_data: 30 },
      { label: 'D11', count_data: 40 },
      { label: 'D12', count_data: 50 },
      { label: 'D13', count_data: 60 },
      { label: 'D14', count_data: 70 },
      { label: 'D15', count_data: 90 },
      { label: 'D16', count_data: 120 },
      { label: 'D17', count_data: 250 },
      { label: 'D18', count_data: 370 },
      { label: 'D19', count_data: 550 },
      { label: 'D20', count_data: 360 },
      { label: 'D21', count_data: 290 },
      { label: 'D22', count_data: 270 },
      { label: 'D23', count_data: 200 },
      { label: 'D24', count_data: 150 },
      { label: 'D25', count_data: 90 },
      { label: 'D26', count_data: 55 },
      { label: 'D27', count_data: 40 },
      { label: 'D28', count_data: 15 },
      { label: 'D29', count_data: 0 },
      { label: 'D30', count_data: 0 },
      { label: 'D31', count_data: 0 },
      { label: 'D32', count_data: 0 },
      { label: 'D33', count_data: 0 },
      { label: 'D34', count_data: 0 },
      { label: 'D35', count_data: 0 },
      { label: 'D36', count_data: 0 },
    ],
  }),
  mounted() {
    // Get bar plot size
    const margin = { top: 10, right: 40, bottom: 24, left: 40 }
    // setTimeout(() => {
    console.log(d3.select('.PhenologyAllPeriodBarPlot').style('width'))
    // }, 5000)
    const barPlotWidth = Math.max(
      parseFloat(d3.select('.PhenologyAllPeriodBarPlot').style('width')) -
        margin.left -
        margin.right,
      360
    )
    const barPlotHeight = 300 - margin.top - margin.bottom
    // Get bar plot svg and set size
    const barPlotSvg = d3
      .select('.BarPlotSvg')
      .attr('width', barPlotWidth + margin.left + margin.right)
      .attr('height', barPlotHeight + margin.top + margin.bottom)
      .append('g')
      .attr('transform', `translate(${margin.left}, ${margin.top})`)
    // Set X axis and add it
    const x = d3
      .scaleBand()
      .range([0, barPlotWidth])
      .padding(0.2)
      .domain(
        this.formattedData.map(function (d) {
          return d.label
        })
      )
    barPlotSvg
      .append('g')
      .attr('transform', `translate(0, ${barPlotHeight})`)
      .call(d3.axisBottom(x))
      .call((g) =>
        g
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
      )
      // .call((g) => g.selectAll('line[y2]').style('opacity', 0))
    // Set Y axis and add it
    const y = d3
      .scaleLinear()
      .range([barPlotHeight, 0])
      .domain([
        0,
        d3.max(this.formattedData, function (d) {
          return d.count_data
        }),
      ])
    barPlotSvg
      .append('g')
      .attr('class', 'yAxis')
      .call(d3.axisLeft(y))
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
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
      )
      .call((g) => g.selectAll('line[x2]').style('opacity', 0))
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Bars
    barPlotSvg
      .selectAll('rect')
      .data(this.formattedData)
      .enter()
      .append('rect')
      .attr('class', 'bars')
      .attr('x', function (d) {
        return x(d.label)
      })
      .attr('y', function (d) {
        return y(d.count_data)
      })
      .attr('width', 3)
      .attr('height', function (d) {
        return barPlotHeight - y(d.count_data)
      })
      .attr('fill', '#435EF2')
  },
}
</script>

<style scoped>
.PhenologyAllPeriodBarPlot {
  width: 100%;
}
</style>
