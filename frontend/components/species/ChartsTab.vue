<template>
  <div class="SpeciesCardContent">
    <species-charts-phenology-all-period
      v-if="phenologyPeriod === 'all_period'"
    />
    <species-charts-phenology-migration
      v-if="phenologyPeriod === 'all_period'"
    />
    <species-charts-phenology-breeding v-if="phenologyPeriod === 'breeding'" />
    <!-- <species-charts-populations-sizes v-if="['all_period','breeding'].includes(phenologyPeriod)"/> -->
    <species-charts-trend
      v-if="['wintering', 'breeding'].includes(phenologyPeriod)"
    />
    <species-charts-altitude />
  </div>
</template>

<script>
export default {
  computed: {
    phenologyPeriod() {
      return this.$store.state.species.phenologyPeriod
    },
  },
  watch: {
    phenologyPeriod: {
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
