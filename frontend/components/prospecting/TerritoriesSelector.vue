<!-- Attendre l'API avec les emprises -->
<template>
  <div v-click-outside="closeSelectBox" class="SelectTerritoryWrapper">
    <div class="SelectedTerritoryContent" @click="openOrCloseSelectBox">
      <img class="SelectedTerritoryIcon" src="/location.svg" />
      <span class="SelectedTerritoryText">{{ selectedTerritory.name }}</span>
      <img
        class="SelectedTerritoryChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="SelectBox">
      <div class="SelectBoxHeader">
        <span class="SelectBoxTitle">Territoires</span>
        <div class="SelectBoxDisplayingTypeContent">
          <div
            v-for="(type, index) in displayingTypeList"
            :key="index"
            class="SelectBoxDisplayingType"
            :class="[
              type.label === selectedDisplayingType.label ? 'selected' : '',
            ]"
            @click="updateSelectedDisplayingType(type)"
          >
            <img class="SelectBoxDisplayingTypeIcon" :src="type.icon" />
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
          :class="territory.name === selectedTerritory.name ? 'selected' : ''"
          @mouseover="showOrHideUnavailableMessage(territory)"
          @mouseout="showOrHideUnavailableMessage(territory)"
        >
          <img class="TerritoriesCardsIcon" :src="territory.icon" />
          <span class="TerritoriesCardsTitle">{{ territory.name }}</span>
          <div
            v-show="
              territory.name !== 'France métropolitaine' &&
              territory.unavailableMessageIsActive
            "
            class="UnavailableData"
          >
            Données non disponibles actuellement
          </div>
        </div>
      </div>
      <div v-else class="TerritoriesList">
        <!-- MANQUE @click="updateSelectedTerritory(territory)" -->
        <div
          v-for="(territory, index) in filteredTerritories"
          :key="index"
          class="TerritoriesLi"
          :class="territory.name === selectedTerritory.name ? 'selected' : ''"
        >
          <div class="TerritoriesLiRadio">
            <div
              v-show="territory.name === selectedTerritory.name"
              class="TerritoriesLiRadioSelected"
            ></div>
          </div>
          <span class="TerritoriesLiText"> {{ territory.name }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({
    selectIsOpen: false,
    displayingTypeList: [
      { label: 'grid', icon: '/grid.svg' },
      { label: 'list', icon: '/list.svg' },
    ],
    selectedDisplayingType: { label: 'grid', icon: 'grid.svg' },
    territoriesList: [
      {
        name: 'France métropolitaine',
        icon: '/prospecting/France-metropolitaine.svg',
      },
      {
        name: 'Guadeloupe',
        icon: '/prospecting/Guadeloupe.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Guyane française',
        icon: '/prospecting/Guyane.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'La Martinique',
        icon: '/prospecting/Martinique.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Mayotte',
        icon: '/prospecting/Mayotte.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Nouvelle Calédonie',
        icon: '/prospecting/Nouvelle-Caledonie.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Polynésie Française',
        icon: '/prospecting/Polynesie.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'La Réunion',
        icon: '/prospecting/Reunion.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Saint Barthélémy',
        icon: '/prospecting/Saint-Barthelemy.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Saint Martin',
        icon: '/prospecting/Saint-Martin.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Saint Pierre et Miquelon',
        icon: '/prospecting/Saint-Pierre-et-Miquelon.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Terres Australes et Antarctiques Françaises',
        icon: '/prospecting/TAAF.svg',
        unavailableMessageIsActive: false,
      },
      {
        name: 'Wallis et Futuna',
        icon: '/prospecting/Wallis-et-Futuna.svg',
        unavailableMessageIsActive: false,
      },
    ],
    selectedTerritory: {
      name: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
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
    showOrHideUnavailableMessage(territory) {
      territory.unavailableMessageIsActive = !territory.unavailableMessageIsActive
    },
  },
}
</script>

<style scoped>
.SelectTerritoryWrapper {
  position: relative;
  margin-left: 26px;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.SelectedTerritoryContent {
  cursor: pointer;
  display: flex;
  align-items: center;
}

.SelectedTerritoryIcon {
  width: 16px;
  margin-right: 12px;
}

.SelectedTerritoryText {
  margin-right: 12px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SelectedTerritoryChevron {
  width: 8px;
}

.SelectBox {
  position: absolute;
  z-index: 5;
  top: 30px;
  background: #fcfcfc;
  width: 334px;
  max-height: min(534px, calc(100vh - 136px));
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
  padding: 16px 0 16px 16px;
  overflow: auto;
  display: flex;
  flex-direction: column;
}

.SelectBoxHeader {
  margin: 0 16px 16px 0;
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

.SelectBoxDisplayingTypeContent {
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  cursor: pointer;
  border-radius: 4px;
  display: flex;
}

.SelectBoxDisplayingType {
  width: 32px;
  height: 32px;
  border-radius: 4px;
  display: flex;
}

.SelectBoxDisplayingType.selected {
  background: #eece25;
}

.SelectBoxDisplayingTypeIcon {
  width: 16px;
  margin: auto;
}

.AutocompleteWrapper {
  width: 302px;
  margin-bottom: 20px;
}

.AutocompleteSearchIconWrapper {
  margin-left: 16px;
}

.TerritoriesGrid,
.TerritoriesList {
  display: flex;
  flex-wrap: wrap;
  overflow-y: auto;
  scrollbar-width: thin;
}

.TerritoriesCard {
  position: relative;

  /* Enlever le background */
  background: rgba(38, 38, 38, 0.1);
  width: 135px;
  height: 120px;
  box-sizing: border-box;
  border-radius: 8px;
  border: 1px solid rgba(57, 118, 90, 0.1);
  margin-right: 16px;
  margin-bottom: 16px;
  padding: 0 12px;
  text-decoration: none;

  /* cursor: pointer; */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.UnavailableData {
  background: linear-gradient(rgba(38, 38, 38, 0.1), rgba(38, 38, 38, 0.1)),
    white;
  position: absolute;
  z-index: 6;
  width: 100%;
  height: 100%;
  border-radius: 8px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;
}

.TerritoriesCard.selected {
  background: #fff;
  border: 3px solid #eece25;
  cursor: pointer;
}

.TerritoriesCardsIcon {
  height: 48px;
  margin-bottom: 12px;
}

.TerritoriesCardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 400;
  font-size: 10px;
  line-height: 15px;
  color: #000;
  text-align: center;
}

.TerritoriesLi {
  width: 100%;
  height: 39.2px;
  padding-left: 10px;
  margin-right: 16px;
  border-radius: 4px;

  /* cursor: pointer; */
  display: flex;
  align-items: center;
}

.TerritoriesLi.selected {
  background: rgba(238, 206, 37, 0.2);
  cursor: pointer;
}

.TerritoriesLiRadio {
  margin-right: 12px;
  min-width: 16px;
  max-width: 16px;
  min-height: 16px;
  max-height: 16px;
  border-radius: 50%;
  border: 1px solid rgba(38, 38, 38, 0.2);
  display: flex;
}

.TerritoriesLi.selected .TerritoriesLiRadio {
  border: none;
  background: #eece25;
}

.TerritoriesLiRadioSelected {
  background: #fcfcfc;
  margin: auto;
  min-width: 6px;
  max-width: 6px;
  min-height: 6px;
  max-height: 6px;
  border-radius: 50%;
}

.TerritoriesLiText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #000;
}
</style>
