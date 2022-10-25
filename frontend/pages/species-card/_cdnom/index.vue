<template>
  <v-container fluid>
    <header>
      <div class="Heading">
        <div
          class="SpeciesPicture"
          :style="{
            background: species.medias.Photo_principale
              ? `url('${species.medias.Photo_principale.url}') center / cover`
              : 'darkgrey'
          }"
        ></div>
        <div class="Title">
          <h3 class="fw-600">
            {{ species.attributes.odf_common_name_fr }}
          </h3>
          <h5>
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
        <dropdown-list
          v-model="selectedTabModel"
          :z-index="3"
          :items-list="tabs"
        />
      </div>
    </header>
    <section class="SpeciesCardSection">
      <nav class="NavDrawer">
        <menu
          v-if="['species', 'charts'].includes(selectedTab.value)"
          class="TabMenu vertical no-bottom-margin"
        >
          <div
            v-for="item in subjectsList"
            :key="item.slug"
            class="TabItem vertical"
            :class="item.slug === selectedSubject.slug ? 'selected' : ''"
            @click="updateSelectedSubject(item)"
          >
            {{ item.label }}
          </div>
        </menu>
        <menu v-if="selectedTab.value === 'maps'">
          <div class="SeeMoreWrapper" @click="updateAtlasStatus">
            <span class="black02 fw-600 bottom-margin-">Atlas</span>
            <img
              class="SeeMoreChevron"
              :src="atlasIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
            />
          </div>
          <div v-show="atlasIsOpen">
            <div
              v-for="item in tabs[2].subjects.atlas"
              :key="item.slug"
              class="TabItem vertical atlas"
              :class="item.slug === selectedSubject.slug ? 'selected' : ''"
              :title="item.name"
              @click="updateSelectedSubject(item)"
            >
              {{ item.label }}
            </div>
          </div>
          <div
            v-for="item in tabs[2].subjects.others"
            :key="item.slug"
            class="TabItem vertical fw-600"
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
            v-show="['charts', 'maps'].includes(selectedTab.value)"
            class="MapSelectors"
            :class="selectedTab.value === 'maps' ? 'map' : ''"
          >
            <div v-show="selectedTab.value === 'maps'" class="MapTitle">
              <h4 class="black02 fw-bold">
                {{ selectedSubject.name }}
              </h4>
              <h5
                v-show="
                  selectedTab.value === 'maps' &&
                  selectedSubject.label !== selectedSubject.name
                "
                class="black03"
              >
                {{ selectedSubject.label }}
              </h5>
            </div>
            <div class="MapSelectorsWrapper">
              <div
                v-click-outside="closeSeasonsBox"
                class="MapSelectorWrapper seasons"
              >
                <div
                  class="MapSelectorSelectedOption"
                  @click="openOrCloseSeasonsBox"
                >
                  <img class="MapSelectorIcon" src="/calendar.svg" />
                  <h5 class="fw-600 right-margin-12">
                    {{ selectedSeason.label }}
                  </h5>
                  <img
                    class="MapSelectorChevron"
                    :src="
                      seasonIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'
                    "
                  />
                </div>
                <seasons-selector
                  :select-is-open="seasonIsOpen"
                  :selected-season="selectedSeason"
                  :filtered-seasons="
                    selectedTab.value === 'maps'
                      ? selectedSubject.seasons
                      : null
                  "
                  @selectedSeason="updateSelectedSeason"
                />
              </div>
              <div
                v-click-outside="closeTerritoriesBox"
                class="MapSelectorWrapper territories"
              >
                <div
                  class="MapSelectorSelectedOption"
                  @click="openOrCloseTerritoriesBox"
                >
                  <img class="MapSelectorIcon" src="/location.svg" />
                  <h5 class="fw-600 right-margin-12">
                    {{ selectedTerritory.area_name }}
                  </h5>
                  <img
                    class="MapSelectorChevron"
                    :src="
                      territoryIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'
                    "
                  />
                </div>
                <territories-selector
                  :select-is-open="territoryIsOpen"
                  :selected-territory="selectedTerritory"
                  @selectedTerritory="updateSelectedTerritory"
                />
              </div>
            </div>
          </div>
          <species-tab
            :tab-status="selectedTab.value === 'species' ? '' : 'hidden'"
            :species="species"
            :filtered-traits="filteredTraits"
            :filtered-further-info="filteredFurtherInfo"
          />
          <charts-tab-all-period
            :tab-status="
              selectedTab.value === 'charts' &&
              selectedSeason.value === 'all_period'
                ? ''
                : 'hidden'
            "
            :data-phenology-all-period="
              dataPhenologyAllPeriod[selectedTerritory.area_code]
            "
            :data-phenology-migration="
              dataPhenologyMigration[selectedTerritory.area_code]
            "
            :data-altitude="dataAltitudeAllPeriod[selectedTerritory.area_code]"
            :data-populations-test="
              dataPopulationsFake[selectedTerritory.area_code]
            "
          />
          <charts-tab-breeding
            :tab-status="
              selectedTab.value === 'charts' &&
              selectedSeason.value === 'breeding'
                ? ''
                : 'hidden'
            "
            :data-phenology-breeding="
              dataPhenologyBreeding[selectedTerritory.area_code]
            "
            :data-trend="dataTrendBreeding[selectedTerritory.area_code]"
            :data-populations-breeding="
              dataPopulationsBreeding[selectedTerritory.area_code]
            "
            :data-altitude="dataAltitudeBreeding[selectedTerritory.area_code]"
          />
          <charts-tab-wintering
            :tab-status="
              selectedTab.value === 'charts' &&
              selectedSeason.value === 'wintering'
                ? ''
                : 'hidden'
            "
            :data-trend="dataTrendWintering[selectedTerritory.area_code]"
            :data-populations-wintering="
              dataPopulationsWintering[selectedTerritory.area_code]
            "
            :data-altitude="dataAltitudeWintering[selectedTerritory.area_code]"
          />
          <maps-tab
            :tab-status="selectedTab.value === 'maps' ? '' : 'hidden'"
            :selected-territory="selectedTerritory"
          />
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
import SeasonsSelector from '~/components/prospecting/SeasonsSelector.vue'
import TerritoriesSelector from '~/components/prospecting/TerritoriesSelector.vue'
import SpeciesTab from '~/components/species-card/SpeciesTab.vue'
import ChartsTabAllPeriod from '~/components/species-card/ChartsTabAllPeriod.vue'
import ChartsTabBreeding from '~/components/species-card/ChartsTabBreeding.vue'
import ChartsTabWintering from '~/components/species-card/ChartsTabWintering.vue'
import MapsTab from '~/components/species-card/MapsTab.vue'
// UPDATE NEEDED : supprimer cet import
import {
  dataPhenologyAllPeriod,
  dataPhenologyMigration,
  dataPhenologyBreeding,
  dataAltitude,
  dataTrend,
  dataPopulationsBreeding,
  dataPopulationsWintering
  // dataPopulationsFake,
} from '~/test/fakeData'
// END UPDATE NEEDED

export default {
  components: {
    'seasons-selector': SeasonsSelector,
    'territories-selector': TerritoriesSelector,
    'species-tab': SpeciesTab,
    'charts-tab-all-period': ChartsTabAllPeriod,
    'charts-tab-breeding': ChartsTabBreeding,
    'charts-tab-wintering': ChartsTabWintering,
    'maps-tab': MapsTab
  },
  data: () => ({
    tabs: [
      {
        value: 'species',
        hash: '',
        label: 'Fiche espèce',
        subjects: [
          { label: 'Description', slug: 'description' },
          // { label: 'Taxonomie', slug: 'taxonomy' },
          { label: 'Statuts', slug: 'status' },
          { label: 'Caractéristiques', slug: 'traits' },
          // { label: 'Téléchargements', slug: 'downloads' },
          { label: 'Liens', slug: 'links' }
        ]
      },
      {
        value: 'charts',
        hash: '#charts',
        label: 'Diagrammes',
        subjects: {
          all_period: [
            { label: 'Phénologie', slug: 'phenology-all-period' },
            { label: 'Phénologie de migration', slug: 'phenology-migration' },
            { label: 'Répartition altitudinale', slug: 'altitude-all-period' }
          ],
          breeding: [
            { label: 'Phénologie', slug: 'phenology-breeding' },
            { label: "Tendance d'évolution", slug: 'trend-breeding' },
            {
              label: 'Taille de populations',
              slug: 'populations-sizes-breeding'
            },
            { label: 'Répartition altitudinale', slug: 'altitude-breeding' }
          ],
          wintering: [
            { label: "Tendance d'évolution", slug: 'trend-wintering' },
            {
              label: 'Taille de populations',
              slug: 'populations-sizes-wintering'
            },
            { label: 'Répartition altitudinale', slug: 'altitude-wintering' }
          ]
        }
      },
      {
        value: 'maps',
        hash: '#maps',
        label: 'Cartes',
        subjects: {
          atlas: [
            {
              label: '2019 - 2024',
              name: 'Oiseaux De France',
              slug: 'odf',
              seasons: ['all_period', 'breeding', 'wintering']
            },
            {
              label: '2009 - 2012',
              name: 'Atlas des Oiseaux de France Métropolitaine',
              slug: 'aofm',
              seasons: ['breeding', 'wintering']
            },
            {
              label: '1985 - 1989',
              name: 'Nouvel Atlas des Oiseaux Nicheurs de France',
              slug: 'naonf',
              seasons: ['breeding']
            },
            {
              label: '1977 - 1981',
              name: 'Atlas des Oiseaux de France en Hiver',
              slug: 'aofh',
              seasons: ['wintering']
            },
            {
              label: '1970 - 1975',
              name: 'Atlas des Oiseaux Nicheurs de France',
              slug: 'aonf',
              seasons: ['breeding']
            }
          ],
          others: [
            {
              label: 'Comparaison AOFM/ODF',
              name: 'Comparaison AOFM/ODF',
              slug: 'compare-aofm-odf',
              seasons: ['breeding', 'wintering']
            },
            {
              label: 'Densité',
              name: 'Densité',
              slug: 'density',
              seasons: ['breeding', 'wintering']
            },
            {
              label: 'Carte additionnelle',
              name: 'Carte additionnelle',
              slug: 'extra-map',
              seasons: ['breeding', 'wintering']
            }
          ]
        }
      }
    ],
    selectedTab: { value: '', hash: '', label: '', subjects: [] },
    selectedSubject: { label: '', slug: '' },
    detectMobile: false,
    atlasIsOpen: true,
    domCurrentScrollingItems: {},
    scrollListener: true,
    scrollDuration: 600,
    selectedSeason: {
      label: 'Toutes saisons',
      value: 'all_period'
    },
    selectedTerritory: {
      area_code: 'FRMET',
      area_name: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
      isActive: true
    },
    seasonIsOpen: false,
    territoryIsOpen: false,
    species: {
      attributes: {},
      medias: {},
      redLists: null,
      protectionStatus: null
    },
    traitsList: [
      { label: 'Groupe', key: 'trait_specie_group' },
      { label: 'Longueur', key: 'trait_length' },
      { label: 'Envergure', key: 'trait_scope' },
      { label: 'Poids', key: 'trait_weight' },
      { label: "Durée d'incubation", key: 'trait_incubation_time' },
      { label: 'Nombre de pontes', key: 'trait_clutches_number' },
      { label: "Nombre d'œufs", key: 'trait_eggs_number' },
      {
        label: "Durée de séjour au nid jusqu'à l'envol",
        key: 'trait_nest_length_stay'
      },
      { label: 'Âge maximal Euring', key: 'trait_max_age_euring' },
      { label: 'Âge maximal FR', key: 'trait_max_age_fr' },
      { label: 'Habitat', key: 'trait_habitat' },
      { label: 'Nourriture', key: 'trait_food' },
      { label: 'Site de nidification', key: 'trait_nesting_site' },
      { label: 'Comportement migrateur', key: 'trait_migratory_behaviour' }
    ],
    furtherInfoList: [
      { label: 'Répartition et déplacements', key: 'distribution' },
      { label: 'Habitats', key: 'habitat' },
      { label: 'Alimentation', key: 'feeding' },
      { label: 'Reproduction', key: 'breeding' }
    ],
    chartsDataAlreadyDownloaded: [],
    dataPhenologyAllPeriod: {},
    dataPhenologyMigration: {},
    dataAltitudeAllPeriod: {},
    dataPhenologyBreeding: {},
    dataTrendBreeding: {},
    dataPopulationsBreeding: {},
    dataAltitudeBreeding: {},
    dataTrendWintering: {},
    dataPopulationsWintering: {},
    dataAltitudeWintering: {},
    dataPopulationsFake: {}
  }),
  head() {
    return {
      title: this.species.attributes.odf_common_name_fr
    }
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
      }
    },
    filteredTabs() {
      // Si les données sont arrivées
      if (this.species.attributes.odf_common_name_fr) {
        // Deep copy
        const tabs = JSON.parse(JSON.stringify(this.tabs))
        // SpeciesTab
        const speciesTabSubjects = ['links']
        if (this.species.attributes.description || this.species.medias.Photos) {
          speciesTabSubjects.push('description')
        }
        if (this.species.redLists || this.species.protectionStatus) {
          speciesTabSubjects.push('status')
        }
        if (this.filteredTraits || this.filteredFurtherInfo) {
          speciesTabSubjects.push('traits')
        }
        tabs[0].subjects = this.tabs[0].subjects.filter((subject) => {
          return speciesTabSubjects.includes(subject.slug)
        })
        // ChartsTabs
        const chartsTabAllPeriodSubjects = []
        const chartsTabBreedingSubjects = []
        const chartsTabWinteringSubjects = []
        if (this.dataPhenologyAllPeriod[this.selectedTerritory.area_code]) {
          chartsTabAllPeriodSubjects.push('phenology-all-period')
        }
        if (this.dataPhenologyMigration[this.selectedTerritory.area_code]) {
          chartsTabAllPeriodSubjects.push('phenology-migration')
        }
        if (this.dataAltitudeAllPeriod[this.selectedTerritory.area_code]) {
          chartsTabAllPeriodSubjects.push('altitude-all-period')
        }
        if (this.dataPhenologyBreeding[this.selectedTerritory.area_code]) {
          chartsTabBreedingSubjects.push('phenology-breeding')
        }
        if (this.dataTrendBreeding[this.selectedTerritory.area_code]) {
          chartsTabBreedingSubjects.push('trend-breeding')
        }
        if (this.dataPopulationsBreeding[this.selectedTerritory.area_code]) {
          chartsTabBreedingSubjects.push('populations-sizes-breeding')
        }
        if (this.dataAltitudeBreeding[this.selectedTerritory.area_code]) {
          chartsTabBreedingSubjects.push('altitude-breeding')
        }
        if (this.dataTrendWintering[this.selectedTerritory.area_code]) {
          chartsTabWinteringSubjects.push('trend-wintering')
        }
        if (this.dataPopulationsWintering[this.selectedTerritory.area_code]) {
          chartsTabWinteringSubjects.push('populations-sizes-wintering')
        }
        if (this.dataAltitudeWintering[this.selectedTerritory.area_code]) {
          chartsTabWinteringSubjects.push('altitude-wintering')
        }
        tabs[1].subjects.all_period = this.tabs[1].subjects.all_period.filter(
          (subject) => {
            return chartsTabAllPeriodSubjects.includes(subject.slug)
          }
        )
        tabs[1].subjects.breeding = this.tabs[1].subjects.breeding.filter(
          (subject) => {
            return chartsTabBreedingSubjects.includes(subject.slug)
          }
        )
        tabs[1].subjects.wintering = this.tabs[1].subjects.wintering.filter(
          (subject) => {
            return chartsTabWinteringSubjects.includes(subject.slug)
          }
        )
        // End
        return tabs
      } else {
        return this.tabs
      }
    },
    subjectsList() {
      if (['species', 'charts'].includes(this.selectedTab.value)) {
        return (
          this.selectedTab.subjects[this.selectedSeason.value] ??
          this.selectedTab.subjects
        )
      } else {
        return []
      }
    },
    filteredTraits() {
      if (this.species.attributes.odf_common_name_fr) {
        // Si les données sont arrivées
        const filteredTraits = this.traitsList.filter((trait) => {
          return this.species.attributes[trait.key]
        })
        return filteredTraits.length > 0 ? filteredTraits : null
      } else {
        return null
      }
    },
    filteredFurtherInfo() {
      if (this.species.attributes.odf_common_name_fr) {
        // Si les données sont arrivées
        const filteredFurtherInfo = this.furtherInfoList.filter((info) => {
          return this.species.attributes[info.key]
        })
        return filteredFurtherInfo.length > 0 ? filteredFurtherInfo : null
      } else {
        return null
      }
    }
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.defineSelectedTab()
      this.$refs.scrollingContainer.scrollTop = 0
    },
    filteredTabs(newVal) {
      // Change si le territoire sélectionné change
      // console.log('filteredTabs')
      // console.log(newVal)
      if (this.selectedTab.value !== 'maps') {
        // Mettre à jour le menu de gauche
        this.defineSelectedTab()
      }
    }
  },
  beforeMount() {
    window.addEventListener('resize', this.listenerResize)
    if (this.$detectMobile()) {
      this.detectMobile = true
      // First we get the viewport height and we multiple it by 1% to get a value for a vh unit
      const vh = window.innerHeight * 0.01
      // Then we set the value in the --vh custom property to the root of the document
      document.documentElement.style.setProperty('--vh', `${vh}px`)
    }
  },
  mounted() {
    document.documentElement.style.overflow = 'hidden'
    document.body.style.position = 'fixed' // Needed for iOS
    this.$refs.scrollingContainer.addEventListener(
      'scroll',
      this.listenerScroll
    )
    // this.defineSelectedTab()
    this.$axios
      .$get(
        `https://geonature.alx.host/taxhub/api/bibnoms/taxoninfo/${this.cdnom}`
      )
      .then((data) => {
        if (data) {
          const species = {
            cdnom: this.cdnom,
            attributes: {},
            medias: { Photos: [] }
          }
          data.attributs.forEach((attribut) => {
            species.attributes[attribut.nom_attribut] = attribut.valeur_attribut
          })
          data.medias.forEach((media) => {
            if (media.nom_type_media === 'Photo') {
              species.medias.Photos.push({
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media
              })
            } else if (media.nom_type_media === 'Photo_principale') {
              species.medias.Photos.splice(0, 0, {
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media
              })
              species.medias[media.nom_type_media] = {
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media
              }
            } else {
              species.medias[media.nom_type_media] = {
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media
              }
            }
          })
          if (!species.medias.Photos.length) {
            delete species.medias.Photos
          }
          this.$axios
            .$get(
              `https://demo.geonature.fr/taxhub/api/bdc_statuts/list/${this.cdnom}`
            )
            .then((data) => {
              if (data) {
                // UPDATE NEEDED : récupérer les noms des territoires pour les LR (et pas seulement leur cd_sig)
                const redListWorld = data.filter((item) => {
                  return item.cd_type_statut === 'LRM'
                })
                const redListsNational = data.filter((item) => {
                  return item.cd_type_statut === 'LRN'
                })
                if (redListWorld.length || redListsNational.length) {
                  species.redLists = { national: [] }
                  if (redListWorld.length) {
                    species.redLists.world = redListWorld[0].code_statut
                  }
                  if (redListsNational.length) {
                    redListsNational.forEach((item) => {
                      species.redLists.national.push({
                        territory: item.cd_sig,
                        statut: item.code_statut
                      })
                    })
                  }
                }
                // END UPDATE NEEDED
                // UPDATE NEEDED : récupérer les statuts de protection
                species.protectionStatus = {}
                species.protectionStatus.national = 'Chassable'
                species.protectionStatus.birdDirective = 'Protégée'
                // END UPDATE NEEDED
                this.species = species
                // console.log(species)
              }
            })
            .catch((error) => {
              console.log(error)
            })
        }
      })
      .catch((error) => {
        console.log(error)
      })
      .finally(() => {
        setTimeout(() => {
          // Le timeout permet d'être assuré que les contenus sont bien integrés à la page
          this.defineDomCurrentScrollingItems() // Certaines sections ne sont affichées qu'une fois les données récupérées
          const scrollingContainerHeight =
            this.$refs.scrollingContainer.offsetHeight
          document.documentElement.style.setProperty(
            '--scrolling-container-height',
            `${scrollingContainerHeight}px`
          )
        }, 1000)
      })
    // UPDATE NEEDED : récupérer les données des graphes via axios + API (selon le territoire sélectionné)
    this.dataPhenologyAllPeriod[this.selectedTerritory.area_code] =
      dataPhenologyAllPeriod
    this.dataPhenologyMigration[this.selectedTerritory.area_code] =
      dataPhenologyMigration
    this.dataAltitudeAllPeriod[this.selectedTerritory.area_code] = dataAltitude
    this.dataPhenologyBreeding[this.selectedTerritory.area_code] =
      dataPhenologyBreeding
    this.dataTrendBreeding[this.selectedTerritory.area_code] = dataTrend
    this.dataPopulationsBreeding[this.selectedTerritory.area_code] =
      dataPopulationsBreeding
    this.dataAltitudeBreeding[this.selectedTerritory.area_code] = dataAltitude
    this.dataTrendWintering[this.selectedTerritory.area_code] = dataTrend
    this.dataPopulationsWintering[this.selectedTerritory.area_code] =
      dataPopulationsWintering
    this.dataAltitudeWintering[this.selectedTerritory.area_code] = dataAltitude
    // this.dataPopulationsFake = dataPopulationsFake
    this.chartsDataAlreadyDownloaded.push(this.selectedTerritory.area_code)
    // END UPDATE NEEDED
  },
  beforeDestroy() {
    document.documentElement.style.removeProperty('overflow')
    document.body.style.removeProperty('position')
    window.removeEventListener('resize', this.listenerResize)
    this.$refs.scrollingContainer.removeEventListener(
      'scroll',
      this.listenerScroll
    )
  },
  methods: {
    defineSelectedTab() {
      this.selectedTab = this.filteredTabs.filter((item) => {
        return item.hash === this.$route.hash
      })[0]
      this.defineSelectedSubject()
      setTimeout(() => {
        // Le timeout permet d'être assuré que les contenus sont bien integrés à la page
        this.defineDomCurrentScrollingItems()
      }, 500)
    },
    defineSelectedSubject() {
      if (
        ['species', 'charts'].includes(this.selectedTab.value) &&
        this.subjectsList.length
      ) {
        this.selectedSubject = this.subjectsList[0]
      } else {
        this.selectedSubject = this.tabs[2].subjects.atlas[0]
      }
    },
    defineDomCurrentScrollingItems() {
      this.domCurrentScrollingItems = this.subjectsList.map((item) => {
        return document.getElementById(item.slug)
      })
    },
    updateSelectedTab(item) {
      this.$router.push(`${item.hash}`)
    },
    updateSelectedSubject(item) {
      if (document.getElementById(item.slug) && this.selectedSubject !== item) {
        this.scrollListener = false
        this.selectedSubject = item
        this.$animateScrollTo(
          this.$refs.scrollingContainer,
          document.getElementById(item.slug).offsetTop,
          12,
          this.scrollDuration
        )
        setTimeout(() => {
          this.scrollListener = true
        }, this.scrollDuration + 10)
      }
      if (this.selectedTab.value === 'maps') {
        this.selectedSubject = item
      }
    },
    updateAtlasStatus() {
      this.atlasIsOpen = !this.atlasIsOpen
    },
    updateSelectedSeason(season) {
      this.selectedSeason = season
      this.seasonIsOpen = false
      if (this.selectedTab.value !== 'maps') {
        this.defineSelectedSubject()
        this.defineDomCurrentScrollingItems()
      }
    },
    updateSelectedTerritory(territory) {
      this.selectedTerritory = territory
      this.territoryIsOpen = false
      // UPDATE NEEDED : mettre à jour les données des graphes lorsqu'on sélectionne un "nouveau territoire"
      if (!this.chartsDataAlreadyDownloaded.includes(territory.area_code)) {
        console.log(
          'Il faut télécharger les données de ce nouveau territoire !'
        )
      }
      // END UPDATE NEEDED
    },
    openOrCloseSeasonsBox() {
      this.seasonIsOpen = !this.seasonIsOpen
    },
    openOrCloseTerritoriesBox() {
      this.territoryIsOpen = !this.territoryIsOpen
    },
    closeSeasonsBox() {
      this.seasonIsOpen = false
    },
    closeTerritoriesBox() {
      this.territoryIsOpen = false
    },
    listenerScroll() {
      this.$debounce(this.handleScroll())
    },
    handleScroll() {
      if (
        this.scrollListener &&
        ['species', 'charts'].includes(this.selectedTab.value)
      ) {
        // console.log(this.domCurrentScrollingItems)
        const currentScroll = this.$refs.scrollingContainer.scrollTop
        const domCurrentScrolledItem = this.domCurrentScrollingItems.filter(
          (item) => {
            return (
              item.offsetTop - 40 <= currentScroll &&
              item.offsetTop + item.offsetHeight > currentScroll
            )
          }
        )
        if (domCurrentScrolledItem.length > 0) {
          const currentScrolledSubject = this.subjectsList.filter((subject) => {
            return subject.slug === domCurrentScrolledItem[0].id
          })[0]
          if (currentScrolledSubject) {
            this.selectedSubject = currentScrolledSubject
          }
        }
      }
    },
    listenerResize() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      const scrollingContainerHeight =
        this.$refs.scrollingContainer.offsetHeight
      document.documentElement.style.setProperty(
        '--scrolling-container-height',
        `${scrollingContainerHeight}px`
      )
      if (this.detectMobile) {
        const vh = window.innerHeight * 0.01
        document.documentElement.style.setProperty('--vh', `${vh}px`)
      }
    }
  }
}
</script>

<style scoped>
div.container.container--fluid {
  height: 100vh;
  height: calc(var(--vh, 1vh) * 100);
  max-height: 100vh;
  max-height: calc(var(--vh, 1vh) * 100);
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

.SeeMoreWrapper {
  margin: 0 0 18px 24px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SeeMoreChevron {
  width: 11px;
}

.SpeciesCardTab {
  position: absolute;
  top: 0;
  left: 300px;
  right: 0;
  bottom: 0;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.SpeciesCardTabRelative {
  position: relative;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.MapSelectors {
  padding: 24px 40px;
  justify-content: flex-start;
  align-items: center;
  column-gap: 40px;
  row-gap: 16px;
  flex-wrap: wrap;
}

.MapSelectors.map {
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
}

.MapTitle {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.MapSelectorsWrapper {
  flex: 1 1 414px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.SpeciesCardTabRelative >>> .MapSelectorBox {
  max-height: 70vh - 110px;
  max-height: calc(var(--scrolling-container-height, 70vh) - 122px);
}

.SpeciesCardContent {
  width: 100%;
  padding: 24px 40px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.SpeciesCardContent.map {
  padding: 0 !important;
  flex-direction: row;
}

.SpeciesCardContent.hidden {
  position: absolute !important;
  top: -9999px !important;
  left: -9999px !important;
}

.SpeciesCardTabRelative >>> .ChartCard {
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

.SpeciesCardTabRelative >>> .ChartCard:last-child {
  margin-bottom: 0;
}

.SpeciesCardTabRelative >>> .Chart {
  height: 300px;
  overflow-y: hidden;
  overflow-x: auto;
  touch-action: auto;
  -webkit-overflow-scrolling: touch; /* iOS */
}

.SpeciesCardTabRelative >>> .ChartLegend {
  margin-top: 40px;
  display: flex;
  justify-content: center;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel {
  margin-right: 20px;
  display: flex;
  align-items: center;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel:last-child {
  margin-right: 0;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel i {
  width: 16px;
  min-width: 16px;
  height: 16px;
  min-height: 16px;
  float: left;
  margin-right: 12px;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel i.round {
  border-radius: 50%;
}

.SpeciesCardTabRelative >>> .UnavailableData {
  margin: auto;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 1050px) {
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

  .SpeciesCardContent,
  .MapSelectors {
    padding: 24px 5%;
  }
}

@media screen and (max-width: 680px) {
  .SpeciesCardContent >>> h4.fw-bold {
    font-size: 16px;
    line-height: 24px;
  }

  .ChartCard {
    padding: 24px;
  }
}

@media screen and (max-width: 552px) {
  .SpeciesCardTabRelative >>> .MapSelectorsWrapper {
    flex-direction: column;
  }

  .SpeciesCardTabRelative >>> .MapSelectorWrapper {
    width: 100%;
    height: 42px;
    margin-right: 0;
    margin-bottom: 8px;
  }

  .SpeciesCardTabRelative >>> .MapSelectorWrapper:last-child {
    margin-bottom: 0;
  }

  .SpeciesCardTabRelative >>> .MapSelectorSelectedOption {
    width: 100%;
    height: 42px;
    padding: 0 12px;
    border: 2px solid rgba(38, 38, 38, 0.8);
    box-sizing: border-box;
    border-radius: 8px;
  }

  .SpeciesCardTabRelative >>> .MapSelectorBox {
    width: 100%;
    top: 47px;
  }

  .MapSelectorWrapper.seasons >>> .MapSelectorBox {
    max-height: calc(70vh - 139px);
    max-height: calc(var(--scrolling-container-height, 70vh) - 139px);
  }

  .MapSelectorWrapper.territories >>> .MapSelectorBox {
    max-height: calc(70vh - 189px);
    max-height: calc(var(--scrolling-container-height, 70vh) - 189px);
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
