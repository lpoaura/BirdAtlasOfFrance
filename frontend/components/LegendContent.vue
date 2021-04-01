<template>
  <div class="MapControl">
    <div class="text-center">
      <h4>Complétude (%)</h4>
    </div>
    <i :style="{ background: featuresColors[0] }"></i>0-25%
    <br />
    <i :style="{ background: featuresColors[1] }"></i>25-50%
    <br />
    <i :style="{ background: featuresColors[2] }"></i>50-75%
    <br />
    <i :style="{ background: featuresColors[3] }"></i>75-100%
    <br />
    <i :style="{ background: featuresColors[4] }"></i>100%+
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
