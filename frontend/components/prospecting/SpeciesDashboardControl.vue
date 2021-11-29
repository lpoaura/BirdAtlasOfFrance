<template>
  <section class="MapControl">
    <header class="MapControlHeader">
      <div class="MapControlInfo">
        <div class="MapControlInfoTitles">
          <h4 class="fw-bold bottom-margin-4">
            {{ selectedSpecies[`common_name_${lang}`] }}
          </h4>
          <h5 class="fw-300">
            <i>{{ selectedSpecies.sci_name }}</i>
            {{
              selectedSpecies.common_name_en
                ? ' - ' + selectedSpecies.common_name_en
                : ''
            }}
          </h5>
        </div>
        <img
          class="MobileMapControlCloseIcon"
          src="/cross.svg"
          @click="closeMobileMapControl"
        />
      </div>
    </header>
    <div class="MapControlOverflow">
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
          ></i>
          {{ featuresLabels[selectedSeason.value][index] }}
        </div>
      </div>
      <div
        class="PrimaryButton outlined top-margin-24"
        @click="deleteSelectedSpecies"
      >
        Fermer
      </div>
    </div>
  </section>
</template>

<script>
export default {
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
    lang: 'fr',
  }),
  methods: {
    deleteSelectedSpecies() {
      this.$emit('selectedSpecies', null)
      this.$router.push({
        path: '/prospecting',
        query: { species: undefined },
      })
    },
    // MOBILE
    closeMobileMapControl() {
      this.$emit('mobileMapControl', false)
    },
  },
}
</script>

<style scoped>
.MapControl {
  width: 420px;
}

/* À REMETTRE lorsque le bouton "Voir la fiche espèce" sera dispo
.FeaturesLegend {
  margin-bottom: 24px;
} */

.FeaturesLegendLabel {
  margin-bottom: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.FeaturesLegendLabel:last-child {
  margin-bottom: 0;
}

.FeaturesLegend i {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  float: left;
  margin-right: 12px;
  display: flex;
}

.MobileMapControl .MapControlOverflow .PrimaryButton.outlined {
  display: none;
}
</style>
