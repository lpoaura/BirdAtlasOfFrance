<template>
  <div class="mapControl">
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
