<template>
  <div
    v-click-outside="closeSearchBar"
    class="AutocompleteWrapper map"
    :class="autocompleteIsOpen ? 'open' : ''"
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
      <div class="AutocompleteDropdownWrapper">
        <div
          class="AutocompleteDropdownSelectedOption"
          @click="openOrCloseSelectBox"
        >
          <h5 class="fw-500">{{ selectedType.label }}</h5>
          <img
            class="DropdownChevron"
            :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
          />
        </div>
        <div v-show="selectIsOpen" class="DropdownOptionsBox">
          <li
            v-for="(type, index) in typeList"
            :key="index"
            class="DropdownOption"
            :class="type.label === selectedType.label ? 'selected' : ''"
            @click="updateSelectedType(type)"
          >
            {{ type.label }}
          </li>
        </div>
      </div>
      <div class="AutocompleteSearch map">
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
        {{
          selectedType.label === 'Espèce'
            ? data[`common_name_${lang}`]
            : data.name.replace('10kmL93', '').replace('10kmUTM22', '')
        }}
        <i v-if="selectedType.label === 'Espèce'">({{ data.sci_name }})</i>
        {{
          selectedType.label === 'Lieu' && data.type_code !== 'ATLAS_GRID'
            ? ' (' + data.code.slice(0, -3) + ')'
            : ''
        }}
      </li>
      <h5
        v-if="dataList.length === 0"
        class="black03 italic AutocompleteNoResults"
      >
        Aucun résultat trouvé, vous recherchez peut-être une
        <nuxt-link to="/about/glossary">espèce sensible</nuxt-link>.
      </h5>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectedSpecies: {
      // Nécessaire si l'espèce est supprimée via son tableau de bord (ProspectingMap)
      type: Object,
      required: false,
      default: null,
    },
  },
  data: () => ({
    search: '',
    dataList: [],
    autocompleteIsOpen: false,
    typeList: [
      {
        label: 'Espèce',
        api: '/api/v1/search/taxa?limit=10&search=',
        placeholder: 'Rechercher une espèce...',
      },
      {
        label: 'Lieu',
        api: '/api/v1/search/areas?limit=10&search=',
        placeholder: 'Rechercher une commune, une maille...',
      },
    ],
    selectedType: {
      label: 'Lieu',
      api: '/api/v1/search/areas?limit=10&search=',
      placeholder: 'Rechercher une commune, une maille...',
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
            this.$axios
              .$get(this.selectedType.api + `${newVal}`)
              .then((data) => {
                if (data.length === 0 && this.selectedType.label === 'Lieu') {
                  this.autocompleteIsOpen = false
                } else {
                  this.autocompleteIsOpen = true
                  this.dataList = data
                }
              })
              .catch((error) => {
                console.log(error)
              })
          }
        } else {
          this.speciesIsSelected = false
          this.$emit('selectedSpecies', null)
          this.$router.push({
            path: '/prospecting',
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
  mounted() {
    if (this.$route.query.species) {
      this.$axios
        .$get(`/api/v1/search/taxa?cd_nom=${this.$route.query.species}`)
        .then((data) => {
          this.speciesIsSelected = true
          this.selectedType = this.typeList[0]
          this.searchIsProgramatic = true
          this.search = data[0][`common_name_${this.lang}`]
        })
        .catch((error) => {
          console.log(error)
        })
    }
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
            if (data.length === 0 && this.selectedType.label === 'Lieu') {
              this.autocompleteIsOpen = false
            } else {
              this.autocompleteIsOpen = true
              this.dataList = data
            }
          })
          .catch((error) => {
            console.log(error)
          })
      }
    },
    updateSelectedData(data) {
      if (this.selectedType.label === 'Espèce') {
        this.speciesIsSelected = true
        this.$emit('selectedSpecies', data)
        this.$router.push({
          path: '/prospecting',
          query: { species: `${data.code}` },
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

.AutocompleteWrapper.open {
  border: 1px solid #eece25;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.04);
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
