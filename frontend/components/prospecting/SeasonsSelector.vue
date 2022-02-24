<template>
  <div v-show="selectIsOpen" class="MapSelectorBox">
    <header class="MapSelectorHeader">
      <div class="MapSelectorInfo">
        <h4 class="black02 fw-600">Périodes</h4>
      </div>
    </header>
    <div class="MapSelectorOverflow">
      <li
        v-for="(season, index) in seasonsList"
        :key="index"
        class="RadioOption"
        :class="[
          season.value === selectedSeason.value ? 'selected' : '',
          !filteredSeasons ||
          (filteredSeasons && filteredSeasons.includes(season.value))
            ? ''
            : 'inactive',
        ]"
        @click="
          !filteredSeasons ||
          (filteredSeasons && filteredSeasons.includes(season.value))
            ? $emit('selectedSeason', season)
            : null
        "
      >
        <div class="RadioLabel">
          <div class="RadioButton">
            <div
              v-show="season.value === selectedSeason.value"
              class="RadioButtonSelected"
            ></div>
          </div>
          {{ season.label }}
        </div>
      </li>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectIsOpen: {
      type: Boolean,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
    filteredSeasons: {
      type: Array,
      required: false,
      default: null,
    },
  },
  data: () => ({
    seasonsList: [
      {
        value: 'all_period',
        label: 'Toutes saisons',
        featuresColors: [
          '#bcbcbc',
          'rgba(51, 105, 80, 0.2)',
          'rgba(51, 105, 80, 0.4)',
          'rgba(51, 105, 80, 0.6)',
          'rgba(51, 105, 80, 0.8)',
          '#336950',
        ],
        speciesDistributionColors: ['#336950'],
      },
      {
        value: 'breeding',
        label: 'Période de reproduction',
        featuresColors: [
          '#bcbcbc',
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
        value: 'wintering',
        label: "Période d'hivernage",
        featuresColors: [
          '#bcbcbc',
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
  watch: {
    filteredSeasons(newVal) {
      this.updateSelectedSeason()
    },
  },
  mounted() {
    this.updateSelectedSeason()
  },
  methods: {
    updateSelectedSeason() {
      if (
        this.filteredSeasons &&
        !this.filteredSeasons.includes(this.selectedSeason.value)
      ) {
        const filteredSeasons = this.seasonsList.filter((season) => {
          return this.filteredSeasons.includes(season.value)
        })
        if (filteredSeasons.length) {
          this.$emit('selectedSeason', filteredSeasons[0])
        }
      }
    },
  },
}
</script>

<style scoped>
.MapSelectorBox {
  width: 280px;
}

.leaflet-control .MapSelectorBox {
  right: -116px;
}
</style>
