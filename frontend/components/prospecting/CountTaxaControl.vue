<template>
  <section class="MapControl">
    <header class="MapControlInfo">
      <div class="MapControlInfoTitles">
        <h4 class="fw-bold">Nombre d'espèces par maille</h4>
        <h5 v-if="currentTerritory.id" class="fw-500 bottom-margin-24">
          {{ currentTerritory.name }}
        </h5>
        <h5 v-else class="fw-500">
          Placez le centre de la carte sur un territoire français pour
          visualiser l'indice de complétude.
        </h5>
      </div>
      <img
        class="MobileMapControlCloseIcon"
        src="/cross.svg"
        @click="closeMobileMapControl"
      />
    </header>
    <div v-show="currentTerritory.id" class="Legend">
      <span
        v-for="(item, index) in countTaxaClasses"
        :key="index"
        class="LegendItem black02 fw-500"
      >
        <i
          :style="{
            background: selectedSeason.featuresColors[index],
          }"
        ></i>
        {{ countTaxaClasses[index].min + '-' + countTaxaClasses[index].max }}
      </span>
    </div>
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
      type: Array,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
  },
  computed: {
    totalAreaCount() {
      let totalCount = 0
      this.globalKnowledgeLevel[this.selectedSeason.value].data.forEach(
        (item) => {
          totalCount += item.value
        }
      )
      return totalCount
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
