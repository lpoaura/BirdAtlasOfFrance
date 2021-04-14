<!-- 2/ Intégrer l'API des espèces -->
<template>
  <div
    v-click-outside="closeSearchBar"
    class="AutocompleteWrapper"
    :class="autocompleteIsOpen ? 'open' : ''"
  >
    <input
      v-model="search"
      type="text"
      :placeholder="selectedType.placeholder"
    />
    <div class="AutocompleteAdvanced">
      <div class="CloseIconBox">
        <img
          v-show="search.length > 0"
          class="CloseIcon"
          src="/close.svg"
          @click="clearResults"
        />
      </div>
      <div class="SearchSplit"></div>
      <div class="SelectTypeWrapper">
        <div class="SelectedTypeContent" @click="openOrCloseSelectBox">
          <span class="SelectedTypeText">{{ selectedType.label }}</span>
          <img
            class="SelectedTypeChevron"
            :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
          />
        </div>
        <div v-show="selectIsOpen" class="SelectBox">
          <li
            v-for="(type, index) in typeList"
            :key="index"
            class="SelectItem"
            :class="[type.label === selectedType.label ? 'selected' : '']"
            @click="updateSelectedType(type)"
          >
            {{ type.label }}
          </li>
        </div>
      </div>
      <div class="SearchIconBox">
        <img class="SearchIcon" src="/search.svg" />
      </div>
    </div>
    <div v-show="autocompleteIsOpen" class="ResultsSplit"></div>
    <div v-show="autocompleteIsOpen" class="AutocompleteResults">
      <li
        v-for="data in dataList"
        :key="data.code"
        class="AutocompleteItem"
        @click="updateSelectedData(data)"
      >
        {{ selectedType.label === 'Espèce' ? data.name : data.html_repr }}
      </li>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({
    search: '',
    dataList: [],
    autocompleteIsOpen: false,
    typeList: [
      {
        label: 'Lieu',
        api: '/api/v1/search_areas?limit=10&search=',
        placeholder: 'Rechercher une commune, une maille...',
      },
      {
        label: 'Espèce',
        api: '/api/v1/search_taxa?limit=10&search=',
        placeholder: 'Rechercher une espèce...',
      },
    ],
    selectedType: {
      label: 'Lieu',
      api: '/api/v1/search_areas?limit=10&search=',
      placeholder: 'Rechercher une commune, une maille...',
    },
    selectIsOpen: false,
    speciesIsSelected: false,
    searchIsProgramatic: false,
  }),
  watch: {
    search(newVal, oldVal) {
      if (!this.speciesIsSelected) {
        if (newVal === '' || newVal.length < 3) {
          this.autocompleteIsOpen = false
        } else {
          this.$axios
            .$get(this.selectedType.api + `${newVal}`)
            .then((data) => {
              if (data.length > 0) {
                this.autocompleteIsOpen = true
                this.dataList = data
              } else {
                this.autocompleteIsOpen = false
              }
            })
            .catch((error) => {
              console.log(error)
            })
        }
      }
      if (
        this.speciesIsSelected &&
        !this.searchIsProgramatic &&
        newVal.lenght !== oldVal.length
      ) {
        this.speciesIsSelected = false
        this.$emit('selectedSpecies', null)
        this.$router.push({
          path: '/prospecting',
          query: { species: undefined },
        })
      }
      this.searchIsProgramatic = false
    },
  },
  methods: {
    openOrCloseSelectBox() {
      this.selectIsOpen = !this.selectIsOpen
    },
    updateSelectedType(type) {
      this.selectIsOpen = false
      this.selectedType = type
      this.updateSearch(this.search)
    },
    updateSearch(newVal) {
      if (newVal === '' || newVal.length < 3) {
        this.autocompleteIsOpen = false
      } else {
        this.$axios
          .$get(this.selectedType.api + `${newVal}`)
          .then((data) => {
            if (data.length > 0) {
              this.autocompleteIsOpen = true
              this.dataList = data
            } else {
              this.autocompleteIsOpen = false
            }
          })
          .catch((error) => {
            console.log(error)
          })
      }
    },
    updateSelectedData(data) {
      if (this.selectedType.label === 'Espèce') {
        // À REVOIR
        this.speciesIsSelected = true
        this.$emit('selectedSpecies', data)
        this.$router.push({
          path: this.selectedType.routerPath,
          query: { species: `${data.code}` },
        })
        const formattedName = data.name.split('(')[0]
        this.searchIsProgramatic = true
        this.search = formattedName
        this.autocompleteIsOpen = false
      } else {
        this.$emit('selectedMunicipality', data)
        this.$router.push({
          path: '/prospecting',
          query: { area: `${data.code}`, type: `${data.type_code}` },
        })
        this.autocompleteIsOpen = false
      }
    },
    clearResults() {
      this.autocompleteIsOpen = false
      this.search = ''
      if (this.speciesIsSelected) {
        this.speciesIsSelected = false
        this.$emit('selectedSpecies', null)
        this.$router.push({
          path: '/prospecting',
          query: { species: undefined },
        })
      }
    },
    closeSearchBar() {
      this.autocompleteIsOpen = false
      this.selectIsOpen = false
    },
  },
}
</script>

<style scoped>
.AutocompleteWrapper {
  position: relative;
  z-index: 5;
  background: linear-gradient(rgba(38, 38, 38, 0.03), rgba(38, 38, 38, 0.03)),
    white;
  width: 100%;
  border: 1px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
}

.AutocompleteWrapper.open {
  border: 1px solid #eece25;
}

.AutocompleteWrapper input {
  width: 100%;
  height: 42px;
  border: none;
  outline: none;
  box-sizing: border-box;
  border-radius: 8px;
  padding-left: 4%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
  color: rgba(38, 38, 38, 0.4);
}

.AutocompleteAdvanced {
  position: absolute;
  top: 0;
  right: 0;
  height: 42px;
  border-radius: 8px;
  padding: 0 6px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.CloseIconBox {
  width: 16px;
  height: 16px;
  display: flex;
}

.CloseIcon {
  width: 100%;
  margin: auto;
  cursor: pointer;
}

.SearchSplit {
  width: 0;
  height: 26px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  margin-left: 10px;
}

.SelectTypeWrapper {
  width: 94px;
  align-self: flex-start;
  display: flex;
  flex-direction: column;
}

.SelectedTypeContent {
  width: 100%;
  height: 42px;
  margin-bottom: 6px;
  padding: 0 1.1vw;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SelectedTypeText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SelectedTypeChevron {
  width: 7px;
}

.SelectBox {
  background: #fcfcfc;
  width: 100%;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.15);
  border-radius: 4px;
  padding: 0.5vw;
  overflow: auto;
}

.SelectItem {
  list-style: none;
  width: 100%;
  padding: 5% 0.6vw;
  cursor: pointer;
  border-radius: 4px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SelectItem.selected {
  background: rgba(238, 206, 37, 0.4);
  font-weight: 500;
  color: #7b6804;
}

.SearchIconBox {
  background: #eece25;
  width: 30px;
  height: 30px;
  border-radius: 4px;
  display: flex;
}

.SearchIcon {
  height: 16px;
  margin: auto;
}

.ResultsSplit {
  width: 96%;
  margin-left: 4%;
  height: 0;
  border: 1px solid rgba(38, 38, 38, 0.1);
}

.AutocompleteResults {
  padding: 1%;
  overflow: auto;
}

.AutocompleteItem {
  list-style: none;
  width: 100%;
  padding: 1.5% 3%;
  cursor: pointer;
  border-radius: 4px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.AutocompleteItem:hover {
  background: rgba(238, 206, 37, 0.4);
  color: #7b6804;
  font-weight: 600;
}
</style>
