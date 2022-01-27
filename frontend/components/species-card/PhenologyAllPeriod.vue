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
  data: () => ({
    formattedData: {
      phenology: {
        label: 'Nombre de données',
        data: [
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
        color: '#435EF2',
      },
      frequency: {
        label: 'Fréquence dans les listes complètes',
        data: [
          { label: 'D1', frequency: 0 },
          { label: 'D2', frequency: 0 },
          { label: 'D3', frequency: 2 },
          { label: 'D4', frequency: 4.5 },
          { label: 'D5', frequency: 5 },
          { label: 'D6', frequency: 6 },
          { label: 'D7', frequency: 8 },
          { label: 'D8', frequency: 11 },
          { label: 'D9', frequency: 12 },
          { label: 'D10', frequency: 14 },
          { label: 'D11', frequency: 14.5 },
          { label: 'D12', frequency: 16 },
          { label: 'D13', frequency: 19 },
          { label: 'D14', frequency: 24 },
          { label: 'D15', frequency: 24.5 },
          { label: 'D16', frequency: 26 },
          { label: 'D17', frequency: 28 },
          { label: 'D18', frequency: 29 },
          { label: 'D19', frequency: 26 },
          { label: 'D20', frequency: 24.5 },
          { label: 'D21', frequency: 22 },
          { label: 'D22', frequency: 21 },
          { label: 'D23', frequency: 19 },
          { label: 'D24', frequency: 17 },
          { label: 'D25', frequency: 16 },
          { label: 'D26', frequency: 14.5 },
          { label: 'D27', frequency: 9.5 },
          { label: 'D28', frequency: 7 },
          { label: 'D29', frequency: 5 },
          { label: 'D30', frequency: 4.5 },
          { label: 'D31', frequency: 4.5 },
          { label: 'D32', frequency: 3.5 },
          { label: 'D33', frequency: 2 },
          { label: 'D34', frequency: 0 },
          { label: 'D35', frequency: 0 },
          { label: 'D36', frequency: 0 },
        ],
        color: '#8CCB6E',
      },
    },
  }),
  mounted() {
    // Get bar plot size
    const margin = { top: 10, right: 60, bottom: 24, left: 60 }
    const barPlotWidth = Math.max(
      parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right,
      360
    )
    const barPlotHeight = 300 - margin.top - margin.bottom
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
    // Set left Y axis and add it
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
          return d.frequency
        }),
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
      .attr('y', barPlotWidth + margin.right - 10)
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
        return yAxisLeft(d.count_data)
      })
      .attr('width', xAxisDecades.bandwidth())
      .attr('height', function (d) {
        return barPlotHeight - yAxisLeft(d.count_data)
      })
      .attr('fill', this.formattedData.phenology.color)
    // Lines and points
    barPlotSvg
      .append('path')
      .datum(this.formattedData.frequency.data)
      .attr('fill', 'none')
      .attr('stroke', this.formattedData.frequency.color)
      .attr('stroke-width', 2)
      .attr('stroke-linecap', 'round')
      .attr('stroke-linejoin', 'round')
      .attr(
        'd',
        d3
          .line()
          .curve(d3.curveLinear)
          .x(function (d) {
            return xAxisDecades(d.label)
          })
          .y(function (d) {
            return yAxisRight(d.frequency)
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
        return yAxisRight(d.frequency)
      })
      .attr('r', 4)
      .attr('fill', this.formattedData.frequency.color)
  },
}
</script>
