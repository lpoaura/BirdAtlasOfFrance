<template>
  <div class="mapLegend">
    <div class="text-center">
      <h4>Complétude (%)</h4>
    </div>
    <i :style="{ background: featuresColors[0] }"></i>0 - 0.1
    <br />
    <i :style="{ background: featuresColors[1] }"></i>0.1 - 0.2
    <br />
    <i :style="{ background: featuresColors[2] }"></i>0.2 - 0.5
    <br />
    <i :style="{ background: featuresColors[3] }"></i>0.5 - 1
    <br />
    <i :style="{ background: featuresColors[4] }"></i>1+
  </div>
</template>

<script>
export default {
  props: {
    featuresColors: {
      type: Array,
      required: true,
    },
  },
}
</script>

<style scoped>
.mapLegend {
  padding: 10px 10px;
  background-color: rgba(255, 255, 255, 1);
  border-color: rgb(255, 255, 255);
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
  border-radius: 5px;
}
.mapLegend i {
  width: 18px;
  height: 18px;
  float: left;
  margin-right: 10px;
  opacity: 0.6;
}
</style>
