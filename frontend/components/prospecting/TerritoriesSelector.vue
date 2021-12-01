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
              type.label === selectedDisplayingType.label ? 'selected' : ''
            "
            @click="updateSelectedDisplayingType(type)"
          >
            <img class="DisplayingTypeIcon" :src="type.icon" />
          </div>
        </div>
      </div>
      <div class="AutocompleteWrapper map">
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
    <div v-if="selectedDisplayingType.label === 'grid'" class="TerritoriesGrid">
      <div
        v-for="(territory, index) in filteredTerritories"
        :key="index"
        class="TerritoriesCard"
        :class="[
          territory.name === selectedTerritory.name ? 'selected' : '',
          territory.isActive ? '' : 'inactive',
        ]"
        @click="territory.isActive ? updateSelectedTerritory(territory) : null"
      >
        <img class="TerritoriesCardsIcon" :src="territory.icon" />
        <h6 class="text-center">{{ territory.name }}</h6>
        <h5
          v-show="!territory.isActive"
          class="UnavailableData fw-600 text-center"
        >
          Données non disponibles actuellement
        </h5>
      </div>
    </div>
    <div v-else class="TerritoriesList">
      <li
        v-for="(territory, index) in filteredTerritories"
        :key="index"
        class="RadioOption"
        :class="[
          territory.name === selectedTerritory.name ? 'selected' : '',
          territory.isActive ? '' : 'inactive',
        ]"
        @click="territory.isActive ? updateSelectedTerritory(territory) : null"
      >
        <div class="RadioLabel">
          <div class="RadioButton">
            <div
              v-show="territory.name === selectedTerritory.name"
              class="RadioButtonSelected"
            ></div>
          </div>
          {{ territory.name }}
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
      { label: 'grid', icon: '/grid.svg' },
      { label: 'list', icon: '/list.svg' },
    ],
    selectedDisplayingType: { label: 'grid', icon: 'grid.svg' },
    territoriesList: [
      {
        name: 'France métropolitaine',
        icon: '/prospecting/France-metropolitaine.svg',
        isActive: true,
      },
      {
        name: 'Guadeloupe',
        icon: '/prospecting/Guadeloupe.svg',
        isActive: false,
      },
      {
        name: 'Guyane',
        icon: '/prospecting/Guyane.svg',
        isActive: true,
      },
      {
        name: 'Martinique',
        icon: '/prospecting/Martinique.svg',
        isActive: false,
      },
      {
        name: 'Mayotte',
        icon: '/prospecting/Mayotte.svg',
        isActive: false,
      },
      {
        name: 'Nouvelle Calédonie',
        icon: '/prospecting/Nouvelle-Caledonie.svg',
        isActive: false,
      },
      {
        name: 'Polynésie Française',
        icon: '/prospecting/Polynesie.svg',
        isActive: false,
      },
      {
        name: 'La Réunion',
        icon: '/prospecting/Reunion.svg',
        isActive: false,
      },
      {
        name: 'Saint Barthélémy',
        icon: '/prospecting/Saint-Barthelemy.svg',
        isActive: false,
      },
      {
        name: 'Saint Martin',
        icon: '/prospecting/Saint-Martin.svg',
        isActive: false,
      },
      {
        name: 'Saint Pierre et Miquelon',
        icon: '/prospecting/Saint-Pierre-et-Miquelon.svg',
        isActive: false,
      },
      {
        name: 'Terres Australes et Antarctiques Françaises',
        icon: '/prospecting/TAAF.svg',
        isActive: false,
      },
      {
        name: 'Wallis et Futuna',
        icon: '/prospecting/Wallis-et-Futuna.svg',
        isActive: false,
      },
    ],
    search: '',
  }),
  computed: {
    filteredTerritories() {
      return this.territoriesList.filter((territory) =>
        territory.name
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

.RadioOption.inactive {
  cursor: auto;
}
</style>
