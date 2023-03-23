<template>
  <header v-if="species">
    <div class="Heading">
      <v-skeleton-loader
        v-if="!species.medias.Photo_principale"
        type="avatar"
      ></v-skeleton-loader>
      <div
        v-if="species.medias.Photo_principale"
        class="SpeciesPicture"
        :style="{
          background: species.medias.Photo_principale
            ? `url('${species.medias.Photo_principale.url}') center / cover`
            : 'darkgrey',
        }"
      ></div>
      <div class="Title">
        <v-skeleton-loader
          v-if="!species.attributes.odf_common_name_fr"
          type="text"
        ></v-skeleton-loader>
        <h3 v-else class="fw-600">
          {{ species.attributes.odf_common_name_fr }}
        </h3>
        <v-skeleton-loader
          v-if="!species.attributes.odf_sci_name"
          type="text"
        ></v-skeleton-loader>
        <h5 v-else>
          <i>{{ species.attributes.odf_sci_name }}</i> &nbsp;|&nbsp;
          {{ species.attributes.odf_common_name_en }}
          <font class="not-on-mobile">
            &nbsp;|&nbsp; Synonymes : {{ species.attributes.common_synonyms }}
          </font>
        </h5>
      </div>
    </div>
    <div class="Metadata">
      <menu class="TabMenu no-bottom-margin">
        <div
          v-for="item in tabs"
          :key="item.value"
          class="TabItem"
          :class="item.hash === selectedTab.hash ? 'selected' : ''"
          @click="updateSelectedTab(item)"
        >
          {{ item.label }}
        </div>
      </menu>
      <!-- <dropdown-list
        v-model="selectedTabModel"
        :z-index="3"
        :items-list="tabs"
      /> -->
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
    selectedTab() {
      return this.$store.state.species.selectedTab
    },
    // Permet de mettre à jour selectedTab seulement après le $router.push
    selectedTabModel: {
      get() {
        return this.selectedTab
      },
      set(value) {
        this.$router.push(`${value.hash}`)
      },
    },
  },
  watch: {
    $route(newVal) {
      console.log(
        '$route',
        newVal,
        this.tabs.find((i) => {
          return (i.hash = newVal.hash)
        })
      )
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.$store.commit(
        'species/setSelectedTab',
        this.tabs.find((i) => {
          return (i.hash = newVal.hash)
        })
      )
      this.$parent.$refs.scrollingContainer.scrollTop = 0
    },
  },
  mounted() {
    this.$store.commit(
      'species/setSelectedTab',
      this.$route.hash
        ? this.tabs.find((i) => {
            return (i.hash = this.$route.hash)
          })
        : this.tabs[0]
    )
  },
  methods: {
    updateSelectedTab(item) {
      this.$store.commit('species/setSelectedTab', item)
      this.$router.push(`${item.hash}`)
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

@media screen and (max-width: 800px) {
  header {
    padding: 16px 5%;
  }
}

@media screen and (max-width: 430px) {
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
</style>
