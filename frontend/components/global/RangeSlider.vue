<template>
  <div style="display: flex; justify-content: center">
    <input type="range" min="0" max="100" value="50" class="slider" />
  </div>
</template>

<style scoped>
input[type='range'] {
  /* overflow: hidden; */
  -webkit-appearance: none;
  background-color: #eece25;
  height: 4px;
  border-radius: 40px;
  outline: none;
}

/* Chrome */

/* @media screen and (-webkit-min-device-pixel-ratio: 0) {
  input[type='range'] {
    overflow: hidden;
    -webkit-appearance: none;
    background-color: #9a905d;
  }

  input[type='range']::-webkit-slider-runnable-track {
    height: 10px;
    -webkit-appearance: none;
    color: #13bba4;
    margin-top: -1px;
  }

  input[type='range']::-webkit-slider-thumb {
    width: 10px;
      -webkit-appearance: none;
      height: 10px;
      cursor: ew-resize;
      background: #434343;
      box-shadow: -80px 0 0 80px #43e5f7;
  }
} */

/* input[type='range']::-webkit-slider-runnable-track {
  -webkit-appearance: none;
  background: rgba(38, 38, 38, 0.1);
  height: 12px;
} */

input[type='range']::-webkit-slider-thumb {
  /* margin-top: -4px; */
  -webkit-appearance: none;
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border-radius: 50%;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-sizing: border-box;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

/* Firefox */
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
}
input[type='range']::-moz-range-thumb {
  -webkit-appearance: none;
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-sizing: border-box;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}

/* IE  */
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
}
input[type='range']::-ms-thumb {
  -webkit-appearance: none;
  width: 12px;
  height: 12px;
  background: #fcfcfc;
  border: 2px solid rgba(238, 206, 37, 0.8);
  box-sizing: border-box;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  cursor: pointer;
}
</style>
