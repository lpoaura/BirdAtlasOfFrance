<!-- Bouton jaune de recherche : afficher les recherches récentes -->
<template>
  <div
    v-click-outside="closeSearchBarOpenedElements"
    class="AutocompleteWrapper"
  >
    <input
      v-model="search"
      type="text"
      placeholder="Rechercher une commune, une maille, une espèce..."
    />
    <div class="AutocompleteAdvanced">
      <div class="CloseIconBox">
        <img
          v-show="autocompleteIsOpen"
          class="CloseIcon"
          src="/close.svg"
          @click="clearResults"
        />
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
        {{ data.name }}
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
        label: 'Espèce',
        api: '/api/v1/search_taxa?limit=10&search=',
        routerPath: '/prospecting',
      },
      {
        label: 'Commune',
        api: '/api/v1/search_areas?limit=10&type_code=COM&search=',
        routerPath: '/prospecting',
      },
    ],
    selectedType: {
      label: 'Espèce',
      api: '/api/v1/search_taxa?limit=10&search=',
      routerPath: '/prospecting',
    },
    selectIsOpen: false,
  }),
  watch: {
    search(newVal) {
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
  },
  methods: {
    updateSelectedData(data) {
      if (this.selectedType.label === 'Espèce') {
        this.$router.push({
          path: this.selectedType.routerPath,
          query: { species: `${data.code}` },
        })
      } else {
        this.$router.push({
          path: this.selectedType.routerPath,
          query: { municipality: `${data.code}` },
        })
      }
    },
    clearResults() {
      this.autocompleteIsOpen = false
      this.search = ''
    },
    updateSelectedType(type) {
      this.selectIsOpen = false
      this.selectedType = type
      this.updateSearch(this.search)
    },
    openOrCloseSelectBox() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSearchBarOpenedElements() {
      this.autocompleteIsOpen = false
      this.selectIsOpen = false
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
  },
}
</script>

<style scoped>
.AutocompleteWrapper {
  position: absolute;
  z-index: 5;
  background: #fff;
  width: 400px;
  align-self: flex-start;
  border: 1px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;

  /* box-shadow: 0 0 8px rgba(0, 0, 0, 0.16); */
  border-radius: 8px;
}

.AutocompleteWrapper input {
  background: rgba(38, 38, 38, 0.03);
  width: 400px;
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
}

.CloseIcon {
  width: 100%;
  cursor: pointer;
}

.SearchIconBox {
  background: #eece25;
  width: 30px;
  height: 30px;
  margin-left: 10px;
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
  padding: 1% 1% 2% 1%;
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
