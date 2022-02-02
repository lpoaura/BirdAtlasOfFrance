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
        <div class="SpeciesCardTabRelative">
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
            ref="species-card"
            class="SpeciesCardContent"
            :class="selectedTab.value === 'species-card' ? '' : 'hidden'"
          >
            Fiche espèce
          </div>
          <div
            ref="diagrams all_period"
            class="SpeciesCardContent"
            :class="
              selectedTab.value === 'diagrams' &&
              selectedSeason.value === 'all_period'
                ? ''
                : 'hidden'
            "
          >
            <div ref="phenology-all-period" class="ChartCard scrolling-item">
              <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
              <h5 class="black03 bottom-margin-40">
                Nombre de données cumulées par décade du 1<sup>er</sup> janvier
                2019 au 31 décembre de l'année dernière.
              </h5>
              <phenology-all-period :formatted-data="dataPhenologyAllPeriod" />
            </div>
            <div ref="phenology-migration" class="ChartCard scrolling-item">
              <h4 class="black02 fw-bold bottom-margin-8">
                Phénologie de migration
              </h4>
              <h5 class="black03 bottom-margin-24">
                Nombre de données cumulées par décade du 1<sup>er</sup> janvier
                2019 au 31 décembre de l'année dernière.
              </h5>
              <phenology-migration :formatted-data="dataPhenologyMigration" />
            </div>
            <div ref="altitude-all-period" class="ChartCard scrolling-item">
              <h4 class="black02 fw-bold bottom-margin-8">
                Répartition altitudinale des observations
              </h4>
              <h5 class="black03 bottom-margin-40">
                Proportion des observations en fonction de l’altitude du
                territoire.
              </h5>
              <altitude :formatted-data="dataAltitude" />
            </div>
          </div>
          <div
            ref="diagrams breeding"
            class="SpeciesCardContent"
            :class="
              selectedTab.value === 'diagrams' &&
              selectedSeason.value === 'breeding'
                ? ''
                : 'hidden'
            "
          >
            <div ref="phenology-breeding" class="ChartCard scrolling-item">
              <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
              <h5 class="black03 bottom-margin-40">
                Nombre de données cumulées par décade du 1<sup>er</sup> janvier
                2019 au 31 décembre de l'année dernière.
              </h5>
              <phenology-breeding :formatted-data="dataPhenologyBreeding" />
            </div>
          </div>
          <div
            ref="diagrams wintering"
            class="SpeciesCardContent"
            :class="
              selectedTab.value === 'diagrams' &&
              selectedSeason.value === 'wintering'
                ? ''
                : 'hidden'
            "
          >
            Diagrammes Hivernage
          </div>
          <div
            ref="maps"
            class="SpeciesCardContent"
            :class="selectedTab.value === 'maps' ? '' : 'hidden'"
          >
            Cartes
          </div>
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
import PhenologyAllPeriod from '~/components/species-card/PhenologyAllPeriod.vue'
import PhenologyMigration from '~/components/species-card/PhenologyMigration.vue'
import PhenologyBreeding from '~/components/species-card/PhenologyBreeding.vue'
import Altitude from '~/components/species-card/Altitude.vue'

export default {
  components: {
    'phenology-all-period': PhenologyAllPeriod,
    'phenology-migration': PhenologyMigration,
    'phenology-breeding': PhenologyBreeding,
    altitude: Altitude,
  },
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
    dataPhenologyAllPeriod: {
      phenology: {
        label: 'Nombre de données',
        data: [
          { label: 'D1', count_data: 0 },
          { label: 'D2', count_data: 0 },
          { label: 'D3', count_data: 0 },
          { label: 'D4', count_data: 0 },
          { label: 'D5', count_data: 0 },
          { label: 'D6', count_data: 0 },
          { label: 'D7', count_data: 0 },
          { label: 'D8', count_data: 10 },
          { label: 'D9', count_data: 20 },
          { label: 'D10', count_data: 30 },
          { label: 'D11', count_data: 40 },
          { label: 'D12', count_data: 50 },
          { label: 'D13', count_data: 60 },
          { label: 'D14', count_data: 70 },
          { label: 'D15', count_data: 90 },
          { label: 'D16', count_data: 120 },
          { label: 'D17', count_data: 250 },
          { label: 'D18', count_data: 370 },
          { label: 'D19', count_data: 550 },
          { label: 'D20', count_data: 360 },
          { label: 'D21', count_data: 290 },
          { label: 'D22', count_data: 270 },
          { label: 'D23', count_data: 200 },
          { label: 'D24', count_data: 150 },
          { label: 'D25', count_data: 90 },
          { label: 'D26', count_data: 55 },
          { label: 'D27', count_data: 40 },
          { label: 'D28', count_data: 15 },
          { label: 'D29', count_data: 0 },
          { label: 'D30', count_data: 0 },
          { label: 'D31', count_data: 0 },
          { label: 'D32', count_data: 0 },
          { label: 'D33', count_data: 0 },
          { label: 'D34', count_data: 0 },
          { label: 'D35', count_data: 0 },
          { label: 'D36', count_data: 0 },
        ],
        color: '#435EF2',
      },
      frequency: {
        label: 'Fréquence dans les listes complètes',
        data: [
          { label: 'D1', frequency: 0 },
          { label: 'D2', frequency: 0 },
          { label: 'D3', frequency: 2 },
          { label: 'D4', frequency: 4.5 },
          { label: 'D5', frequency: 5 },
          { label: 'D6', frequency: 6 },
          { label: 'D7', frequency: 8 },
          { label: 'D8', frequency: 11 },
          { label: 'D9', frequency: 12 },
          { label: 'D10', frequency: 14 },
          { label: 'D11', frequency: 14.5 },
          { label: 'D12', frequency: 16 },
          { label: 'D13', frequency: 19 },
          { label: 'D14', frequency: 24 },
          { label: 'D15', frequency: 24.5 },
          { label: 'D16', frequency: 26 },
          { label: 'D17', frequency: 28 },
          { label: 'D18', frequency: 29 },
          { label: 'D19', frequency: 26 },
          { label: 'D20', frequency: 24.5 },
          { label: 'D21', frequency: 22 },
          { label: 'D22', frequency: 21 },
          { label: 'D23', frequency: 19 },
          { label: 'D24', frequency: 17 },
          { label: 'D25', frequency: 16 },
          { label: 'D26', frequency: 14.5 },
          { label: 'D27', frequency: 9.5 },
          { label: 'D28', frequency: 7 },
          { label: 'D29', frequency: 5 },
          { label: 'D30', frequency: 4.5 },
          { label: 'D31', frequency: 4.5 },
          { label: 'D32', frequency: 3.5 },
          { label: 'D33', frequency: 2 },
          { label: 'D34', frequency: 0 },
          { label: 'D35', frequency: 0 },
          { label: 'D36', frequency: 0 },
        ],
        color: '#8CCB6E',
      },
    },
    dataPhenologyMigration: {
      phenology: {
        label: 'Nombre de données en migration active',
        data: [
          { label: 'D1', count_data: 0 },
          { label: 'D2', count_data: 0 },
          { label: 'D3', count_data: 0 },
          { label: 'D4', count_data: 0 },
          { label: 'D5', count_data: 0 },
          { label: 'D6', count_data: 0 },
          { label: 'D7', count_data: 5 },
          { label: 'D8', count_data: 10 },
          { label: 'D9', count_data: 15 },
          { label: 'D10', count_data: 80 },
          { label: 'D11', count_data: 110 },
          { label: 'D12', count_data: 380 },
          { label: 'D13', count_data: 560 },
          { label: 'D14', count_data: 385 },
          { label: 'D15', count_data: 270 },
          { label: 'D16', count_data: 150 },
          { label: 'D17', count_data: 55 },
          { label: 'D18', count_data: 20 },
          { label: 'D19', count_data: 0 },
          { label: 'D20', count_data: 0 },
          { label: 'D21', count_data: 0 },
          { label: 'D22', count_data: 0 },
          { label: 'D23', count_data: 0 },
          { label: 'D24', count_data: 5 },
          { label: 'D25', count_data: 80 },
          { label: 'D26', count_data: 285 },
          { label: 'D27', count_data: 410 },
          { label: 'D28', count_data: 505 },
          { label: 'D29', count_data: 560 },
          { label: 'D30', count_data: 360 },
          { label: 'D31', count_data: 250 },
          { label: 'D32', count_data: 205 },
          { label: 'D33', count_data: 40 },
          { label: 'D34', count_data: 0 },
          { label: 'D35', count_data: 0 },
          { label: 'D36', count_data: 0 },
        ],
        color: '#435EF2',
      },
      prenuptial: {
        label: 'Migration prénuptiale',
        data: ['D9', 'D12', 'D15'],
        colors: { quantile: 'rgba(57, 118, 90, 0.1)', median: '#39765A' },
      },
      postnuptial: {
        label: 'Migration postnuptiale',
        data: ['D26', 'D29', 'D32'],
        colors: { quantile: 'rgba(235, 106, 10, 0.1)', median: '#EB6A0A' },
      },
    },
    dataPhenologyBreeding: {
      label: 'Nombre de données',
      atlasCodes: ['Mâle chanteur', 'Jeunes'],
      data: [
        { label: 'D1', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D2', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D3', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D4', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D5', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D6', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D7', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D8', firstAtlasCode: 10, secondAtlasCode: 0 },
        { label: 'D9', firstAtlasCode: 20, secondAtlasCode: 0 },
        { label: 'D10', firstAtlasCode: 30, secondAtlasCode: 0 },
        { label: 'D11', firstAtlasCode: 40, secondAtlasCode: 0 },
        { label: 'D12', firstAtlasCode: 50, secondAtlasCode: 0 },
        { label: 'D13', firstAtlasCode: 60, secondAtlasCode: 0 },
        { label: 'D14', firstAtlasCode: 70, secondAtlasCode: 0 },
        { label: 'D15', firstAtlasCode: 90, secondAtlasCode: 0 },
        { label: 'D16', firstAtlasCode: 120, secondAtlasCode: 10 },
        { label: 'D17', firstAtlasCode: 250, secondAtlasCode: 20 },
        { label: 'D18', firstAtlasCode: 370, secondAtlasCode: 40 },
        { label: 'D19', firstAtlasCode: 550, secondAtlasCode: 50 },
        { label: 'D20', firstAtlasCode: 360, secondAtlasCode: 70 },
        { label: 'D21', firstAtlasCode: 290, secondAtlasCode: 90 },
        { label: 'D22', firstAtlasCode: 270, secondAtlasCode: 95 },
        { label: 'D23', firstAtlasCode: 200, secondAtlasCode: 140 },
        { label: 'D24', firstAtlasCode: 150, secondAtlasCode: 170 },
        { label: 'D25', firstAtlasCode: 90, secondAtlasCode: 150 },
        { label: 'D26', firstAtlasCode: 55, secondAtlasCode: 130 },
        { label: 'D27', firstAtlasCode: 40, secondAtlasCode: 100 },
        { label: 'D28', firstAtlasCode: 15, secondAtlasCode: 90 },
        { label: 'D29', firstAtlasCode: 0, secondAtlasCode: 80 },
        { label: 'D30', firstAtlasCode: 0, secondAtlasCode: 70 },
        { label: 'D31', firstAtlasCode: 0, secondAtlasCode: 50 },
        { label: 'D32', firstAtlasCode: 0, secondAtlasCode: 20 },
        { label: 'D33', firstAtlasCode: 0, secondAtlasCode: 10 },
        { label: 'D34', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D35', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D36', firstAtlasCode: 0, secondAtlasCode: 0 },
      ],
      colors: ['#435EF2', '#E56B6F'],
    },
    dataAltitude: {
      altitude: {
        label: 'Répartition des observations',
        data: [
          { label: 0, altitude: 0 },
          { label: 100, altitude: 0 },
          { label: 200, altitude: 0 },
          { label: 300, altitude: 0 },
          { label: 400, altitude: 0 },
          { label: 500, altitude: 0 },
          { label: 600, altitude: 0 },
          { label: 700, altitude: 0 },
          { label: 800, altitude: 0 },
          { label: 900, altitude: 0 },
          { label: 1000, altitude: 0 },
          { label: 1100, altitude: 0 },
          { label: 1200, altitude: 4 },
          { label: 1300, altitude: 14 },
          { label: 1400, altitude: 26 },
          { label: 1500, altitude: 35 },
          { label: 1600, altitude: 42 },
          { label: 1700, altitude: 49 },
          { label: 1800, altitude: 55 },
          { label: 1900, altitude: 58 },
          { label: 2000, altitude: 61 },
          { label: 2100, altitude: 63 },
          { label: 2200, altitude: 62.5 },
          { label: 2300, altitude: 60.5 },
          { label: 2400, altitude: 57 },
          { label: 2500, altitude: 51 },
          { label: 2600, altitude: 50 },
          { label: 2700, altitude: 39 },
          { label: 2800, altitude: 32 },
          { label: 2900, altitude: 22 },
          { label: 3000, altitude: 12 },
          { label: 3100, altitude: 3 },
          { label: 3200, altitude: 0 },
          { label: 3300, altitude: 0 },
          { label: 3400, altitude: 0 },
          { label: 3500, altitude: 0 },
        ],
        color: '#435EF2',
      },
      globalAltitude: {
        label: "Répartition de l'altitude du territoire",
        data: [
          { label: 0, altitude: 60 },
          { label: 100, altitude: 30 },
          { label: 500, altitude: 45 },
          { label: 600, altitude: 15 },
          { label: 1700, altitude: 5 },
          { label: 3500, altitude: 0 },
        ],
        color: 'rgba(67, 94, 242, 0.1)',
      },
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
        // console.log(this.species)
      })
      .catch((error) => {
        console.log(error)
      })
    this.defineSelectedTab()
  },
  beforeDestroy() {
    document.documentElement.style.removeProperty('overflow')
    document.body.style.removeProperty('position')
    // this.$refs.scrollingContainer.removeEventListener('scroll', this.listener)
  },
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
  display: flex;
  flex-direction: column;
}

.SpeciesCardTabRelative {
  position: relative;
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

.SpeciesCardContent.hidden {
  position: absolute !important;
  top: -9999px !important;
  left: -9999px !important;
}

.ChartCard {
  width: 100%;
  max-width: 1050px;
  padding: 24px 32px;
  margin-bottom: 40px;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  align-self: center;
  scroll-margin: 12px;
  display: flex;
  flex-direction: column;
}

.ChartCard:last-child {
  margin-bottom: 0;
}

.ChartWrapper >>> .Chart {
  height: 300px;
  overflow-y: hidden;
  overflow-x: auto;
  touch-action: auto;
  -webkit-overflow-scrolling: touch; /* iOS */
}

.ChartWrapper >>> .ChartLegend {
  margin-top: 40px;
  display: flex;
  justify-content: center;
}

.ChartWrapper >>> .ChartLegendLabel {
  margin-right: 20px;
  display: flex;
  align-items: center;
}

.ChartWrapper >>> .ChartLegendLabel:last-child {
  margin-right: 0;
}

.ChartWrapper >>> .ChartLegendLabel i {
  width: 16px;
  min-width: 16px;
  height: 16px;
  min-height: 16px;
  float: left;
  margin-right: 12px;
}

.ChartWrapper >>> .ChartLegendLabel i.round {
  border-radius: 50%;
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
