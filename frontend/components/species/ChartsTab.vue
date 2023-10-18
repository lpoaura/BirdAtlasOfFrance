<template>
  <div class="SpeciesCardContent">
    <div
      v-if="
        subjectsList.length > 0 && subjectsList.filter((i) => i.status) == 0
      "
      class="no-data-info"
    >
      Aucune donnée à restituer pour ce territoire et cette période
    </div>
    <species-charts-phenology-all-period
      v-if="selectedSeason.value === 'all_period'"
    />
    <!-- <species-charts-phenology-migration
      v-if="selectedSeason.value === 'all_period'"
    /> -->
    <species-charts-phenology-breeding
      v-if="selectedSeason.value === 'breeding'"
    />
    <!-- <species-charts-populations-sizes
      v-if="['wintering', 'breeding'].includes(selectedSeason.value)"
    /> -->
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
    subjectsList() {
      return this.$store.state.species.subjectsList
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

<style>
.no-data-info {
  background-color: whitesmoke;
  padding: 12px 24px;
  text-align: center;
  border-radius: 8px;
  font-size: 14px;
  line-height: 21px;
}
</style>
