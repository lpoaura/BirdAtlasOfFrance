<template>
  <div v-show="loading" class="InformationControl" style="position: relative">
    <div class="Progress"></div>
    <h5 class="black02 fw-500 bottom-margin-38">Chargement des données</h5>
  </div>
</template>

<script>
export default {
  props: {
    loading: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Boolean,
      required: true,
    },
  },
}
</script>
<style>
.Progress {
  background: url('/prospecting/progress.gif') center / cover;
  background-size: 240%;
  width: 34px;
  height: 34px;
  position: absolute;
  bottom: 10px;
  left: 0;
  right: 0;
  margin: auto;
}

.bottom-margin-38 {
  margin-bottom: 38px;
}
</style>
