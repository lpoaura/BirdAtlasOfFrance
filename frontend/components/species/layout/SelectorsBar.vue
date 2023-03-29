<template>
  <div
    class="MapSelectors"
    :class="selectedTab.value === 'maps' ? 'map' : ''"
  >
    <div v-if="selectedSubject && selectedTab.value === 'maps'" class="MapTitle">
      <h4 class="black02 fw-bold">
        {{ selectedSubject.name
        }}<span v-if="selectedSubject.slug != 'extra-map'">
          - {{ selectedSeason?.label }}</span
        >
      </h4>
      <h5
        v-if="selectedSubject &&
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
          :filtered-seasons="selectedTab.value === 'maps' ? selectedSubject.seasons : null"
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
  data: () => {
    return {
      territoryIsOpen: false,
      seasonIsOpen: false,
      selectedTerritory: {
        area_code: 'FRMET',
        area_name: 'France métropolitaine',
        icon: '/prospecting/France-metropolitaine.svg',
        isActive: true,
      },
      selectedSeason: {
        label: 'Toutes saisons',
        value: 'all_period',
      },
    }
  },
  computed: {
    selectedSubject() {
      return this.$store.state.species.selectedSubject
    },
    selectedTab() {
      return this.$store.state.species.selectedTab
    },
  },
  watch: {
    selectedSeason: {
      handler(newVal, oldVal) {
        this.$store.commit('species/setSelectedSeason', this.selectedSeason)
      },
      deep: true,
    },
    selectedTerritory: {
      handler(newVal, oldVal) {
        this.getIdArea()
      },
      deep: true,
    },
  },
  mounted() {
    this.getIdArea()
    this.$store.commit('species/setSelectedSeason', this.selectedSeason)
  },
  methods: {
    async getIdArea() {
      const resp = await this.$axios.$get(
        `/api/v1/lareas/ATLAS_TERRITORY/${this.selectedTerritory.area_code}?geom=false&bbox=false`
      )
      this.selectedTerritory.id_area = resp.id_area
      this.$store.commit('species/setSelectedTerritory', this.selectedTerritory)
    },
    openOrCloseTerritoriesBox() {
      this.territoryIsOpen = !this.territoryIsOpen
    },
    closeTerritoriesBox() {
      this.territoryIsOpen = false
    },
    updateSelectedTerritory(territory) {
      this.selectedTerritory = territory
      this.territoryIsOpen = false
      // UPDATE NEEDED : mettre à jour les données des graphes lorsqu'on sélectionne un "nouveau territoire"
      // if (!this.chartsDataAlreadyDownloaded.includes(territory.area_code)) {
      //   console.debug(
      //     'Il faut télécharger les données de ce nouveau territoire !'
      //   )
      // }
      // END UPDATE NEEDED
    },
    openOrCloseSeasonsBox() {
      this.seasonIsOpen = !this.seasonIsOpen
    },
    updateSelectedSeason(season) {
      this.selectedSeason = season
      this.seasonIsOpen = false
      if (this.selectedTab.value !== 'maps') {
        // this.defineSelectedSubject()
        // this.defineDomCurrentScrollingItems()
      }
    },
    closeSeasonsBox() {
      this.seasonIsOpen = false
    },
  },
}
</script>

<style>
/* .MapSelectors {
  padding: 24px 40px;
  justify-content: flex-start;
  align-items: center;
  column-gap: 40px;
  row-gap: 16px;
  flex-wrap: wrap;
} */

.MapSelectors.map {
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
}

.MapTitle {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.MapSelectorsWrapper {
  flex: 1 1 414px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}
</style>
