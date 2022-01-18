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
        <i :style="{ background: formattedData.prenuptial.color }"></i
        >{{ formattedData.prenuptial.label }}
      </h5>
      <h5 class="ChartLegendLabel">
        <i :style="{ background: formattedData.postnuptial.color }"></i
        >{{ formattedData.postnuptial.label }}
      </h5>
    </div>
  </div>
</template>

<script>
const d3 = require('d3')

export default {
  data: () => ({
    formattedData: {
      phenology: {
        label: 'Nombre de données en migration active',
        data: [
          { label: 'D1', count_data: 0 },
          { label: 'D2', count_data: 0 },
          { label: 'D3', count_data: 0 },
          { label: 'D4', count_data: 0 },
          { label: 'D5', count_data: 0 },
          { label: 'D6', count_data: 0 },
          { label: 'D7', count_data: 5 },
          { label: 'D8', count_data: 10 },
          { label: 'D9', count_data: 15 },
          { label: 'D10', count_data: 80 },
          { label: 'D11', count_data: 110 },
          { label: 'D12', count_data: 380 },
          { label: 'D13', count_data: 560 },
          { label: 'D14', count_data: 385 },
          { label: 'D15', count_data: 270 },
          { label: 'D16', count_data: 150 },
          { label: 'D17', count_data: 55 },
          { label: 'D18', count_data: 20 },
          { label: 'D19', count_data: 0 },
          { label: 'D20', count_data: 0 },
          { label: 'D21', count_data: 0 },
          { label: 'D22', count_data: 0 },
          { label: 'D23', count_data: 0 },
          { label: 'D24', count_data: 5 },
          { label: 'D25', count_data: 80 },
          { label: 'D26', count_data: 285 },
          { label: 'D27', count_data: 410 },
          { label: 'D28', count_data: 505 },
          { label: 'D29', count_data: 560 },
          { label: 'D30', count_data: 360 },
          { label: 'D31', count_data: 250 },
          { label: 'D32', count_data: 205 },
          { label: 'D33', count_data: 40 },
          { label: 'D34', count_data: 0 },
          { label: 'D35', count_data: 0 },
          { label: 'D36', count_data: 0 },
        ],
        color: '#435EF2',
      },
      prenuptial: {
        label: 'Migration prénuptiale',
        data: ['D10', 'D13', 'D16'],
        color: 'rgba(57, 118, 90, 0.1)',
      },
      postnuptial: {
        label: 'Migration postnuptiale',
        data: ['D26', 'D29', 'D32'],
        color: 'rgba(235, 106, 10, 0.1)',
      },
    },
  }),
  mounted() {
    // Get bar plot size
    const margin = { top: 20, right: 0, bottom: 24, left: 60 }
    const barPlotWidth = Math.max(
      parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right,
      360
    )
    const barPlotHeight = 320 - margin.top - margin.bottom
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
      .padding(0.26)
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
    const yAxisLeft = d3
      .scaleLinear()
      .range([barPlotHeight, 0])
      .domain([
        0,
        d3.max(this.formattedData.phenology.data, function (d) {
          return d.count_data
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
      .text('Nombre de données')
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Quantiles
    const xAxisDecades = d3
      .scaleBand()
      .range([0, barPlotWidth])
      .padding(0.8)
      .domain(
        this.formattedData.phenology.data.map(function (d) {
          return d.label
        })
      )
    barPlotSvg
      .append('rect')
      .attr('class', 'quantiles')
      .attr(
        'x',
        xAxisDecades(this.formattedData.prenuptial.data[0]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', 0)
      .attr(
        'width',
        xAxisDecades(this.formattedData.prenuptial.data[2]) -
          xAxisDecades(this.formattedData.prenuptial.data[0])
      )
      .attr('height', barPlotHeight)
      .attr('fill', this.formattedData.prenuptial.color)
    barPlotSvg
      .append('text')
      .attr(
        'x',
        xAxisDecades(this.formattedData.prenuptial.data[0]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', -margin.top + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('5%')
    barPlotSvg
      .append('text')
      .attr(
        'x',
        xAxisDecades(this.formattedData.prenuptial.data[1]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', -margin.top + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('Médiane')
    barPlotSvg
      .append('text')
      .attr(
        'x',
        xAxisDecades(this.formattedData.prenuptial.data[2]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', -margin.top + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('95%')
    barPlotSvg
      .append('rect')
      .attr('class', 'quantiles')
      .attr(
        'x',
        xAxisDecades(this.formattedData.postnuptial.data[0]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', 0)
      .attr(
        'width',
        xAxisDecades(this.formattedData.postnuptial.data[2]) -
          xAxisDecades(this.formattedData.postnuptial.data[0])
      )
      .attr('height', barPlotHeight)
      .attr('fill', this.formattedData.postnuptial.color)
    barPlotSvg
      .append('text')
      .attr(
        'x',
        xAxisDecades(this.formattedData.postnuptial.data[0]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', -margin.top + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('5%')
    barPlotSvg
      .append('text')
      .attr(
        'x',
        xAxisDecades(this.formattedData.postnuptial.data[1]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', -margin.top + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('Médiane')
    barPlotSvg
      .append('text')
      .attr(
        'x',
        xAxisDecades(this.formattedData.postnuptial.data[2]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y', -margin.top + 10)
      .attr(
        'style',
        "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
      )
      .text('95%')
    // Bars
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
        return yAxisLeft(d.count_data)
      })
      .attr('width', xAxisDecades.bandwidth())
      .attr('height', function (d) {
        return barPlotHeight - yAxisLeft(d.count_data)
      })
      .attr('fill', this.formattedData.phenology.color)
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
