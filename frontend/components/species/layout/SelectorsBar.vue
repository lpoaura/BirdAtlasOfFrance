<template>
  <div
    v-if="['charts', 'maps'].includes(selectedTab.value)"
    class="MapSelectors"
    :class="selectedTab.value === 'maps' ? 'map' : ''"
  >
    <div v-show="selectedTab.value === 'maps'" class="MapTitle">
      <h4 class="black02 fw-bold">
        {{ selectedSubject.name
        }}<span v-if="selectedSubject.slug != 'extra-map'">
          - {{ selectedSeason?.label }}</span
        >
      </h4>
      <h5
        v-show="
          selectedTab.value === 'maps' &&
          selectedSubject?.label !== selectedSubject.name
        "
        class="black03"
      >
        {{ selectedSubject?.label }}
      </h5>
    </div>
    <div class="MapSelectorsWrapper">
      <div v-click-outside="closeSeasonsBox" class="MapSelectorWrapper seasons">
        <div class="MapSelectorSelectedOption" @click="openOrCloseSeasonsBox">
          <img class="MapSelectorIcon" src="/calendar.svg" />
          <h5 class="fw-600 right-margin-12">
            {{ selectedSeason?.label }}
          </h5>
          <img
            class="MapSelectorChevron"
            :src="seasonIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
          />
        </div>
        <commons-selectors-seasons
          :select-is-open="seasonIsOpen"
          :selected-season="selectedSeason"
          :filtered-seasons="
            selectedTab.value === 'maps' ? selectedSubject.seasons : null
          "
          @selectedSeason="updateSelectedSeason"
        />
      </div>
      <div
        v-click-outside="closeTerritoriesBox"
        class="MapSelectorWrapper territories"
      >
        <div
          class="MapSelectorSelectedOption"
          @click="openOrCloseTerritoriesBox"
        >
          <img class="MapSelectorIcon" src="/location.svg" />
          <h5 class="fw-600 right-margin-12">
            {{ selectedTerritory.area_name }}
          </h5>
          <img
            class="MapSelectorChevron"
            :src="territoryIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
          />
        </div>
        <commons-selectors-territories
          :select-is-open="territoryIsOpen"
          :selected-territory="selectedTerritory"
          @selectedTerritory="updateSelectedTerritory"
        />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectedTab: {
      type: Object,
      required: true,
    },
    selectedSubject: {
      type: Object,
      required: true,
    },
    selectedTerritory: {
      type: Object,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
    territoryIsOpen: {
      type: Boolean,
      required: true,
    },
  },
  mounted() {
    console.debug('', this.selectedSeason)
  },
}
</script>
