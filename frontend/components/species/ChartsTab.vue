<template>
  <div class="SpeciesCardContent">
    <species-charts-phenology-all-period
      v-if="selectedSeason.value === 'all_period'"
    />
    <!-- <species-charts-phenology-migration
      v-if="selectedSeason.value === 'all_period'"
    /> -->
    <species-charts-phenology-breeding
      v-if="selectedSeason.value === 'breeding'"
    />
    <species-charts-trend
      v-if="['wintering', 'breeding'].includes(selectedSeason.value)"
    />
    <species-charts-altitude />
  </div>
</template>

<script>
export default {
  computed: {
    selectedSeason() {
      return this.$store.state.species.selectedSeason
    },
    selectedTerritory() {
      return this.$store.state.species.selectedTerritory
    },
  },
  watch: {
    selectedSeason: {
      handler() {
        this.initSubjectsList()
      },
    },
    selectedTerritory: {
      handler() {
        this.initSubjectsList()
      },
      deep: true,
    },
  },
  mounted() {
    this.initSubjectsList()
  },
  methods: {
    initSubjectsList() {
      this.$store.commit('species/setSubjectsList', [])
    },
  },
}
</script>
