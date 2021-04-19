<template>
  <div v-click-outside="closeSelectBox" class="SelectSeasonWrapper">
    <div class="SelectSeasonContent" @click="openOrCloseSelectBox">
      <img class="SelectSeasonIcon" src="/calendar.svg" />
      <span class="SelectSeasonText">{{ selectedSeason.label }}</span>
      <img
        class="SelectSeasonChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="SelectBox">
      <div class="SelectBoxHeader">
        <span class="SelectBoxTitle">Saisons</span>
      </div>
      <div class="SeasonsList">
        <div
          v-for="(season, index) in seasonsList"
          :key="index"
          class="SeasonsLi"
          :class="season.label === selectedSeason.label ? 'selected' : ''"
          @click="updateSelectedSeason(season)"
        >
          <div class="SeasonsLiRadio">
            <div
              v-show="season.label === selectedSeason.label"
              class="SeasonsLiRadioSelected"
            ></div>
          </div>
          <span class="SeasonsLiText"> {{ season.label }}</span>
        </div>
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
        label: 'Reproduction',
        value: 'breeding',
        featuresColors: ['#FFEDA0', '#FED976', '#FEB24C', '#FD8D3C', '#FC4E2A'],
        speciesDistributionColors: [
          'rgba(238, 206, 37, 0.4)',
          'rgba(235, 106, 10, 0.4)',
          'rgba(171, 54, 29, 0.6)',
        ],
      },
      {
        label: 'Hivernage',
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
.SelectSeasonWrapper {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.SelectSeasonContent {
  cursor: pointer;
  display: flex;
  align-items: center;
}

.SelectSeasonIcon {
  width: 16px;
  margin-right: 10px;
}

.SelectSeasonText {
  margin-right: 10px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SelectSeasonChevron {
  width: 8px;
}

.SelectBox {
  position: absolute;
  z-index: 5;
  top: 30px;
  background: #fcfcfc;
  width: 200px;
  max-height: calc(100vh - 136px);
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
  padding: 16px;
  overflow: auto;
  display: flex;
  flex-direction: column;
}

.SelectBoxHeader {
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SelectBoxTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: #000;
}

.SeasonsList {
  display: flex;
  flex-direction: column;
}

.SeasonsLi {
  width: 100%;
  height: 39.2px;
  padding-left: 10px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.SeasonsLi.selected {
  background: rgba(238, 206, 37, 0.2);
}

.SeasonsLiRadio {
  margin-right: 12px;
  min-width: 16px;
  max-width: 16px;
  min-height: 16px;
  max-height: 16px;
  border-radius: 50%;
  border: 1px solid rgba(38, 38, 38, 0.2);
  display: flex;
}

.SeasonsLi.selected .SeasonsLiRadio {
  border: none;
  background: #eece25;
}

.SeasonsLiRadioSelected {
  background: #fcfcfc;
  margin: auto;
  min-width: 6px;
  max-width: 6px;
  min-height: 6px;
  max-height: 6px;
  border-radius: 50%;
}

.SeasonsLiText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}
</style>
