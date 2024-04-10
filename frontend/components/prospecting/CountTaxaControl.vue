<template>
  <section class="MapControl">
    <header class="MapControlInfo">
      <div class="MapControlInfoTitles">
        <h4 class="fw-bold">Nombre d'espèces par maille</h4>
        <h5 v-if="currentTerritory.area_code" class="fw-500 bottom-margin-24">
          {{ currentTerritory.area_name }}
        </h5>
        <h5 v-else class="fw-500">
          Placez le centre de la carte sur un territoire français pour
          visualiser le nombre d'espèces par maille.
        </h5>
      </div>
      <img
        class="MobileMapControlCloseIcon"
        src="/cross.svg"
        @click="closeMobileMapControl"
      />
    </header>
    <div
      v-show="
        currentTerritory.area_code && countTaxaClasses.all_period.length > 0
      "
      class="Legend"
    >
      <span class="LegendItem black02 fw-500">
        <i
          :style="{
            background: selectedSeason.featuresColors[0],
          }"
        ></i>
        0
      </span>
      <span
        v-for="(item, index) in countTaxaClasses[selectedSeason.value]"
        :key="index"
        class="LegendItem black02 fw-500"
      >
        <i
          :style="{
            background: selectedSeason.featuresColors[index + 1],
          }"
        ></i>
        {{
          countTaxaClasses[selectedSeason.value][index].min +
          '-' +
          countTaxaClasses[selectedSeason.value][index].max
        }}
      </span>
    </div>
    <span
      v-show="
        currentTerritory.area_code && !(countTaxaClasses.all_period.length > 0)
      "
      class="fw-500"
    >
      Les données de ce territoire ne sont pas encore disponibles.
    </span>
  </section>
</template>

<script>
export default {
  props: {
    currentTerritory: {
      type: Object,
      required: true,
    },
    countTaxaClasses: {
      type: Object,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
  },
  methods: {
    // MOBILE
    closeMobileMapControl() {
      this.$emit('mobileMapControl', false)
    },
  },
}
</script>

<style scoped>
.MapControl {
  width: auto;
  max-width: min(420px, calc(100vw - 20px));
  padding: 16px;
}

.MapControlInfo {
  margin-bottom: 0;
  margin-right: 0;
}

.Legend {
  display: flex;
  flex-direction: column;
}

.LegendItem {
  margin-bottom: 14px;
  display: flex;
  align-items: center;
}

.LegendItem:last-child {
  margin-bottom: 0;
}

.LegendItem i {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  float: left;
  margin-right: 16px;
}
</style>
