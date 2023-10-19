<template>
  <div v-click-outside="closeSearchBar" class="AutocompleteWrapper">
    <input v-model="search" type="text" placeholder="Rechercher" />
    <div class="AutocompleteGadgets">
      <img
        v-if="search.length > 0"
        class="AutocompleteCloseIcon"
        src="/close.svg"
        @click="clearResults"
      />
      <div class="AutocompleteSearchSplit"></div>
      <div class="AutocompleteDropdownWrapper">
        <div
          class="AutocompleteDropdownSelectedOption"
          @click="openOrCloseSelectBox"
        >
          <h4 class="fw-500">{{ selectedType.label }}</h4>
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
            :class="type.value === selectedType.value ? 'selected' : ''"
            @click="updateSelectedType(type)"
          >
            {{ type.label }}
          </li>
        </div>
      </div>
      <div class="AutocompleteSearch">
        <img class="AutocompleteSearchIcon" src="/search.svg" />
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
          selectedType.value === 'species'
            ? data[`common_name_${lang}`]
            : data.name.replace('10kmL93', '').replace('10kmUTM22', '') +
              ' (' +
              data.code.slice(0, -3) +
              ')'
        }}
        <i v-if="selectedType.value === 'species'">({{ data.sci_name }})</i>
      </li>
      <span
        v-if="!dataList.length"
        class="black03 italic AutocompleteNoResults"
      >
        Aucun résultat trouvé, vous recherchez peut-être une
        <nuxt-link to="/about/glossary">espèce sensible</nuxt-link>.
      </span>
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
        value: 'species',
        label: 'Espèce',
        api: '/api/v1/search/taxa?limit=10&search=',
        route: '/species',
      },
      {
        value: 'place',
        label: 'Lieu',
        api: '/api/v1/search/areas?limit=10&type_code=COM&search=',
        route: '/prospecting',
      },
    ],
    selectedType: {
      value: 'species',
      label: 'Espèce',
      api: '/api/v1/search/taxa?limit=10&search=',
      route: '/species',
    },
    selectIsOpen: false,
    lang: 'fr',
  }),
  watch: {
    search(newVal) {
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
            console.debug(`${error}`)
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
            if (!data.length && this.selectedType.value === 'place') {
              this.autocompleteIsOpen = false
            } else {
              this.autocompleteIsOpen = true
              this.dataList = data
            }
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
      }
    },
    updateSelectedData(data) {
      if (this.selectedType.value === 'species') {
        this.$router.push({
          path: `${this.selectedType.route}/${data.code}`,
        })
      } else {
        this.$router.push({
          path: this.selectedType.route,
          query: { area: `${data.code}`, type: `${data.type_code}` },
        })
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
  background: #fff;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.24);
  border-radius: 16px;
}

.AutocompleteWrapper input {
  height: 60px;
  border-radius: 16px;
  padding-left: 34px;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
}

.AutocompleteGadgets {
  height: 60px;
  border-radius: 16px;
  padding: 0 10px;
}

.AutocompleteSearchSplit {
  height: 40px;
}

.AutocompleteDropdownWrapper {
  width: 160px;
}

.AutocompleteDropdownSelectedOption {
  height: 60px;
  margin-bottom: 5px;
  padding: 0 30px;
}

.DropdownChevron {
  width: 10px;
}

.DropdownOptionsBox {
  padding: 12px;
}

.DropdownOption {
  padding: 10px 18px;
  font-size: 16px;
  line-height: 24px;
}

.AutocompleteSearch {
  width: 40px;
  height: 40px;
  border-radius: 8px;
}

.AutocompleteSearchIcon {
  height: 18px;
}

.AutocompleteResultsSplit {
  width: calc(100% - 34px);
  margin-left: 34px;
}

.AutocompleteResults {
  padding: 17px;
}

.AutocompleteResultsOption {
  padding: 10px 17px;
  font-size: 14px;
  line-height: 21px;
}

.AutocompleteNoResults {
  padding: 3px 17px;
}

/********** RESPONSIVE **********/

@media screen and (width <= 680px) {
  .AutocompleteWrapper input {
    height: 50px;
    padding-left: 20px;
    font-size: 12px;
    line-height: 18px;
  }

  .AutocompleteGadgets {
    height: 50px;
    padding: 0 8px;
  }

  .AutocompleteCloseIcon {
    width: 16px;
    height: 16px;
    margin-right: 16px;
  }

  .AutocompleteSearchSplit {
    height: 32px;
  }

  .AutocompleteDropdownWrapper {
    width: 96px;
  }

  .AutocompleteDropdownSelectedOption {
    height: 50px;
    padding: 0 16px;
  }

  h4.fw-500 {
    font-size: 12px;
    line-height: 18px;
    font-weight: normal;
  }

  .DropdownChevron {
    width: 8px;
  }

  .DropdownOptionsBox {
    padding: 8px;
  }

  .DropdownOption {
    padding: 6px 8px;
    font-size: 12px;
    line-height: 18px;
  }

  .AutocompleteSearch {
    width: 34px;
    height: 34px;
  }

  .AutocompleteSearchIcon {
    height: 14px;
  }

  .AutocompleteResultsSplit {
    width: calc(100% - 20px);
    margin-left: 20px;
  }

  .AutocompleteResults {
    padding: 10px;
  }

  .AutocompleteResultsOption {
    padding: 6px 10px;
    font-size: 12px;
    line-height: 18px;
  }

  span.AutocompleteNoResults {
    padding: 0 10px;
    font-size: 12px;
    line-height: 18px;
  }
}

@media screen and (width <= 370px) {
  .AutocompleteCloseIcon {
    display: none;
  }
}
</style>
