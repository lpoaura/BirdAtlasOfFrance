<template>
  <v-container fluid>
    <header>
      <div class="Heading">
        <div class="SpeciesPicture"></div>
        <div class="Title">
          <h3 class="fw-600">{{ species.common_name_fr }}</h3>
          <h5>
            <i>{{ species.sci_name }}</i> &nbsp;|&nbsp;
            {{ species.common_name_en }}
            <font class="not-on-mobile">
              &nbsp;|&nbsp;Synonymes :
              <font style="color: red">blablabla, blablablablabla</font>
            </font>
          </h5>
        </div>
      </div>
      <div class="Metadata">
        <menu class="TabMenu no-bottom-margin">
          <div
            v-for="(item, index) in tabs"
            :key="'tab' + index"
            class="TabItem"
            :class="item.hash === selectedTab.hash ? 'selected' : ''"
            @click="updateSelectedTab(item)"
          >
            {{ item.label }}
          </div>
        </menu>
        <dropdown-list
          v-model="selectedTabModel"
          :z-index="1"
          :items-list="tabs"
        />
      </div>
    </header>
    <section class="SpeciesCardSection">
      <nav class="NavDrawer">
        <menu class="TabMenu vertical no-bottom-margin">
          <div
            v-for="(item, index) in subjectsList"
            :key="'subject' + index"
            class="TabItem vertical"
            :class="item === selectedSubject ? 'selected' : ''"
            @click="updateSelectedSubject(item)"
          >
            {{ item }}
          </div>
        </menu>
      </nav>
      <div class="SpeciesCardContent">
        <div class="Selectors">
          <dropdown-list
            v-model="selectedSeason"
            :z-index="2"
            :items-list="seasonsList"
            icon="/calendar-green.svg"
          />
          <dropdown-list
            v-model="selectedTerritory"
            :z-index="1"
            :items-list="territoriesList"
            icon="/location-green.svg"
          />
        </div>
        Mettre un slider (overflow: auto) dans cette section
      </div>
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    species: {},
    tabs: [
      {
        hash: '',
        label: 'Fiche espèce',
        subjects: [
          'Description',
          'Taxonomie',
          'Statuts',
          'Caractéristiques',
          'Téléchargements',
          'Liens',
        ],
      },
      {
        hash: '#diagrams',
        label: 'Diagrammes',
        subjects: {
          all_period: [
            'Phénologie',
            'Phénologie de migration',
            'Répartition altitudinale',
          ],
          breeding: [
            'Phénologie',
            "Tendances d'évolution",
            'Taille de populations',
            'Répartition altitudinale',
          ],
          wintering: [
            "Tendances d'évolution",
            'Taille de populations',
            'Répartition altitudinale',
          ],
        },
      },
      { hash: '#maps', label: 'Cartes', subjects: ['À définir...'] },
    ],
    selectedTab: { hash: '', label: '', subjects: [] },
    selectedSubject: 'Description',
    seasonsList: [
      {
        label: 'Toutes saisons',
        value: 'all_period',
      },
      {
        label: 'Période de reproduction',
        value: 'breeding',
      },
      {
        label: "Période d'hivernage",
        value: 'wintering',
      },
    ],
    selectedSeason: {
      label: 'Toutes saisons',
      value: 'all_period',
    },
    territoriesList: [
      {
        label: 'France métropolitaine',
        icon: '/prospecting/France-metropolitaine.svg',
      },
      {
        label: 'Guadeloupe',
        icon: '/prospecting/Guadeloupe.svg',
      },
      {
        label: 'Guyane',
        icon: '/prospecting/Guyane.svg',
      },
      {
        label: 'Martinique',
        icon: '/prospecting/Martinique.svg',
      },
      {
        label: 'Mayotte',
        icon: '/prospecting/Mayotte.svg',
      },
      {
        label: 'Nouvelle Calédonie',
        icon: '/prospecting/Nouvelle-Caledonie.svg',
      },
      {
        label: 'Polynésie Française',
        icon: '/prospecting/Polynesie.svg',
      },
      {
        label: 'La Réunion',
        icon: '/prospecting/Reunion.svg',
      },
      {
        label: 'Saint Barthélémy',
        icon: '/prospecting/Saint-Barthelemy.svg',
      },
      {
        label: 'Saint Martin',
        icon: '/prospecting/Saint-Martin.svg',
      },
      {
        label: 'Saint Pierre et Miquelon',
        icon: '/prospecting/Saint-Pierre-et-Miquelon.svg',
      },
      {
        label: 'Terres Australes et Antarctiques Françaises',
        icon: '/prospecting/TAAF.svg',
      },
      {
        label: 'Wallis et Futuna',
        icon: '/prospecting/Wallis-et-Futuna.svg',
      },
    ],
    selectedTerritory: {
      label: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
    },
  }),
  head: {
    title: 'Fiche espèce',
  },
  computed: {
    cdnom() {
      return this.$route.params.cdnom
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
    subjectsList() {
      return (
        this.selectedTab.subjects[this.selectedSeason.value] ??
        this.selectedTab.subjects
      )
    },
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.selectedTab = this.tabs.filter((item) => {
        return item.hash === newVal.hash
      })[0]
      this.selectedSubject = this.selectedTab.subjects[
        this.selectedSeason.value
      ]
        ? this.selectedTab.subjects[this.selectedSeason.value][0]
        : this.selectedTab.subjects[0]
    },
    selectedSeason(newVal) {
      this.selectedSubject = this.selectedTab.subjects[
        this.selectedSeason.value
      ]
        ? this.selectedTab.subjects[this.selectedSeason.value][0]
        : this.selectedTab.subjects[0]
    },
  },
  mounted() {
    this.$axios
      .$get(`/api/v1/search_taxa?limit=1&cd_nom=${this.cdnom}`)
      .then((data) => {
        this.species = data[0]
        console.log(this.species)
      })
      .catch((error) => {
        console.log(error)
      })
    this.selectedTab = this.tabs.filter((item) => {
      return item.hash === this.$route.hash
    })[0]
  },
  methods: {
    updateSelectedTab(item) {
      this.$router.push(`${item.hash}`)
    },
    updateSelectedSubject(item) {
      this.selectedSubject = item
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  height: 100vh;
  padding-top: 68px;
  display: flex;
  flex-direction: column;
}

header {
  background: #fcfcfc;
  width: 100%;
  padding: 16px 40px;
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
  display: flex;
  align-items: center;

  /* justify-content: space-between; */
  column-gap: 24px;
  row-gap: 16px;
  flex-wrap: wrap;
}

.Heading {
  display: flex;
  align-items: center;
}

.SpeciesPicture {
  /* Background à remplacer avec l'url de l'image */
  background: darkgrey;
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

.SpeciesCardSection {
  flex: 1;
  display: flex;
  align-items: stretch;
}

nav.NavDrawer {
  background: #f8f8f8;
  width: 300px;
  padding: 24px 40px;
  display: flex;
  flex-direction: column;
}

.SpeciesCardContent {
  flex: 1;
  padding: 24px 40px;
  overflow-y: auto;
}

.Selectors {
  display: flex;
  justify-content: flex-end;
}

.Selectors .DropdownListWrapper {
  width: fit-content;
  max-width: 300px;
  margin-right: 8px;
}

.Selectors .DropdownListWrapper:last-child {
  margin-right: 0;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 920px) {
  nav.NavDrawer {
    display: none;
  }
}

@media screen and (max-width: 800px) {
  header {
    padding: 16px 5%;
  }

  .SpeciesCardContent {
    padding: 24px 5%;
  }
}

/* POTENTIELLEMENT AJUSTER LE max-width */
@media screen and (max-width: 610px) {
  .Selectors {
    flex-direction: column;
  }

  .Selectors .DropdownListWrapper {
    width: 100%;
    max-width: none;
    margin-right: 0;
  }

  .Selectors .DropdownListWrapper:first-child {
    margin-bottom: 8px;
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
