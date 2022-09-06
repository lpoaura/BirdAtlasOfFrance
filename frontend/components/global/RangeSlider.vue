<template>
  <input
    type="range"
    :min="min"
    :max="max"
    :value="number"
    :style="{ background: background }"
    class="slider"
    @input="update"
  />
  <!-- @input="$emit('change', $event.target.value)" -->
</template>

<script>
export default {
  model: {
    prop: 'number',
    event: 'change',
  },
  props: {
    number: {
      type: String,
      required: true,
    },
    min: {
      type: Number,
      required: true,
    },
    max: {
      type: Number,
      required: true,
    },
  },
  data: () => ({
    background:
      'linear-gradient(to right, #eece25 0%, #eece25 50%, rgba(38, 38, 38, 0.1) 50%, rgba(38, 38, 38, 0.1) 100%)',
  }),
  mounted() {
    const percentage = ((this.number - this.min) / (this.max - this.min)) * 100
    this.background =
      'linear-gradient(to right, #eece25 0%, #eece25 ' +
      percentage +
      '%, rgba(38, 38, 38, 0.1) ' +
      percentage +
      '%, rgba(38, 38, 38, 0.1) 100%)'
  },
  methods: {
    update(event) {
      this.$emit('change', event.target.value)
      const percentage =
        ((event.target.value - this.min) / (this.max - this.min)) * 100
      this.background =
        'linear-gradient(to right, #eece25 0%, #eece25 ' +
        percentage +
        '%, rgba(38, 38, 38, 0.1) ' +
        percentage +
        '%, rgba(38, 38, 38, 0.1) 100%)'
    },
  },
}
</script>

<style scoped>
input[type='range'] {
  appearance: none;
  width: 100%;
  height: 4px;
  margin-top: 10px;
  background-color: #eece25;
  border-radius: 40px;
  outline: none;
  transition: background 450ms ease-in;
}

/* Chrome */
input[type='range']::-webkit-slider-thumb {
  appearance: none;
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border-radius: 50%;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-sizing: border-box;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

/* Mozilla Firefox */
input[type='range']::-moz-range-thumb {
  appearance: none;
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-sizing: border-box;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

/* IE */
input[type='range']::-ms-thumb {
  appearance: none;
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-sizing: border-box;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

/* Pure CSS solution for the track (Mozilla Firefox and Internet Explorer) */

/* Mozilla Firefox
input[type='range']::-moz-range-progress {
  background-color: #eece25;
  height: 4px;
  border-radius: 40px;
  outline: none;
}
input[type='range']::-moz-range-track {
  background: linear-gradient(rgba(38, 38, 38, 0.1), rgba(38, 38, 38, 0.1)),
    white;
  height: 4px;
  border-radius: 40px;
  outline: none;
} */

/* Internet Explorer
input[type='range']::-ms-fill-lower {
  background-color: #eece25;
  height: 4px;
  border-radius: 40px;
  outline: none;
}
input[type='range']::-ms-fill-upper {
  background: linear-gradient(rgba(38, 38, 38, 0.1), rgba(38, 38, 38, 0.1)),
    white;
  height: 4px;
  border-radius: 40px;
  outline: none;
} */
</style>
