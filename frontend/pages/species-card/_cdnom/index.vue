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
          :z-index="3"
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
            :class="item.slug === selectedSubject.slug ? 'selected' : ''"
            @click="updateSelectedSubject(item)"
          >
            {{ item.label }}
          </div>
        </menu>
      </nav>
      <div ref="scrollingContainer" class="SpeciesCardTab">
        <div
          v-show="['diagrams', 'maps'].includes(selectedTab.value)"
          class="Selectors"
        >
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
        <div
          v-show="selectedTab.value === 'species-card'"
          ref="species-card"
          class="SpeciesCardContent"
        >
          Test Fiche espèce
        </div>
        <div
          v-show="
            selectedTab.value === 'diagrams' &&
            selectedSeason.value === 'all_period'
          "
          ref="diagrams all_period"
          class="SpeciesCardContent"
        >
          <div ref="phenology-all-period" class="DiagramCard scrolling-item">
            <h4 class="black02 fw-bold">Phénologie</h4>
          </div>
          <div ref="phenology-migration" class="DiagramCard scrolling-item">
            <h4 class="black02 fw-bold">Phénologie de migration</h4>
          </div>
          <div ref="altitude-all-period" class="DiagramCard scrolling-item">
            <h4 class="black02 fw-bold">
              Répartition altitudinale des observations
            </h4>
          </div>
          <div ref="test" class="DiagramCard scrolling-item">
            <h4 class="black02 fw-bold">Test</h4>
          </div>
        </div>
        <div
          v-show="
            selectedTab.value === 'diagrams' &&
            selectedSeason.value === 'breeding'
          "
          ref="diagrams breeding"
          class="SpeciesCardContent"
        >
          Test diagrammes Reproduction
        </div>
        <div
          v-show="
            selectedTab.value === 'diagrams' &&
            selectedSeason.value === 'wintering'
          "
          ref="diagrams wintering"
          class="SpeciesCardContent"
        >
          Test diagrammes Hivernage
        </div>
        <div
          v-show="selectedTab.value === 'maps'"
          ref="maps"
          class="SpeciesCardContent"
        >
          Test Cartes
        </div>
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
        value: 'species-card',
        hash: '',
        label: 'Fiche espèce',
        subjects: [
          { label: 'Description', slug: 'description' },
          { label: 'Taxonomie', slug: 'taxonomy' },
          { label: 'Statuts', slug: 'status' },
          { label: 'Caractéristiques', slug: 'characteristic' },
          { label: 'Téléchargements', slug: 'downloads' },
          { label: 'Liens', slug: 'links' },
        ],
      },
      {
        value: 'diagrams',
        hash: '#diagrams',
        label: 'Diagrammes',
        subjects: {
          all_period: [
            { label: 'Phénologie', slug: 'phenology-all-period' },
            { label: 'Phénologie de migration', slug: 'phenology-migration' },
            { label: 'Répartition altitudinale', slug: 'altitude-all-period' },
            { label: 'Test', slug: 'test' },
          ],
          breeding: [
            { label: 'Phénologie', slug: 'phenology-breeding' },
            { label: "Tendances d'évolution", slug: 'trends-breeding' },
            {
              label: 'Taille de populations',
              slug: 'populations-size-breeding',
            },
            { label: 'Répartition altitudinale', slug: 'altitude-breeding' },
          ],
          wintering: [
            { label: "Tendances d'évolution", slug: 'trends-wintering' },
            {
              label: 'Taille de populations',
              slug: 'populations-size-wintering',
            },
            { label: 'Répartition altitudinale', slug: 'altitude-wintering' },
          ],
        },
      },
      {
        value: 'maps',
        hash: '#maps',
        label: 'Cartes',
        subjects: [{ label: 'À définir...', slug: 'none' }],
      },
    ],
    selectedTab: { hash: '', label: '', subjects: [] },
    selectedSubject: { label: '', slug: '' },
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
    currentScrollingItems: {},
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
      this.defineSelectedTab()
      const id = this.selectedTab.subjects[this.selectedSeason.value]
        ? `${this.selectedTab.value} ${this.selectedSeason.value}`
        : this.selectedTab.value
      this.currentScrollingItems = [
        ...this.$refs[id].getElementsByClassName('scrolling-item'),
      ]
    },
    selectedSeason(newVal) {
      this.defineSelectedSubject()
      const id = this.selectedTab.subjects[this.selectedSeason.value]
        ? `${this.selectedTab.value} ${this.selectedSeason.value}`
        : this.selectedTab.value
      this.currentScrollingItems = [
        ...this.$refs[id].getElementsByClassName('scrolling-item'),
      ]
    },
  },
  mounted() {
    document.documentElement.style.overflow = 'hidden'
    document.body.style.position = 'fixed' // Needed for iOS
    // this.$refs.scrollingContainer.addEventListener('scroll', this.listener)
    this.$axios
      .$get(`/api/v1/search_taxa?limit=1&cd_nom=${this.cdnom}`)
      .then((data) => {
        this.species = data[0]
        console.log(this.species)
      })
      .catch((error) => {
        console.log(error)
      })
    this.defineSelectedTab()
  },
  // beforeDestroy() {
  //   this.$refs.scrollingContainer.removeEventListener('scroll', this.listener)
  // },
  methods: {
    defineSelectedTab() {
      this.selectedTab = this.tabs.filter((item) => {
        return item.hash === this.$route.hash
      })[0]
      this.defineSelectedSubject()
    },
    defineSelectedSubject() {
      this.selectedSubject = this.selectedTab.subjects[
        this.selectedSeason.value
      ]
        ? this.selectedTab.subjects[this.selectedSeason.value][0]
        : this.selectedTab.subjects[0]
    },
    updateSelectedTab(item) {
      this.$router.push(`${item.hash}`)
    },
    updateSelectedSubject(item) {
      this.selectedSubject = item
      if (this.$refs[item.slug]) {
        // this.$refs.scrollingContainer.removeEventListener(
        //   'scroll',
        //   this.listener
        // )
        this.$refs[item.slug].scrollIntoView({ behavior: 'smooth' })
        // this.$refs.scrollingContainer.addEventListener('scroll', this.listener)
      }
    },
    listener() {
      this.$debounce(this.handleScroll())
    },
    handleScroll() {
      const scroll = this.$refs.scrollingContainer.scrollTop
      const currentScrolledItem = this.currentScrollingItems.filter((item) => {
        return (
          item.offsetTop - 40 <= scroll &&
          item.offsetTop + item.offsetHeight > scroll
        )
      })
      if (currentScrolledItem.length > 0) {
        const currentSubjects = this.selectedTab.subjects[
          this.selectedSeason.value
        ]
          ? this.selectedTab.subjects[this.selectedSeason.value]
          : this.selectedTab.subjects
        this.selectedSubject = currentSubjects.filter((subject) => {
          return subject.slug === currentScrolledItem[0].id
        })[0]
      }
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  height: 100vh;
  max-height: 100vh;
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
  position: relative;
  display: flex;
}

nav.NavDrawer {
  background: #f8f8f8;
  width: 300px;
  padding: 24px 40px;
  display: flex;
  flex-direction: column;
}

.SpeciesCardTab {
  position: absolute;
  top: 0;
  left: 300px;
  right: 0;
  bottom: 0;
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

.SpeciesCardContent {
  width: 100%;
  display: flex;
  flex-direction: column;
}

.DiagramCard {
  width: 100%;
  height: 300px;
  max-width: 1050px;
  padding: 24px 32px;
  margin-bottom: 40px;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  align-self: center;
  scroll-margin: 12px;
}

.DiagramCard:last-child {
  margin-bottom: 0;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 920px) {
  nav.NavDrawer {
    display: none;
  }

  .SpeciesCardTab {
    left: 0;
  }
}

@media screen and (max-width: 800px) {
  header {
    padding: 16px 5%;
  }

  .SpeciesCardTab {
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
