<template>
  <header v-if="species">
    <div class="Heading">
      <v-skeleton-loader v-if="!medias?.Photo_principale && !medias?.Photos" class="SpeciesPicture"
        type="avatar"></v-skeleton-loader>
      <div v-if="medias?.Photo_principale || medias?.Photos" class="SpeciesPicture" :style="{
        background: medias?.Photo_principale
          ? `url('${medias?.Photo_principale.url}') center / cover`
          : medias.Photos[0]
            ? `url('${medias?.Photos[0].url}') center / cover`
            : 'darkgrey',
      }"></div>
      <div v-if="!searchMode" class="Title" @click="searchMode = true">
        <v-tooltip bottom>
          <template #activator="{ on, attrs }">
            <span v-bind="attrs" class="black02 flex-1 right-margin-8" v-on="on">
              <h3 class="fw-600">
                {{ attributes?.odf_common_name_fr || species.frenchVernacularName || attributes?.odf_sci_name ||
                  attributes?.referenceNameHtml }}
              </h3>
            </span>
          </template>
          <v-skeleton-loader v-if="!species.frenchVernacularName" type="text">&nbsp;</v-skeleton-loader>
          Rechercher une autre espèce
        </v-tooltip>
        <h5 v-if="species.referenceNameHtml">
          <span v-html="species.referenceNameHtml"></span> &nbsp;|&nbsp;
          {{ species.englishVernacularName }}
          <font class="not-on-mobile">
            &nbsp;|&nbsp; Synonymes : {{ attributes?.common_synonyms }}
          </font>
        </h5>
      </div>
      <div v-else class="searchWidget">
        <species-search-widget :widget-status="searchMode" @close="searchMode = false" />
      </div>
    </div>
    <div class="Metadata">
      <menu class="TabMenu no-bottom-margin">
        <div v-for="item in tabs" :key="item.value" class="TabItem"
          :class="item.hash === selectedTab.hash ? 'selected' : ''" @click="updateSelectedTab(item)">
          {{ item.label }}
        </div>
      </menu>
      <dropdown-list v-model="selectedTabModel" :z-index="3" :items-list="tabs" />
    </div>
  </header>
</template>

<script>
export default {
  props: {
    species: {
      type: Object,
      required: true,
    },
  },
  data: () => {
    return {
      searchMode: false,
      regulatory: null,
      redList: null,
      tabs: [
        {
          value: 'monography',
          hash: '#monography',
          label: 'Fiche espèce',
        },
        {
          value: 'charts',
          hash: '#charts',
          label: 'Diagrammes',
        },
        {
          value: 'maps',
          hash: '#maps',
          label: 'Cartes',
        },
      ],
    }
  },

  computed: {
    cdNom() {
      return this.$store.state.species.cdNom
    },
    medias() {
      return this.$store.state.species.medias
    },
    attributes() {
      return this.$store.state.species.attributes
    },
    selectedTab() {
      return this.$store.state.species.selectedTab
    },
    // Permet de mettre à jour selectedTab seulement après le $router.push
    selectedTabModel: {
      get() {
        return this.selectedTab
      },
      set(value) {
        this.updateSelectedTab(value)
      },
    },
  },
  watch: {
    $route(newVal) {
      // /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      // this.$store.commit(
      //   'species/setSelectedTab',
      //   this.tabs.find((i) => {
      //     return (i.hash = newVal.hash)
      //   })
      // )
      this.$parent.$refs.scrollingContainer.scrollTop = 0
    },
  },
  mounted() {
    this.$store.commit(
      'species/setSelectedTab',
      this.$route.hash
        ? this.tabs.find((i) => {
          return i.hash === this.$route.hash
        })
        : this.tabs[0]
    )
  },
  methods: {
    updateSelectedTab(item) {
      this.$store.commit('species/setSelectedTab', item)
      this.$router.push(`${item.hash}`)
    },
    revertSearchMode() {
      console.log(this.searchMode)
      this.searchMode = !this.searchMode
    },
  },
}
</script>

<style scoped>
header {
  background: #fcfcfc;
  padding: 16px 40px;
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
  display: flex;
  align-items: center;
  column-gap: 24px;
  row-gap: 16px;
  flex-wrap: wrap;
}

.Heading {
  display: flex;
  align-items: center;
}

.SpeciesPicture {
  min-width: 50px;
  max-width: 50px;
  min-height: 50px;
  max-height: 50px;
  border-radius: 50%;
  margin-right: 36px;
}

.Title {
  display: flex;
  flex-direction: column;
  cursor: pointer;
}

.Metadata {
  flex: 1 1 390px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.Metadata .DropdownListWrapper {
  display: none;
}

@media screen and (width <= 800px) {
  header {
    padding: 16px 5%;
  }
}

@media screen and (width <= 430px) {
  .not-on-mobile {
    display: none;
  }

  div.container.container--fluid header .TabMenu {
    display: none;
  }

  div.container.container--fluid header .DropdownListWrapper {
    display: block;
    margin-bottom: 0;
  }
}

.searchWidget {
  max-width: 420px;
  height: 42px;
}
</style>
