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
          territoryDistribution.includes(territory.area_code)
            ? ''
            : 'inactive',
        ]"
        @click="territory.isActive ? updateSelectedTerritory(territory) : null"
      >
        <img class="TerritoriesCardsIcon" :src="territory.icon" />
        <h6 class="text-center">{{ territory.area_name }}</h6>
        <h5
          v-show="
            !(
              territory.isActive &&
              territoryDistribution.includes(territory.area_code)
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
          territoryDistribution.includes(territory.area_code)
            ? ''
            : 'inactive',
        ]"
        @click="
          territory.isActive &&
          territoryDistribution.includes(territory.area_code)
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
    selectedTerritory: {
      type: Object,
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
    territoriesList: [
      {
        area_code: 'FRMET',
        area_name: 'France métropolitaine',
        icon: '/prospecting/France-metropolitaine.svg',
        isActive: true,
      },
      {
        area_code: '01',
        area_name: 'Guadeloupe',
        icon: '/prospecting/Guadeloupe.svg',
        isActive: true,
      },
      {
        area_code: '03',
        area_name: 'Guyane',
        icon: '/prospecting/Guyane.svg',
        isActive: true,
      },
      {
        area_code: '02',
        area_name: 'Martinique',
        icon: '/prospecting/Martinique.svg',
        isActive: false,
      },
      {
        area_code: '06',
        area_name: 'Mayotte',
        icon: '/prospecting/Mayotte.svg',
        isActive: false,
      },
      {
        area_code: '988',
        area_name: 'Nouvelle Calédonie',
        icon: '/prospecting/Nouvelle-Caledonie.svg',
        isActive: true,
      },
      {
        area_code: '987',
        area_name: 'Polynésie Française',
        icon: '/prospecting/Polynesie.svg',
        isActive: false,
      },
      {
        area_code: '04',
        area_name: 'La Réunion',
        icon: '/prospecting/Reunion.svg',
        isActive: false,
      },
      {
        area_code: '977',
        area_name: 'Saint Barthélémy',
        icon: '/prospecting/Saint-Barthelemy.svg',
        isActive: false,
      },
      {
        area_code: '978',
        area_name: 'Saint Martin',
        icon: '/prospecting/Saint-Martin.svg',
        isActive: false,
      },
      {
        area_code: '975',
        area_name: 'Saint Pierre et Miquelon',
        icon: '/prospecting/Saint-Pierre-et-Miquelon.svg',
        isActive: true,
      },
      {
        area_code: '984',
        area_name: 'TAAF',
        icon: '/prospecting/TAAF.svg',
        isActive: false,
      },
      {
        area_code: '986',
        area_name: 'Wallis et Futuna',
        icon: '/prospecting/Wallis-et-Futuna.svg',
        isActive: false,
      },
    ],
    // END UPDATE NEEDED
    search: '',
  }),

  computed: {
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
    territoryDistribution() {
      const firstTerritory = this.territoriesList.find(
        (territory) =>
          territory.isActive &&
          this.territoryDistribution.includes(territory.area_code)
      )
      console.log('firstTerritory',firstTerritory)
      this.updateSelectedTerritory(firstTerritory)
    },
  },
  methods: {
    updateSelectedDisplayingType(type) {
      this.selectedDisplayingType = type
    },
    clearResults() {
      this.search = ''
    },
    updateSelectedTerritory(territory) {
      this.$emit('selectedTerritory', territory)
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
