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
        <i :style="{ background: formattedData.prenuptial.colors.quantile }"></i
        >{{ formattedData.prenuptial.label }}
      </h5>
      <h5 class="ChartLegendLabel">
        <i
          :style="{ background: formattedData.postnuptial.colors.quantile }"
        ></i
        >{{ formattedData.postnuptial.label }}
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
    const margin = { top: 20, right: 0, bottom: 24, left: 66 }
    const barPlotWidth = Math.max(
      parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right,
      500
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
    const yAxis = d3
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
      .text('Nombre de données')
    // Delete axis lines
    barPlotSvg.selectAll('path').style('opacity', 0)
    // Quantiles
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
      .attr('fill', this.formattedData.prenuptial.colors.quantile)
    barPlotSvg
      .append('line')
      .attr('class', 'median')
      .attr(
        'x1',
        xAxisDecades(this.formattedData.prenuptial.data[1]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr(
        'x2',
        xAxisDecades(this.formattedData.prenuptial.data[1]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y1', 0)
      .attr('y2', barPlotHeight)
      .attr('stroke-width', 4)
      .style('stroke-dasharray', '4,5')
      .style('stroke', '#39765A')
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
      .attr('fill', this.formattedData.postnuptial.colors.quantile)
    barPlotSvg
      .append('line')
      .attr('class', 'median')
      .attr(
        'x1',
        xAxisDecades(this.formattedData.postnuptial.data[1]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr(
        'x2',
        xAxisDecades(this.formattedData.postnuptial.data[1]) +
          xAxisDecades.bandwidth() / 2
      )
      .attr('y1', 0)
      .attr('y2', barPlotHeight)
      .attr('stroke-width', 4)
      .style('stroke-dasharray', '4,5')
      .style('stroke', '#EB6A0A')
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
        return yAxis(d.count_data)
      })
      .attr('width', xAxisDecades.bandwidth())
      .attr('height', function (d) {
        return barPlotHeight - yAxis(d.count_data)
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
