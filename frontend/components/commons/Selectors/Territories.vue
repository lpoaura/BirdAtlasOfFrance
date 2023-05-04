<template>
  <div v-show="selectIsOpen" class="MapSelectorBox">
    <header class="MapSelectorHeader">
      <div class="MapSelectorInfo">
        <h4 class="black02 fw-600">Territoires</h4>
        <div class="DisplayingTypeWrapper">
          <div
            v-for="(type, index) in displayingTypesList"
            :key="index"
            class="DisplayingType"
            :class="
              type.value === selectedDisplayingType.value ? 'selected' : ''
            "
            @click="updateSelectedDisplayingType(type)"
          >
            <img class="DisplayingTypeIcon" :src="type.icon" />
          </div>
        </div>
      </div>
      <div
        class="AutocompleteWrapper map"
        :class="search.length > 0 ? 'open' : ''"
      >
        <input v-model="search" type="text" placeholder="Rechercher" />
        <div class="AutocompleteGadgets map">
          <img
            v-if="search.length > 0"
            class="AutocompleteCloseIcon map"
            src="/close.svg"
            @click="clearResults"
          />
          <div class="AutocompleteSearch map">
            <img class="AutocompleteSearchIcon map" src="/search.svg" />
          </div>
        </div>
      </div>
    </header>
    <div v-if="selectedDisplayingType.value === 'grid'" class="TerritoriesGrid">
      <div
        v-for="(territory, index) in filteredTerritories"
        :key="index"
        class="TerritoriesCard"
        :class="[
          territory.area_code === selectedTerritory.area_code ? 'selected' : '',
          territory.isActive &&
          (territoryDistribution.includes(territory.area_code) ||
            territoryDistribution.length === 0)
            ? ''
            : 'inactive',
        ]"
        @click="
          territory.isActive &&
          (territoryDistribution.includes(territory.area_code) ||
            territoryDistribution.length === 0)
            ? updateSelectedTerritory(territory)
            : null
        "
      >
        <img class="TerritoriesCardsIcon" :src="territory.icon" />
        <h6 class="text-center">{{ territory.area_name }}</h6>
        <h5
          v-show="
            !(
              territory.isActive &&
              (territoryDistribution.includes(territory.area_code) ||
                territoryDistribution.length === 0)
            )
          "
          class="UnavailableData fw-600 text-center"
        >
          <!-- Données non disponibles actuellement -->
          Aucune donnée pour ce territoire
        </h5>
      </div>
    </div>
    <div v-else class="TerritoriesList">
      <li
        v-for="(territory, index) in filteredTerritories"
        :key="index"
        class="RadioOption"
        :class="[
          territory.area_code === selectedTerritory.area_code ? 'selected' : '',
          territory.isActive &&
          (territoryDistribution.includes(territory.area_code) ||
            territoryDistribution.length === 0)
            ? ''
            : 'inactive',
        ]"
        @click="
          territory.isActive &&
          (territoryDistribution.includes(territory.area_code) ||
            territoryDistribution.length === 0)
            ? updateSelectedTerritory(territory)
            : null
        "
      >
        <div class="RadioLabel">
          <div class="RadioButton">
            <div
              v-show="territory.area_code === selectedTerritory.area_code"
              class="RadioButtonSelected"
            ></div>
          </div>
          {{ territory.area_name }}
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
  },
  data: () => ({
    displayingTypesList: [
      { value: 'grid', icon: '/grid.svg' },
      { value: 'list', icon: '/list.svg' },
    ],
    selectedDisplayingType: { value: 'grid', icon: 'grid.svg' },
    // UPDATE NEEDED : récupérer la liste des territoires via l'API '/api/v1/lareas/type/ATLAS_TERRITORY?bbox=true&only_enable=true'
    // => Depuis la BDD, rajouter dans feature.properties les propriétés icon et isActive

    // END UPDATE NEEDED
    search: '',
  }),

  computed: {
    territoriesList() {
      return this.$store.state.species.territoriesList
    },
    selectedTerritory() {
      return { ...this.$store.state.species.selectedTerritory }
    },
    filteredTerritories() {
      return this.territoriesList.filter((territory) =>
        territory.area_code
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '')
          .includes(
            this.search
              .toLowerCase()
              .normalize('NFD')
              .replace(/[\u0300-\u036f]/g, '')
          )
      )
    },
    territoryDistribution() {
      return this.$store.state.species.territoryDistribution
    },
  },
  watch: {
    // territoryDistribution() {
    //   this.initSelectedTerritory()
    // },
    // selectedTerritory: {
    //   handler(newVal, oldVal) {
    //     if (
    //       newVal.area_code !== oldVal.area_code
    //     ) {
    //       this.getIdArea()
    //     }
    //   },
    //   deep: true,
    // },
  },
  mounted() {
    // if (this.territoryDistribution.length === 0) {
    //   this.$store.commit(
    //     'species/setSelectedTerritory',
    //     this.territoriesList[0]
    //   )
    // }
  },
  methods: {
    // async getIdArea() {
    //   if (this.selectedTerritory) {
    //     const resp = await this.$axios.$get(
    //       `/api/v1/lareas/ATLAS_TERRITORY/${this.selectedTerritory.area_code}?geom=false&bbox=false`
    //     )
    //     this.selectedTerritory.id_area = resp.id_area
    //     this.$store.commit(
    //       'species/setSelectedTerritory',
    //       {...this.selectedTerritory}
    //     )
    //   }
    // },
    // initSelectedTerritory() {
    //   const firstTerritory = this.territoriesList.find(
    //     (territory) =>
    //       territory.isActive &&
    //       this.territoryDistribution.includes(territory.area_code)
    //   )
    //   console.log('firstTerritory', firstTerritory)
    //   this.updateSelectedTerritory({...firstTerritory})
    // },
    updateSelectedDisplayingType(type) {
      this.selectedDisplayingType = type
    },
    clearResults() {
      this.search = ''
    },
    updateSelectedTerritory(territory) {
      console.log('updateSelectedTerritory')
      this.$store.commit('species/setSelectedTerritory', territory)
    },
  },
}
</script>

<style scoped>
.AutocompleteWrapper {
  width: auto;
  margin: 0 16px 20px 0;
}

.TerritoriesGrid,
.TerritoriesList {
  flex: 1;
  padding-right: 16px;
  overflow-y: auto;
  scrollbar-width: thin;
}

.TerritoriesGrid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  grid-gap: 16px;
}

.TerritoriesCard {
  position: relative;
  height: 120px;
  box-sizing: border-box;
  border-radius: 8px;
  border: 1px solid rgba(57, 118, 90, 0.1);
  padding: 0 12px;
  text-decoration: none;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.TerritoriesCard.selected {
  background: #fff;
  border: 3px solid #eece25;
}

.TerritoriesCard.selected h6 {
  color: #000;
}

.TerritoriesCard.inactive {
  background: rgba(38, 38, 38, 0.1);
  cursor: auto;
}

.UnavailableData {
  display: none;
  background: linear-gradient(rgba(38, 38, 38, 0.1), rgba(38, 38, 38, 0.1)),
    white;
  position: absolute;
  z-index: 6;
  width: 100%;
  height: 100%;
  border-radius: 8px;
  justify-content: center;
  align-items: center;
}

.TerritoriesCard:hover .UnavailableData {
  display: flex;
}

.TerritoriesCardsIcon {
  height: 48px;
  margin-bottom: 12px;
}
</style>
