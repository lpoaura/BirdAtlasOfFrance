<template>
  <div class="SpeciesCardContent">
    <div id="description" class="Row" :style="{ height: readMore || !medias?.Photos ? 'auto' : '367px' }">
      <div class="Column read-more-wrapper">
        <div class="read-more">
          <h4 class="black02 fw-bold bottom-margin-16">Description</h4>
          <v-skeleton-loader v-if="Object.keys(attributes).length === 0" type="paragraph"></v-skeleton-loader>
          <span v-if="Object.keys(attributes).length > 0" ref="description" class="black02" v-html="attributes?.description
            ? attributes.description
            : 'Pas de description disponible actuellement pour cette espèce.'
            ">
          </span>
          <div v-if="descriptionHeight > 37 && !readMore" class="Blurring"></div>
        </div>
        <div v-if="descriptionHeight > 37" class="display-flex">
          <span class="green01 fw-600 pointer ReadMore" @click="readMore = !readMore">
            {{ readMore ? 'Lire moins' : 'Lire plus' }}
          </span>
        </div>
        <div v-if="descriptionHeight > 327 && readMore" class="display-flex">
          <span class="green01 fw-600 pointer ReadMore" @click="readMore = !readMore">
            Lire moins
          </span>
        </div>
      </div>
      <species-monography-pictures-carousel v-if="medias?.Photos" :pictures="medias.Photos" />
    </div>

    <div v-if="filteredTraits || filteredFurtherInfo" id="traits" class="Column">
      <div v-if="filteredTraits" class="Column">
        <h4 class="black02 fw-bold bottom-margin-16">Caractéristiques</h4>
        <div class="TraitsCardsGrid">
          <div v-for="(trait, index) in filteredTraits" :key="index" class="TraitCard">
            <span class="black02 fw-600 bottom-margin-8">
              {{ trait.label }}
            </span>
            <span class="black02">
              {{ attributes[trait.key] }}
            </span>
          </div>
        </div>
      </div>
      <div v-if="filteredFurtherInfo" class="FurtherInfoGrid">
        <div v-for="(info, index) in filteredFurtherInfo" :key="index" class="Column">
          <h4 class="black02 fw-bold bottom-margin-16">
            {{ info.label }}
          </h4>
          <span class="black02">
            {{ attributes[info.key] }}
          </span>
        </div>
      </div>
    </div>
    <div v-if="redLists.length || species.protectionStatus" id="status" class="Column">
      <div class="StatusGrid">
        <div v-if="redLists.length" class="Column">
          <h4 class="black02 fw-bold bottom-margin-16">
            Statuts de conservation
          </h4>
          <div class="StatusWrapper">
            <span class="black02 fw-bold bottom-margin-8">Listes rouges</span>
            <li v-for="(item, index) in redLists" :key="index" class="StatusOption bottom-margin-8">
              <v-tooltip bottom>
                <template #activator="{ on, attrs }">
                  <span v-bind="attrs" class="black02 flex-1 right-margin-8" v-on="on">
                    {{ item.locationName }} (<span class="text--disabled">{{
                      item.statusTypeName
                    }}</span><span v-if="item.statusRemarks">
                      - {{ item.statusRemarks }}</span>)
                  </span>
                </template>
                <span class="text-white" v-html="item.source"></span>
              </v-tooltip>

              <div v-if="item.statusCode" class="black02 float-right">
                <v-tooltip bottom>
                  <template #activator="{ on, attrs }">
                    <div v-bind="attrs" class="RedListSticker" :style="{
                      background: $redLists(item.statusCode).bgColor,
                    }" v-on="on">
                      <h5 class="fw-600" :style="{ color: $redLists(item.statusCode).fontColor }">
                        {{ item.statusCode }}
                      </h5>
                    </div>
                  </template>
                  <span class="text-white">{{ item.statusName }}</span>
                </v-tooltip>
              </div>
            </li>
          </div>
        </div>
        <div v-if="regulatories.length || europeenDirectives.length" class="Column">
          <h4 class="black02 fw-bold bottom-margin-16">
            Statuts réglementaires
          </h4>
          <div v-if="regulatories.length" id="Regulatory" class="StatusWrapper">
            <p v-for="(regulatory, index) in regulatories" :key="index" class="black02">
              <span class="fw-bold">
                {{ regulatory.statusTypeName }} ({{
                  regulatory.locationName
                }}) </span><br />
              {{ regulatory.statusName }}
            </p>
          </div>
          <div v-if="europeenDirectives.length" class="StatusWrapper">
            <p v-for="(directive, index) in europeenDirectives" :key="index" class="black02">
              <span class="fw-bold">{{ directive.statusTypeName }} ({{
                directive.locationName
              }})</span><br />
              {{ directive.statusName }}
            </p>
          </div>
        </div>
      </div>
    </div>
    <div id="links" class="Column">
      <h4 class="black02 fw-bold bottom-margin-16">Liens</h4>
      <div class="LinksWrapper">
        <div class="LinksGrid">
          <li class="LinkOption">
            <img src="/eye-green.svg" class="LinkOptionIcon" />
            <span class="fw-500">
              <a :href="`https://inpn.mnhn.fr/espece/cd_nom/${species.id}`" target="_blank">
                Visualiser la fiche INPN de l'espèce
              </a>
            </span>
          </li>
          <li class="LinkOption">
            <img src="/pencil-green.svg" class="LinkOptionIcon" />
            <span class="fw-500">
              <a href="https://www.faune-france.org/" target="_blank">
                Saisir mes données sur Faune France
              </a>
            </span>
          </li>
          <li v-for="(link, index) in filteredLinks" :key="index" class="LinkOption">
            <img :src="link.icon" class="LinkOptionIcon" />
            <span class="fw-500">
              <a :href="medias[link.key].url" target="_blank">
                {{ link.label }}
              </a>
            </span>
          </li>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    species: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    status: [],
    locationNameList: ['Monde', 'Europe'],
    adminLevelOrderedList: ['État', 'Territoire'],
    descriptionHeight: 0,
    subjectsList: [
      { label: 'Caractéristiques', slug: 'traits', position: 3 },
      // { label: 'Téléchargements', slug: 'downloads' },
      { label: 'Liens', slug: 'links', position: 4 },
    ],
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
        key: 'trait_nest_length_stay',
      },
      { label: 'Âge maximal Euring', key: 'trait_max_age_euring' },
      { label: 'Âge maximal FR', key: 'trait_max_age_fr' },
      { label: 'Habitat', key: 'trait_habitat' },
      { label: 'Nourriture', key: 'trait_food' },
      { label: 'Site de nidification', key: 'trait_nesting_site' },
      { label: 'Comportement migrateur', key: 'trait_migratory_behaviour' },
    ],
    furtherInfoList: [
      { label: 'Répartition et déplacements', key: 'distribution' },
      { label: 'Habitats', key: 'habitat' },
      { label: 'Alimentation', key: 'feeding' },
      { label: 'Reproduction', key: 'breeding' },
      { label: 'Taille de population', key: 'pop_size' },
    ],
    readMore: false,
    linksList: [
      {
        label: 'Écouter le chant sur Xeno-Canto',
        key: 'xeno-canto',
        icon: '/song-green.svg',
      },
      {
        label: "Visualiser l'espèce sur EuroBirdPortal",
        key: 'euro-bird-portal',
        icon: '/eye-green.svg',
      },
    ],
  }),
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
    redLists() {

      return this.status
        .filter(
          (i) => i.statusTypeGroup === 'Liste rouge' &&
            (this.locationNameList.includes(i.locationName) || this.adminLevelOrderedList.includes(i.locationAdminLevel)) &&
            !(i.locationName === 'France métropolitaine' && i.source.includes('2011'))
        )
        .sort(
          (a, b) =>
            this.adminLevelOrderedList.indexOf(a.locationAdminLevel) -
            this.adminLevelOrderedList.indexOf(b.locationAdminLevel)
        )
        .sort((a, b) =>
          this.locationNameList.indexOf(b.locationName) - this.locationNameList.indexOf(a.locationName)
        )
    },
    regulatories() {
      return this.status
        .filter(
          (i) =>
            i.statusTypeGroup === 'Réglementation' ||
            i.statusTypeGroup === 'Protection'
        )
        .sort((a, b) => b.locationAdminLevel > a.locationAdminLevel)
    },
    europeenDirectives() {
      return this.status.filter(
        (i) => i.statusTypeGroup === 'Directives européennes'
      )
    },
    filteredLinks() {
      if (this.attributes.odf_common_name_fr) {
        // Si les données sont arrivées
        return this.linksList.filter((link) => {
          return this.medias[link.key]
        })
      } else {
        return []
      }
    },
    filteredTraits() {
      if (this.attributes?.odf_common_name_fr) {
        // Si les données sont arrivées
        const filteredTraits = this.traitsList.filter((trait) => {
          return this.attributes[trait.key]
        })
        return filteredTraits.length > 0 ? filteredTraits : null
      } else {
        return null
      }
    },
    filteredFurtherInfo() {
      if (this.attributes?.odf_common_name_fr) {
        // Si les données sont arrivées
        const filteredFurtherInfo = this.furtherInfoList.filter((info) => {
          return this.attributes[info.key]
        })
        return filteredFurtherInfo.length > 0 ? filteredFurtherInfo : null
      } else {
        return null
      }
    },
  },
  watch: {
    cdNom() {
      this.getStatus()
    },
    species() {
      this.initSubjectList()
      setTimeout(() => {
        // Le timeout permet d'être assuré que le texte est bien integré à l'élément
        if (this.$refs.description) {
          this.descriptionHeight = this.$refs.description.offsetHeight
        }
      }, 100)
    },
    status() {
      if (
        this.status.filter((i) =>
          ['Liste rouge', 'Réglementation', 'Directives européennes'].includes(
            i.statusTypeGroup
          )
        )
      ) {
        this.$store.commit('species/pushSubjectsList', {
          label: 'Statuts',
          slug: 'status',
          position: 2,
        })
      }
    },
  },
  beforeMount() {
    window.addEventListener('resize', this.listener)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.listener)
  },
  mounted() {
    this.initSubjectList()
  },
  methods: {
    async getStatus() {
      await this.$axios
        .$get(`https://taxref.mnhn.fr/api/taxa/${this.cdNom}/status/lines`)
        .then((data) => {
          this.status = data._embedded.status
        })
    },
    initStore() { },
    initSubjectList() {
      this.$store.commit('species/setSubjectsList', [])
      this.$store.commit('species/pushSubjectsList', {
        label: 'Description',
        slug: 'description',
        position: 1,
      })

      if (
        this.filteredTraits?.length > 0 ||
        this.filteredFurtherInfo?.length > 0
      ) {
        this.$store.commit('species/pushSubjectsList', {
          label: 'Caractéristiques',
          slug: 'traits',
          position: 3,
        })
      }
      this.$store.commit('species/pushSubjectsList', {
        label: 'Liens',
        slug: 'links',
        position: 4,
      })
    },
    listener() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      if (this.$refs.description) {
        this.descriptionHeight = this.$refs.description.offsetHeight
      }
    },
    // filteredTabs() {
    //   // Si les données sont arrivées
    //   if (this.attributes?.odf_common_name_fr) {
    //     // Deep copy
    //     const tabs = JSON.parse(JSON.stringify(this.tabs))
    //     // SpeciesTab
    //     const speciesTabSubjects = ['links']
    //     // if (this.attributes.description || this.medias.Photos) {
    //     //   speciesTabSubjects.push('description')
    //     // }
    //     if (this.species.redLists || this.species.protectionStatus) {
    //       speciesTabSubjects.push('status')
    //     }
    //     tabs[0].subjects = this.tabs[0].subjects.filter((subject) => {
    //       return speciesTabSubjects.includes(subject.slug)
    //     })
    //     // ChartsTabs
    //     const chartsTabAllPeriodSubjects = []
    //     const chartsTabBreedingSubjects = []
    //     const chartsTabWinteringSubjects = []
    //     if (this.dataPhenologyAllPeriod) {
    //       chartsTabAllPeriodSubjects.push('phenology-all-period')
    //     }
    //     if (this.dataPhenologyMigration[this.selectedTerritory.area_code]) {
    //       chartsTabAllPeriodSubjects.push('phenology-migration')
    //     }
    //     if (this.dataAltitudeAllPeriod[this.selectedTerritory.area_code]) {
    //       chartsTabAllPeriodSubjects.push('altitude-all-period')
    //     }
    //     if (this.dataPhenologyBreeding) {
    //       chartsTabBreedingSubjects.push('phenology-breeding')
    //     }
    //     if (this.dataTrendBreeding[this.selectedTerritory.area_code]) {
    //       chartsTabBreedingSubjects.push('trend-breeding')
    //     }
    //     if (this.dataPopulationsBreeding[this.selectedTerritory.area_code]) {
    //       chartsTabBreedingSubjects.push('populations-sizes-breeding')
    //     }
    //     if (this.dataAltitudeBreeding[this.selectedTerritory.area_code]) {
    //       chartsTabBreedingSubjects.push('altitude-breeding')
    //     }
    //     if (this.dataTrendWintering[this.selectedTerritory.area_code]) {
    //       chartsTabWinteringSubjects.push('trend-wintering')
    //     }
    //     if (this.dataPopulationsWintering[this.selectedTerritory.area_code]) {
    //       chartsTabWinteringSubjects.push('populations-sizes-wintering')
    //     }
    //     if (this.dataAltitudeWintering[this.selectedTerritory.area_code]) {
    //       chartsTabWinteringSubjects.push('altitude-wintering')
    //     }
    //     tabs[1].subjects.all_period = this.tabs[1].subjects.all_period.filter(
    //       (subject) => {
    //         return chartsTabAllPeriodSubjects.includes(subject.slug)
    //       }
    //     )
    //     tabs[1].subjects.breeding = this.tabs[1].subjects.breeding.filter(
    //       (subject) => {
    //         return chartsTabBreedingSubjects.includes(subject.slug)
    //       }
    //     )
    //     tabs[1].subjects.wintering = this.tabs[1].subjects.wintering.filter(
    //       (subject) => {
    //         return chartsTabWinteringSubjects.includes(subject.slug)
    //       }
    //     )
    //     // End
    //     return tabs
    //   } else {
    //     return this.tabs
    //   }
    // },
  },
}
</script>

<style scoped>
.Row {
  margin-top: 40px;
  display: flex;
}

.Row:first-child {
  margin-top: 0;
}

.Column {
  display: flex;
  flex-direction: column;
}

.Row>.Column {
  flex: 1;
  margin-right: 24px;
}

.SpeciesCardContent>.Column {
  margin-top: 40px;
}

.Row>.Column:last-child {
  margin-right: 0;
}

.SpeciesCardContent>.Column:first-child {
  margin-top: 0;
}

.read-more-wrapper {
  justify-content: space-between;
}

.read-more {
  position: relative;
  flex: 1;
  overflow-y: hidden;
  margin-bottom: 8px;
  display: flex;
  flex-direction: column;
}

.Blurring {
  background: linear-gradient(0deg,
      rgba(252, 252, 252, 1) 0%,
      rgba(252, 252, 252, 0) 100%);
  position: absolute;
  z-index: 1;
  left: 0;
  bottom: 0;
  width: 100%;
  height: 50px;
}

.StatusGrid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(max(288px, 45%), 2fr));
  grid-gap: 40px;
}

.StatusWrapper,
.LinksWrapper {
  padding: 24px 32px;
  margin-bottom: 16px;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
}

.StatusWrapper:last-child,
.LinksWrapper:last-child {
  margin-bottom: 0;
}

/* .StatusOption{
  margin-bottom: 16px;
} */

.StatusOption,
.LinkOption {
  list-style: none;
  display: flex;
  align-items: center;
}

.StatusOption:last-child {
  margin-bottom: 0 !important;
}

.StatusValue {
  flex: 0.7;
  display: flex;
  align-items: center;
}

.v-tooltip__content {
  background-color: white;
  border: 1px solid;
  border-radius: 8px;
  padding: 10px;
  max-width: 50%;
}

.RedListSticker {
  min-width: 25px;
  max-width: 25px;
  min-height: 25px;
  max-height: 25px;
  border-radius: 6px;
  display: flex;
}

.RedListSticker>h5 {
  margin: auto;
}

.TraitsCardsGrid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  grid-auto-rows: 1fr;
  grid-gap: 16px;
}

.TraitCard {
  background: rgba(57, 118, 90, 0.05);
  border-radius: 16px;
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.FurtherInfoGrid {
  margin-top: 40px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(max(288px, 45%), 2fr));
  grid-gap: 40px;
}

.LinksGrid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(max(250px, 45%), 2fr));
  row-gap: 24px;
  column-gap: 40px;
}

.LinkOptionIcon {
  width: 16px;
  margin-right: 12px;
}

/********** RESPONSIVE **********/

@media screen and (width <=740px) {
  .Row {
    height: auto !important;
    flex-direction: column;
  }

  .Row .Column {
    margin-right: 0;
    margin-bottom: 24px;
  }

  .ReadMore,
  .Blurring {
    display: none;
  }

  .StatusWrapper,
  .LinksWrapper {
    padding: 16px 24px;
  }
}
</style>
