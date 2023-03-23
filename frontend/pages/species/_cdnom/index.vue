<template>
  <v-container fluid>
    <species-layout-nav-bar :species="species" />
    <section class="SpeciesCardSection">
      <species-layout-side-bar />
      <div ref="scrollingContainer" class="SpeciesCardTab">
        <div class="SpeciesCardTabRelative">
          <species-layout-selectors-bar
            v-if="['charts', 'maps'].includes(selectedTab.value)"
          />
          <species-monography-tab
            v-if="selectedTab.value === 'monography'"
            :species="species"
          />
          <species-charts-tab v-if="selectedTab.value === 'charts'" />
          <species-maps-tab v-if="selectedTab.value === 'maps'" />
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
// UPDATE NEEDED : supprimer cet import
// import {
//   // dataAltitude,
//   dataTrend,
//   dataPopulationsBreeding,
//   dataPopulationsWintering,
//   dataPhenologyMigration,
//   // dataPopulationsFake,
// } from '~/test/fakeData'
// END UPDATE NEEDED

export default {
  data: () => ({
    selectedSubject: { label: '', slug: '' },
    detectMobile: false,
    domCurrentScrollingItems: {},
    scrollListener: true,
    scrollDuration: 600,
    selectedSeason: {
      label: 'Toutes saisons',
      value: 'all_period',
    },
    selectedTerritory: {
      area_code: 'FRMET',
      area_name: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
      isActive: true,
    },
    seasonIsOpen: false,
    territoryIsOpen: false,
    species: {
      attributes: {},
      medias: {},
      redLists: null,
      protectionStatus: null,
    },
    chartsDataAlreadyDownloaded: [],
    dataPhenologyAllPeriod: null,
    dataPhenologyMigration: {},
    dataAltitudeAllPeriod: {},
    dataPhenologyBreeding: null,
    dataTrendBreeding: {},
    dataPopulationsBreeding: {},
    dataAltitudeBreeding: {},
    dataTrendWintering: {},
    dataPopulationsWintering: {},
    dataAltitudeWintering: {},
    dataPopulationsFake: {},
    dataAltitude: null,
    historicAtlasMaps: [],
    // dataAltitude: {
    //   altitude: {
    //     label: 'Répartition des observations',
    //     color: '#435EF2',
    //     data: []
    //   },
    //   globalAltitude: {
    //     label: "Répartition de l'altitude du territoire",
    //     data: [
    //       { label: 0, percentage: 60 },
    //       { label: 100, percentage: 30 },
    //       { label: 500, percentage: 45 },
    //       { label: 600, percentage: 15 },
    //       { label: 1700, percentage: 5 },
    //       { label: 3500, percentage: 0 }
    //     ],
    //     color: 'rgba(67, 94, 242, 0.1)'
    //   }
    // },
    id_area: null,
  }),
  head() {
    return {
      title: this.species.attributes.odf_common_name_fr,
    }
  },
  computed: {
    cdNom() {
      const cdNom = this.$route.params.cdnom
      this.$store.commit('species/setCdNom', cdNom)
      return cdNom
    },
    selectedTab() {
      return this.$store.state.species.selectedTab
    },
    subjectsList() {
      return this.$store.state.species.subjectsList
    },
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.defineSelectedTab()
      this.$refs.scrollingContainer.scrollTop = 0
    },
    // filteredTabs(newVal) {
    //   // Change si le territoire sélectionné change
    //   if (this.selectedTab.value !== 'maps') {
    //     // Mettre à jour le menu de gauche
    //     this.defineSelectedTab()
    //   }
    // },
    // selectedTab: {
    //   handler(newVal, oldVal) {
    //     if (newVal.value !== oldVal.value) {
    //       this.$store.commit('species/setSelectedTab', newVal.value)
    //     }
    //   },
    //   deep: true,
    // },
  },
  beforeMount() {
    // this.getIdArea()
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
    // this.loadChartsData()
    // this.loadHistoricAtlasList()
    document.documentElement.style.overflow = 'hidden'
    document.body.style.position = 'fixed' // Needed for iOS
    this.$refs.scrollingContainer.addEventListener(
      'scroll',
      this.listenerScroll
    )
    // this.defineSelectedTab()
    this.getSpecieData()
    // UPDATE NEEDED : récupérer les données des graphes via axios + API (selon le territoire sélectionné)
    // this.dataPhenologyMigration[this.selectedTerritory.area_code] =
    //   dataPhenologyMigration
    // this.dataTrendBreeding[this.selectedTerritory.area_code] = dataTrend
    // this.dataPopulationsBreeding[this.selectedTerritory.area_code] =
    //   dataPopulationsBreeding
    // this.dataTrendWintering[this.selectedTerritory.area_code] = dataTrend
    // this.dataPopulationsWintering[this.selectedTerritory.area_code] =
    //   dataPopulationsWintering
    // this.chartsDataAlreadyDownloaded.push(this.selectedTerritory.area_code)
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
    async getSpecieData() {
      await this.$axios
        .$get(`/taxhub/api/bibnoms/taxoninfo/${this.cdNom}`, {
          headers: {
            'Access-Control-Allow-Origin': 'localhost:3000',
            'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE,PATCH,OPTIONS',
            'Access-Control-Allow-Credentials': true,
          },
        })
        .then((data) => {
          if (data) {
            const species = {
              cdnom: this.cdNom,
              attributes: {},
              medias: { Photos: [] },
            }
            data.attributs.forEach((attribut) => {
              species.attributes[attribut.nom_attribut] =
                attribut.valeur_attribut
            })
            data.medias.forEach((media) => {
              if (media.nom_type_media === 'Photo') {
                species.medias.Photos.push({
                  title: media.titre,
                  url: media.url,
                  author: media.auteur,
                  description: media.desc_media,
                })
              } else if (media.nom_type_media === 'Photo_principale') {
                species.medias.Photos.splice(0, 0, {
                  title: media.titre,
                  url: media.url,
                  author: media.auteur,
                  description: media.desc_media,
                })
                species.medias[media.nom_type_media] = {
                  title: media.titre,
                  url: media.url,
                  author: media.auteur,
                  description: media.desc_media,
                }
              } else {
                species.medias[media.nom_type_media] = {
                  title: media.titre,
                  url: media.url,
                  author: media.auteur,
                  description: media.desc_media,
                }
              }
            })
            if (!species.medias.Photos.length) {
              delete species.medias.Photos
            }
            this.$axios
              .$get(
                `https://geonature.lpo-aura.org/taxhub/api/bdc_statuts/list/${this.cdNom}`
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
                          statut: item.code_statut,
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
                  // console.debug(species)
                }
              })
              .catch((error) => {
                console.error(error)
              })
          }
        })
        .catch((error) => {
          console.error(error)
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
    },
    defineSelectedTab() {
      this.defineSelectedSubject()
      setTimeout(() => {
        // Le timeout permet d'être assuré que les contenus sont bien integrés à la page
        this.defineDomCurrentScrollingItems()
      }, 500)
    },
    defineSelectedSubject() {
      this.$store.commit('species/setSelectedSubject', this.subjectsList[0])
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
        console.debug(
          'Il faut télécharger les données de ce nouveau territoire !'
        )
      }
      // END UPDATE NEEDED
    },
    // openOrCloseSeasonsBox() {
    //   this.seasonIsOpen = !this.seasonIsOpen
    // },
    // openOrCloseTerritoriesBox() {
    //   this.territoryIsOpen = !this.territoryIsOpen
    // },
    // closeSeasonsBox() {
    //   this.seasonIsOpen = false
    // },
    // closeTerritoriesBox() {
    //   this.territoryIsOpen = false
    // },
    listenerScroll() {
      this.$debounce(this.handleScroll())
    },
    handleScroll() {
      if (
        this.scrollListener &&
        ['monography', 'charts'].includes(this.selectedTab.value)
      ) {
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
    },
  },
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
