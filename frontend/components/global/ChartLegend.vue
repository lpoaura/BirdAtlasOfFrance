<template>
  <div class="ChartLegend">
    <span
      v-for="(item, index) in chartLegendItems"
      :key="index"
      class="ChartLegendLabel"
    >
      <i :style="{ background: item.color }"></i>
      {{ item.label }}
    </span>
  </div>
</template>

<script>
export default {
  data: () => ({
    chartLegendItems: [
      { label: 'Généralistes', color: '#CE1717' },
      { label: 'Milieux forestiers', color: '#0BCCCC' },
      { label: 'Toutes espèces', color: '#70149F' },
      { label: 'Milieux bâtis', color: '#6E9D9D' },
      { label: 'Milieux agricoles', color: '#167216' },
    ],
  }),
}
</script>

<style scoped>
.ChartLegend {
  width: 100%;
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
}

.ChartLegendLabel {
  margin-right: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 10px;
  line-height: 15px;
  color: #000;
  white-space: nowrap;
}

.ChartLegendLabel:last-child {
  margin-right: 0;
}

.ChartLegendLabel i {
  width: 14px;
  height: 14px;
  border-radius: 2px;
  float: left;
  margin-right: 8px;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
  .ChartLegend {
    margin-bottom: 16px;
  }
}

@media screen and (max-width: 600px) {
  .ChartLegend {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(105px, 1fr));
    grid-gap: 16px;
  }

  .ChartLegendLabel {
    margin-right: 0;
  }
}
</style>
