<template>
  <div class="SpeciesCardContent map" :class="tabStatus">
    <client-only>
      <lazy-species-map
        :selected-territory="selectedTerritory"
        :selected-subject="selectedSubject"
        :selected-season="selectedSeason"
        :cdnom="cdnom"
      />
    </client-only>
    <div class="MapLegend"></div>
  </div>
</template>

<script>
export default {
  components: {
    'lazy-species-map': () => {
      if (process.client) {
        return import('~/components/species-card/maps/SpeciesMap.vue')
      }
    }
  },
  props: {
    tabStatus: {
      type: String,
      required: true
    },
    selectedTerritory: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true
    },
    selectedSubject: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true
    },
    selectedSeason: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true
    },
    cdnom: {
      type: String,
      required: true
    }
  }
}
</script>

<style scoped>
.MapLegend {
  border-left: 1px solid rgba(57, 118, 90, 0.1);
  width: 200px;
}
</style>
