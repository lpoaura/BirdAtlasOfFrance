<template>
  <section class="SpeciesDashboardControl">
    <!-- HEADER -->
    <div class="SpeciesDashboardHeader">
      <span class="SpeciesDashboardTitle">{{
        selectedSpecies.common_name_fr
      }}</span>
      <seasons-selector
        :selected-season="selectedSeason"
        @selectedSeason="updateSelectedSeason"
      />
    </div>
    <span class="SpeciesDashboardSubtitle">
      <i>{{ selectedSpecies.sci_name }} </i>
      <span v-if="selectedSpecies.common_name_en">
        - {{ selectedSpecies.common_name_en }}
      </span>
    </span>
    <!-- CONTENT -->
    <div class="SpeciesDashboardContent">
      <div class="FeaturesLegend">
        <div
          v-for="(item, index) in selectedSeason.speciesDistributionColors"
          :key="index"
          class="FeaturesLegendLabel"
        >
          <i
            :style="{
              background: item,
            }"
          ></i
          >{{ featuresLabels[selectedSeason.value][index] }}
        </div>
      </div>
      <div
        class="PrimaryButton outlined"
        style="margin-top: 6px"
        @click="deleteSelectedSpecies"
      >
        Fermer
      </div>
    </div>
  </section>
</template>

<script>
import SeasonsSelector from '~/components/prospecting/SeasonsSelector.vue'

export default {
  components: {
    'seasons-selector': SeasonsSelector,
  },
  props: {
    selectedSpecies: {
      type: Object,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    featuresLabels: {
      all_period: ['Présence'],
      breeding: ['Nicheur possible', 'Nicheur probable', 'Nicheur certain'],
      wintering: ['Présence'],
    },
  }),
  methods: {
    updateSelectedSeason(season) {
      this.$emit('selectedSeason', season)
    },
    deleteSelectedSpecies() {
      this.$emit('selectedSpecies', null)
      this.$router.push({
        path: '/prospecting',
        query: { species: undefined },
      })
    },
  },
}
</script>

<style scoped>
.SpeciesDashboardControl {
  background: #fcfcfc;
  width: 506px;
  max-height: calc(100vh - 156px);
  padding: 16px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}

.SpeciesDashboardHeader {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SpeciesDashboardTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  display: flex;
  align-items: center;
}

.SpeciesDashboardSubtitle {
  margin-bottom: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 300;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SpeciesDashboardContent {
  /* padding-right: 16px; */
  overflow-y: auto;
}

.FeaturesLegend {
  margin-bottom: 16px;
}

.FeaturesLegendLabel {
  margin-bottom: 10px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.FeaturesLegendLabel i {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  float: left;
  margin-right: 10px;
  display: flex;
}
</style>
