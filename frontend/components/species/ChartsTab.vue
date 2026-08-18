<template>
  <div class="SpeciesCardContent">
    <div
      v-if="showNoDataMessage"
      class="no-data-info"
    >
      Aucune donnée à restituer pour ce territoire et cette période
    </div>
    <species-charts-phenology-all-period 
      v-if="selectedSeason.value === 'all_period'" 
    />
    <species-charts-phenology-migration 
      v-if="selectedSeason.value === 'all_period'"
    />
    <!-- <species-charts-phenology-breeding 
      v-if="selectedSeason.value === 'breeding'"
    /> -->
    <species-charts-trend 
      v-if="['wintering', 'breeding'].includes(selectedSeason.value)"
    />
    <!-- <species-charts-populations-sizes 
      v-if="['wintering', 'breeding'].includes(selectedSeason.value)" 
    /> -->
    <species-charts-populations-sizes-tab 
      v-if="['breeding'].includes(selectedSeason.value)" 
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
    selectedTerritoryCode() {
      return this.$store.state.species.selectedTerritory?.area_code
    },
    subjectsList() {
      return this.$store.state.species.subjectsList
    },
    expectedChartSlugs() {
      const season = this.selectedSeason?.value
      if (season === 'all_period') {
        return ['phenology-all-period', 'phenology-migration', 'altitude']
      }
      if (season === 'wintering') {
        return ['trend', 'altitude']
      }
      if (season === 'breeding') {
        return ['trend', 'population-size', 'altitude']
      }
      return ['altitude']
    },
    chartsHaveAllReported() {
      const reportedSlugs = this.subjectsList.map((s) => s.slug)
      return this.expectedChartSlugs.every((slug) =>
        reportedSlugs.includes(slug)
      )
    },
    showNoDataMessage() {
      return (
        this.chartsHaveAllReported &&
        this.subjectsList.filter((i) => i.status).length === 0
      )
    },
  },
  watch: {
    selectedSeason: {
      handler() {
        this.initSubjectsList()
      },
    },
    selectedTerritoryCode: {
      handler() {
        this.initSubjectsList()
      },
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
