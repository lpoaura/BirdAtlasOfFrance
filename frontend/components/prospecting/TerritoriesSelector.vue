<!-- Attendre l'API avec les emprises -->
<template>
  <div v-click-outside="closeSelectBox" class="MapSelectorWrapper">
    <div class="MapSelectorSelectedOption" @click="openOrCloseSelectBox">
      <img class="MapSelectorIcon" src="/location.svg" />
      <h5 class="fw-600 right-margin-12">{{ selectedTerritory.name }}</h5>
      <img
        class="MapSelectorChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="MapSelectorBox">
      <div class="MapSelectorHeader">
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
          <div class="AutocompleteCloseIconWrapper map">
            <img
              v-show="search.length > 0"
              class="AutocompleteCloseIcon"
              src="/close.svg"
              @click="clearResults"
            />
          </div>
          <div class="AutocompleteSearchIconWrapper map">
            <img class="AutocompleteSearchIcon map" src="/search.svg" />
          </div>
        </div>
      </div>
      <div
        v-if="selectedDisplayingType.label === 'grid'"
        class="TerritoriesGrid"
      >
        <!-- MANQUE @click="updateSelectedTerritory(territory)" -->
        <div
          v-for="(territory, index) in filteredTerritories"
          :key="index"
          class="TerritoriesCard"
          :class="[
            territory.name === selectedTerritory.name ? 'selected' : '',
            territory.isActive ? '' : 'inactive',
          ]"
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
        <!-- MANQUE @click="updateSelectedTerritory(territory)" -->
        <li
          v-for="(territory, index) in filteredTerritories"
          :key="index"
          class="RadioOption"
          :class="[
            territory.name === selectedTerritory.name ? 'selected' : '',
            territory.isActive ? '' : 'inactive',
          ]"
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
  </div>
</template>

<script>
export default {
  data: () => ({
    selectIsOpen: false,
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
        name: 'Guyane française',
        icon: '/prospecting/Guyane.svg',
        isActive: false,
      },
      {
        name: 'La Martinique',
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
    selectedTerritory: {
      name: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
      isActive: true,
    },
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
    openOrCloseSelectBox() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSelectBox() {
      this.selectIsOpen = false
    },
    updateSelectedDisplayingType(type) {
      this.selectedDisplayingType = type
    },
    clearResults() {
      this.search = ''
    },
    updateSelectedTerritory(territory) {
      this.selectedTerritory = territory
    },
  },
}
</script>

<style scoped>
.AutocompleteWrapper {
  width: 302px;
  margin-bottom: 20px;
}

.AutocompleteSearchIconWrapper {
  margin-left: 16px;
}

.TerritoriesGrid,
.TerritoriesList {
  overflow-y: auto;
  scrollbar-width: thin;
}

.TerritoriesGrid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  grid-gap: 16px;
  padding-right: 16px;
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

.TerritoriesList {
  padding-right: 16px;
}

.RadioOption.inactive {
  cursor: auto;
}
</style>
