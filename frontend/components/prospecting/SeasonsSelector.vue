<template>
  <div v-click-outside="closeSelectBox" class="MapSelectorWrapper">
    <div class="MapSelectorSelectedOption" @click="openOrCloseSelectBox">
      <img class="MapSelectorIcon" src="/calendar.svg" />
      <h5 class="fw-600 right-margin-12">{{ selectedSeason.label }}</h5>
      <img
        class="MapSelectorChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="MapSelectorBox">
      <div class="MapSelectorHeader">
        <h4 class="black02 fw-600">Périodes</h4>
      </div>
      <div class="MapSelectorOverflow">
        <li
          v-for="(season, index) in seasonsList"
          :key="index"
          class="RadioOption"
          :class="season.label === selectedSeason.label ? 'selected' : ''"
          @click="updateSelectedSeason(season)"
        >
          <div class="RadioLabel">
            <div class="RadioButton">
              <div
                v-show="season.label === selectedSeason.label"
                class="RadioButtonSelected"
              ></div>
            </div>
            {{ season.label }}
          </div>
        </li>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectedSeason: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    selectIsOpen: false,
    seasonsList: [
      {
        label: 'Toutes saisons',
        value: 'all_period',
        featuresColors: [
          'rgba(51, 105, 80, 0.2)',
          'rgba(51, 105, 80, 0.4)',
          'rgba(51, 105, 80, 0.6)',
          'rgba(51, 105, 80, 0.8)',
          '#336950',
        ],
        speciesDistributionColors: ['#336950'],
      },
      {
        label: 'Période de reproduction',
        value: 'breeding',
        featuresColors: [
          'rgba(230, 87, 132, 0.2)',
          'rgba(230, 87, 132, 0.4)',
          'rgba(230, 87, 132, 0.6)',
          'rgba(230, 87, 132, 0.8)',
          '#E65784',
        ],
        speciesDistributionColors: [
          'rgba(238, 206, 37, 0.4)',
          'rgba(235, 106, 10, 0.4)',
          'rgba(171, 54, 29, 0.6)',
        ],
      },
      {
        label: "Période d'hivernage",
        value: 'wintering',
        featuresColors: [
          'rgba(76, 97, 244, 0.2)',
          'rgba(76, 97, 244, 0.4)',
          'rgba(76, 97, 244, 0.6)',
          'rgba(76, 97, 244, 0.8)',
          '#4C61F4',
        ],
        speciesDistributionColors: ['#4C61F4'],
      },
    ],
  }),
  methods: {
    openOrCloseSelectBox() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSelectBox() {
      this.selectIsOpen = false
    },
    updateSelectedSeason(season) {
      this.$emit('selectedSeason', season)
      this.selectIsOpen = false
    },
  },
}
</script>

<style scoped>
.MapSelectorBox {
  width: 280px;
}
</style>
