<!-- 1/ Réadapter le css -->
<!-- 2/ Intégrer l'API et le côté dynamique -->
<template>
  <div
    v-click-outside="closeSearchBar"
    class="AutocompleteWrapper"
    :class="autocompleteIsOpen ? 'open' : ''"
  >
    <input
      v-model="search"
      type="text"
      placeholder="Rechercher une commune, une maille, une espèce..."
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
        label: 'Espèce',
        api: '/api/v1/search_taxa?limit=10&search=',
        // routerPath: '/prospecting',
      },
      {
        label: 'Lieu',
        api: '/api/v1/search_areas?limit=10&search=',
        // routerPath: '/prospecting',
      },
    ],
    selectedType: {
      label: 'Lieu',
      api: '/api/v1/search_areas?limit=10&search=',
      // routerPath: '/prospecting',
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
        this.$router.push({
          path: this.selectedType.routerPath,
          query: { species: `${data.code}` },
        })
      } else {
        this.$emit('selectedMunicipality', data)
        this.autocompleteIsOpen = false
      }
    },
    clearResults() {
      this.autocompleteIsOpen = false
      this.search = ''
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
  width: 400px;
  align-self: flex-start;
  border: 1px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
}

.AutocompleteWrapper.open {
  border: 1px solid #eece25;
}

.AutocompleteWrapper input {
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
