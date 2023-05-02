<template>
  <div>
    <div
      class="AutocompleteWrapper map"
      :class="search.length > 0 ? 'open' : ''"
    >
      <input
        v-model="search"
        class="large"
        type="text"
        :placeholder="selectedType.placeholder"
      />
      <input
        v-model="search"
        class="small"
        type="text"
        placeholder="Rechercher"
      />
      <div class="AutocompleteGadgets map">
        <img
          v-if="search.length > 0"
          class="AutocompleteCloseIcon map"
          src="/close.svg"
          @click="clearResults"
        />
        <div class="AutocompleteSearchSplit"></div>
        <div class="AutocompleteSearch map" @click="$emit('close')">
          <img class="AutocompleteSearchIcon map" src="/search.svg" />
        </div>
      </div>
      <div v-show="autocompleteIsOpen" class="AutocompleteResultsSplit"></div>
      <div v-show="autocompleteIsOpen" class="AutocompleteResults">
        <li
          v-for="data in dataList"
          :key="data.code"
          class="AutocompleteResultsOption"
          @click="updateSelectedData(data)"
        >
          {{ data[`common_name_${lang}`] }}
          <i v-if="selectedType.value === 'species'">({{ data.sci_name }})</i>
        </li>
        <h5
          v-if="!dataList.length"
          class="black03 italic AutocompleteNoResults"
        >
          Aucun résultat trouvé, vous recherchez peut-être une
          <nuxt-link to="/about/glossary">espèce sensible</nuxt-link>.
        </h5>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    widgetStatus: {
      type: Boolean,
      required: true,
    },
  },
  data: () => ({
    search: '',
    dataList: [],
    autocompleteIsOpen: false,
    selectedType: {
      value: 'species',
      label: 'Espèce',
      api: '/api/v1/search/taxa',
      placeholder: 'Rechercher une espèce...',
    },
    selectIsOpen: false,
    speciesIsSelected: false,
    searchIsProgramatic: false,
    lang: 'fr',
  }),
  watch: {
    search(newVal) {
      if (!this.searchIsProgramatic) {
        if (!this.speciesIsSelected) {
          if (newVal === '' || newVal.length < 3) {
            this.autocompleteIsOpen = false
          } else {
            const params = {
              limit: 10,
              search: newVal,
            }
            this.$axios
              .$get(this.selectedType.api, { params })
              .then((data) => {
                this.autocompleteIsOpen = true
                this.dataList = data
              })
              .catch((error) => {
                console.error(error)
              })
          }
        } else {
          this.speciesIsSelected = false
          this.$emit('selectedSpecies', null)
          this.$router.push({
            path: '/species/',
            query: { species: undefined },
          })
        }
      }
      this.searchIsProgramatic = false
    },
    selectedSpecies(newVal) {
      if (!newVal) {
        this.speciesIsSelected = false
        this.search = ''
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
      if (!this.speciesIsSelected) {
        this.updateSearch(this.search)
      }
    },
    updateSearch(newVal) {
      if (newVal === '' || newVal.length < 3) {
        this.autocompleteIsOpen = false
      } else {
        this.$axios
          .$get(this.selectedType.api + `${newVal}`)
          .then((data) => {
            if (!data.length && this.selectedType.value === 'place') {
              this.autocompleteIsOpen = false
            } else {
              this.autocompleteIsOpen = true
              this.dataList = data
            }
          })
          .catch((error) => {
            console.error(error)
          })
      }
    },
    updateSelectedData(data) {
      if (this.selectedType.value === 'species') {
        this.speciesIsSelected = true
        this.$emit('selectedSpecies', data)
        this.$router.push({
          path: `/species/${data.code}`,
        })
        if (this.search !== data[`common_name_${this.lang}`]) {
          this.searchIsProgramatic = true
          this.search = data[`common_name_${this.lang}`]
        }
      } else {
        this.$emit('selectedArea', data)
        this.$router.push({
          path: '/prospecting',
          query: { area: `${data.code}`, type: `${data.type_code}` },
        })
        if (
          this.search !==
          data.name.replace('10kmL93', '').replace('10kmUTM22', '')
        ) {
          this.searchIsProgramatic = true
          this.search = data.name
            .replace('10kmL93', '')
            .replace('10kmUTM22', '')
        }
      }
      this.autocompleteIsOpen = false
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
  z-index: 5;
}

.AutocompleteWrapper input.small {
  display: none;
}

.AutocompleteSearchSplit {
  height: 26px;
}

.AutocompleteDropdownWrapper {
  width: 106px;
}

.AutocompleteDropdownSelectedOption {
  height: 42px;
  margin-bottom: 5px;
  padding: 0 16px;
}

.DropdownChevron {
  width: 7px;
}

.DropdownOptionsBox {
  padding: 8px;
}

.DropdownOption {
  padding: 6px 8px;
  font-size: 12px;
  line-height: 18px;
}

.AutocompleteResultsSplit {
  width: calc(100% - 10px);
  margin-left: 5px;
}

.AutocompleteResults {
  padding: 8px;
}

.AutocompleteResultsOption {
  padding: 6px 8px;
  font-size: 12px;
  line-height: 18px;
}

.AutocompleteNoResults {
  padding: 4px 8px;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 440px) {
  .AutocompleteWrapper input.large {
    display: none;
  }

  .AutocompleteWrapper input.small {
    display: flex;
  }
}
</style>
