<!-- Bouton jaune de recherche : afficher les recherches populaires -->
<template>
  <div
    v-click-outside="closeSearchBarOpenedElements"
    class="AutocompleteWrapper"
  >
    <input v-model="search" type="text" placeholder="Rechercher" />
    <div class="AutocompleteAdvanced">
      <div class="CloseIconBox">
        <img
          v-show="autocompleteIsOpen"
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
            :src="
              selectIsOpen
                ? '/select-chevron-up.svg'
                : '/select-chevron-down.svg'
            "
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
        routerPath: '/species-card/',
      },
      {
        label: 'Commune',
        api: '/api/v1/search_areas?limit=10&type_code=COM&search=',
        // À MODIFIER
        routerPath: '/species-card/',
      },
    ],
    selectedType: {
      label: 'Espèce',
      api: '/api/v1/search_taxa?limit=10&search=',
      routerPath: '/species-card/',
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
      this.$router.push({ path: this.selectedType.routerPath + `${data.code}` })
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
  background: #fff;
  position: relative;
  width: 100%;
  border: 1px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.24);
  border-radius: 16px;
}

.AutocompleteWrapper input {
  background: #fff;
  width: 100%;
  height: clamp(46px, 8vh, 72px);
  border: none;
  outline: none;
  box-sizing: border-box;
  border-radius: 16px;
  padding-left: 4%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: rgba(38, 38, 38, 0.6);
}

.AutocompleteAdvanced {
  position: absolute;
  top: 0;
  right: 0;
  height: clamp(46px, 8vh, 72px);
  border-radius: 16px;
  padding: 0 max(1.3vh, 7px);
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.CloseIconBox {
  width: 20px;
  height: 20px;
}

.CloseIcon {
  width: 100%;
  cursor: pointer;
}

.SearchSplit {
  width: 0;
  height: clamp(30px, 5.6vh, 50px);
  border: 1px solid rgba(38, 38, 38, 0.1);
  margin-left: 1.8vw;
}

.SelectTypeWrapper {
  width: 12.8vw;
  align-self: flex-start;
  display: flex;
  flex-direction: column;
}

.SelectedTypeContent {
  width: 100%;
  height: clamp(46px, 8vh, 72px);
  margin-bottom: 5px;
  padding: 0 1.8vw;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SelectedTypeText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
}

.SelectedTypeChevron {
  width: 0.74vw;
}

.SelectBox {
  background: #fcfcfc;
  width: 100%;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.15);
  border-radius: 8px;
  padding: 0.8vw 0.8vw;
  overflow: auto;
}

.SelectItem {
  list-style: none;
  width: 100%;
  padding: 5% 1vw;
  cursor: pointer;
  border-radius: 8px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
}

.SelectItem.selected {
  background: rgba(238, 206, 37, 0.4);
  font-weight: 600;
  color: #7b6804;
}

.SearchIconBox {
  background: #eece25;
  width: clamp(34px, 5.4vh, 48px);
  height: clamp(34px, 5.4vh, 48px);
  border-radius: 8px;
  display: flex;
}

.SearchIcon {
  height: clamp(14px, 2.25vh, 20px);
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
  font-size: 14px;
  line-height: 21px;
  color: #262626;
}

.AutocompleteItem:hover {
  background: rgba(238, 206, 37, 0.4);
  color: #7b6804;
  font-weight: 600;
}
</style>
