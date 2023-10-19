<template>
  <section class="MapControl">
    <!-- MAIN DASHBOARD -->
    <div
      v-show="
        !clickedSpecies && !clickedEpocItem && !seeMoreMunicipalitiesIsClicked
      "
      class="MapControlDashboard"
    >
      <!-- Header -->
      <header class="MapControlHeader">
        <div class="MapControlInfo">
          <div class="MapControlInfoTitles">
            <h4 v-if="featureProperties" class="fw-bold bottom-margin-4">
              {{ featureProperties.area_name }}
            </h4>
            <h5 v-if="featureDataKey" class="black03">
              Dernière actualisation le
              {{ $formatDate(featureDataKey.last_date, false) }}
            </h5>
            <h5 v-else class="black03">
              Cette maille ne comporte pas de données
            </h5>
          </div>
          <a
            v-if="featureProperties"
            class="MapControlDownloadButton"
            :href="`/files/map/grid/${featureProperties.area_name}.pdf`"
            target="_blank"
          >
            <img class="MapControlDownloadButtonIcon" src="/download.svg" />
          </a>
          <img
            class="MobileMapControlCloseIcon"
            src="/cross.svg"
            @click="closeMobileMapControl"
          />
        </div>
        <menu class="TabMenu">
          <span
            v-for="(item, index) in tabs"
            :key="index"
            class="TabItem"
            :class="item.label === selectedTab.label ? 'selected' : ''"
            @click="updateSelectedTab(item)"
          >
            {{ item.label }}
          </span>
        </menu>
        <div class="MobileMapControlMenuWrapper">
          <dropdown-list
            v-model="selectedTab"
            :z-index="3"
            :items-list="tabs"
          />
          <a
            v-if="featureProperties"
            class="MapControlDownloadButton"
            :href="`/files/map/grid/${featureProperties.area_name}.pdf`"
            target="_blank"
          >
            <img class="MapControlDownloadButtonIcon" src="/download.svg" />
          </a>
        </div>
        <div
          class="MapControlSplit main right-margin-16"
          :class="scrolled && selectedTab.label === 'Espèces' ? 'fixed' : ''"
        ></div>
      </header>
      <!-- Onglet "Tableau de bord" -->
      <div
        v-show="selectedTab.label === 'Tableau de bord'"
        class="MapControlOverflow"
      >
        <h4
          v-if="featureDataKey"
          class="black02 fw-bold top-margin-24 bottom-margin-16"
        >
          Indice de complétude ({{
            selectedSeason.label
              .replace('Période de ', '')
              .replace("Période d'", '')
              .toLowerCase()
          }})
        </h4>
        <div v-if="featureDataKey" class="MapControlKeyData">
          <h3
            class="MapControlKeyDataValue fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{
              (!featureProperties[selectedSeason.value].old_count ||
                featureProperties[selectedSeason.value].old_count == 0) &&
              featureProperties[selectedSeason.value].new_count > 0
                ? $toPercent(1)
                : $toPercent(
                    featureProperties[selectedSeason.value].percent_knowledge
                  )
            }}%
          </h3>
          <h5 class="black03">
            des espèces de référence ont été signalées<br class="br" />
            sur la période Atlas 2019-2024
          </h5>
        </div>
        <h4 v-else class="black02 fw-bold top-margin-24 bottom-margin-24">
          Il semblerait qu'aucune observation n'ait été réalisée sur cette
          maille à ce jour.
        </h4>
        <div class="MapControlSplit"></div>
        <h4
          v-if="featureDataKey"
          class="black02 fw-bold top-margin-24 bottom-margin-16"
        >
          Nombre d'espèces ({{
            selectedSeason.label
              .replace('Période de ', '')
              .replace("Période d'", '')
              .toLowerCase()
          }})
        </h4>
        <div v-if="featureDataKey" class="MapControlKeyData">
          <h3
            class="MapControlKeyDataValue large fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{ featureProperties[selectedSeason.value].old_count || 0 }}
            espèce{{
              featureProperties[selectedSeason.value].old_count > 1 ? 's' : ''
            }}
          </h3>
          <h3
            class="MapControlKeyDataValue small fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{ featureProperties[selectedSeason.value].old_count || 0 }} esp.
          </h3>
          <h5 class="black03">
            signalée{{
              featureProperties[selectedSeason.value].old_count > 1 ? 's' : ''
            }}
            sur la période <b>Avant 2019</b>
          </h5>
        </div>
        <div v-if="featureDataKey" class="MapControlKeyData">
          <h3
            class="MapControlKeyDataValue large fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{ featureProperties[selectedSeason.value].new_count || 0 }}
            espèce{{
              featureProperties[selectedSeason.value].new_count > 1 ? 's' : ''
            }}
          </h3>
          <h3
            class="MapControlKeyDataValue small fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{ featureProperties[selectedSeason.value].new_count || 0 }} esp.
          </h3>
          <h5 class="black03">
            signalée{{
              featureProperties[selectedSeason.value].new_count > 1 ? 's' : ''
            }}
            sur la période <b>Atlas 2019-2024</b>
          </h5>
        </div>
        <div v-if="featureDataKey" class="MapControlSplit"></div>
        <h4
          v-if="featureDataKey && featureDataKey.taxa_count_all_period > 0"
          class="black02 fw-bold bottom-margin-16"
        >
          Répartition temporelle des données ({{
            $thousandDelimiter(featureDataKey.data_count)
          }})
        </h4>
        <div
          class="TimeDistributionBarPlot"
          :class="timeDistributionIsOn ? '' : 'hidden'"
        >
          <svg class="BarPlotSvg"></svg>
        </div>
        <div v-if="timeDistributionIsOn" class="MapControlSplit"></div>
        <div class="MapControlSeeMoreWrapper">
          <h4 class="black02 fw-bold">
            Communes ({{ featureMunicipalitiesList.length }})
          </h4>
          <div class="MapControlSeeMore">
            <h5
              class="large green01 fw-600 right-margin-12"
              @click="updateSeeMoreMunicipalities"
            >
              Voir toutes les communes
            </h5>
            <h5
              class="small green01 fw-600 right-margin-12"
              @click="updateSeeMoreMunicipalities"
            >
              Voir tout
            </h5>
            <img
              class="MapControlSeeMoreChevron"
              src="/chevron-right-green.svg"
            />
          </div>
        </div>
        <li
          v-for="(municipality, index) in featureMunicipalitiesList.slice(0, 3)"
          :key="index"
          class="MapControlDataOption"
        >
          {{ municipality.area_name }}
        </li>
        <!-- <div class="MapControlSplit"></div>
        <nuxt-link to="#" class="PrimaryButton" style="margin-top: 6px"
          >Contacter le coordinateur local départemental</nuxt-link
        > -->
      </div>
      <!-- Onglet "Espèces" -->
      <div
        v-show="selectedTab.label === 'Espèces'"
        ref="speciesOverflow"
        class="MapControlOverflow"
      >
        <div
          class="AutocompleteWrapper map"
          :class="search.length > 0 ? 'open' : ''"
        >
          <input v-model="search" type="text" placeholder="Rechercher" />
          <div class="AutocompleteGadgets map">
            <img
              v-if="search.length > 0"
              class="AutocompleteCloseIcon map"
              src="/close.svg"
              @click="clearResults"
            />
            <div class="AutocompleteSearch map">
              <img class="AutocompleteSearchIcon map" src="/search.svg" />
            </div>
          </div>
        </div>
        <div class="ChipMenu">
          <div
            v-for="(item, index) in speciesStatusList"
            :key="index"
            class="ChipItem"
            :class="
              item.value === selectedSpeciesStatus.value ? 'selected' : ''
            "
            @click="updateSelectedSpeciesStatus(item)"
          >
            {{ item.label }}
          </div>
        </div>
        <dropdown-list
          v-model="selectedSpeciesStatus"
          :z-index="2"
          :items-list="speciesStatusList"
        />
        <div class="TableHeader" :class="scrolled ? 'fixed' : ''">
          <div class="TableLineContent">
            <span class="black02 fw-600 align-end flex-1">
              {{ filteredSpecies.list.length }} espèces
            </span>
            <div class="TableColumnsWrapper">
              <span class="TableColumn large black02 fw-500">
                Avant 2019
                <h5>({{ filteredSpecies.old_count }} esp.)</h5>
              </span>
              <span class="TableColumn small black02 fw-500">
                <div class="display-flex">
                  <font style="font-family: sans-serif">&lt;</font>&nbsp;2019
                </div>
                <h5>({{ filteredSpecies.old_count }} esp.)</h5>
              </span>
              <span class="TableColumn large black02 fw-500">
                Après 2019
                <h5>({{ filteredSpecies.new_count }} esp.)</h5>
              </span>
              <span class="TableColumn small black02 fw-500">
                <div class="display-flex">
                  <font style="font-family: sans-serif">&ge;</font>&nbsp;2019
                </div>
                <h5>({{ filteredSpecies.new_count }} esp.)</h5>
              </span>
            </div>
          </div>
          <div class="MapControlSplit header table"></div>
        </div>
        <div
          v-for="taxon in filteredSpecies.list"
          :key="taxon.cd_nom"
          class="TableLine"
        >
          <div
            class="TableLineContent pointer"
            @click="updateClickedSpecies(taxon)"
          >
            <div class="HelperWrapper">
              <div
                class="Dot"
                :class="
                  taxon.breeding.new_status
                    ? taxon.breeding.new_status.replace('Nicheur ', '')
                    : ''
                "
              ></div>
              <div v-if="taxon.breeding.new_status" class="HelperTip"></div>
              <h5
                v-if="taxon.breeding.new_status"
                class="HelperContent white02 nowrap"
              >
                {{ taxon.breeding.new_status }} (ODF)
              </h5>
            </div>
            <span class="flex-1">{{ taxon[`common_name_${lang}`] }}</span>
            <div class="TableColumnsWrapper">
              <div class="TableColumn">
                <img
                  v-show="taxon[selectedSpeciesStatus.value].old_count > 0"
                  class="TableCheckIcon"
                  src="/check-green.svg"
                />
              </div>
              <div class="TableColumn">
                <img
                  v-show="taxon[selectedSpeciesStatus.value].new_count > 0"
                  class="TableCheckIcon"
                  src="/check-green.svg"
                />
              </div>
            </div>
          </div>
          <div class="MapControlSplit table"></div>
        </div>
      </div>
      <!-- Onglet "Prospection" -->
      <div
        v-show="selectedTab.label === 'Prospection'"
        class="MapControlOverflow"
      >
        <h4 class="black02 fw-bold top-margin-24 bottom-margin-16">
          Durée totale de prospection ({{
            selectedSeason.label
              .replace('Période de ', '')
              .replace("Période d'", '')
              .toLowerCase()
          }})
        </h4>
        <div class="MapControlKeyData">
          <h3
            class="MapControlKeyDataValue large fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{ prospectingHours }} heure(s)
          </h3>
          <h3
            class="MapControlKeyDataValue small fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{ prospectingHours }} h
          </h3>
          <h5 class="black03">enregistrées sur la période Atlas 2019-2024</h5>
        </div>
        <div class="MapControlSplit"></div>
        <h4 class="black02 fw-bold bottom-margin-16">
          Points EPOC ODF {{ new Date().getFullYear() }} ({{
            featureEpocOdfList.length
          }})
        </h4>
        <li
          v-for="(epoc, index) in featureEpocOdfList"
          :key="'epocOdf' + index"
          class="MapControlDataOption pointer"
          @click="updateClickedEpocItem(epoc)"
        >
          <img class="MapControlDataOptionIcon" src="/location.svg" />
          {{ epoc.properties.id_ff.replace('-', ' ').replace(/_/g, ' ') }}
        </li>
        <li
          v-if="!featureEpocOdfList.length"
          class="MapControlDataOption bottom-margin-24"
        >
          Aucun point EPOC ODF à afficher dans cette maille.
        </li>
        <div class="MapControlSplit top-margin-24"></div>
        <h4 class="black02 fw-bold bottom-margin-16">
          Points EPOC ODF réalisés ({{ featureEpocOdfRealizedList.length }})
        </h4>
        <li
          v-for="(epoc, index) in featureEpocOdfRealizedList"
          :key="'epocOdfRealized' + index"
          class="MapControlDataOption pointer"
          @click="updateClickedEpocItem(epoc)"
        >
          <img class="MapControlDataOptionIcon" src="/location.svg" />
          EPOC ODF réalisé le
          {{
            $formatDate(epoc.properties.date, true) +
            ' à ' +
            epoc.properties.time.slice(0, -3)
          }}
        </li>
        <li
          v-if="!featureEpocOdfRealizedList.length"
          class="MapControlDataOption bottom-margin-24"
        >
          Aucun point EPOC ODF réalisé dans cette maille.
        </li>
        <div class="MapControlSplit top-margin-24"></div>
        <h4 class="black02 fw-bold bottom-margin-16">
          Points EPOC réalisés ({{ featureEpocRealizedList.length }})
        </h4>
        <li
          v-if="featureEpocRealizedList.length > 0"
          class="MapControlDataOption"
        >
          Pour accéder aux informations des points EPOC réalisés, veuillez les
          sélectionner directement sur la carte (après avoir affiché la couche
          "Points EPOC").
        </li>
        <li v-else class="MapControlDataOption">
          Aucun point EPOC réalisé dans cette maille.
        </li>
      </div>
    </div>
    <!-- MUNICIPALITIES DASHBOARD -->
    <div v-if="seeMoreMunicipalitiesIsClicked" class="MapControlDashboard">
      <div class="MapControlComeBack" @click="deleteSeeMoreMunicipalities">
        <img class="MapControlComeBackIcon" src="/previous.svg" />
        <span class="fw-500">{{ featureProperties.area_name }}</span>
      </div>
      <header class="MapControlInfo">
        <h4 class="fw-bold">
          Communes ({{ featureMunicipalitiesList.length }})
        </h4>
      </header>
      <div class="MapControlSplit right-margin-16 no-bottom-margin"></div>
      <div class="MapControlOverflow">
        <li
          v-for="(municipality, index) in featureMunicipalitiesList"
          :key="index"
          class="MapControlDataOption top-margin"
        >
          {{ municipality.area_name }}
        </li>
      </div>
    </div>
    <!-- SPECIES DASHBOARD -->
    <div v-if="clickedSpecies" class="MapControlDashboard">
      <div class="MapControlComeBack" @click="deleteClickedSpecies">
        <img class="MapControlComeBackIcon" src="/previous.svg" />
        <span class="fw-500">{{ featureProperties.area_name }}</span>
      </div>
      <header class="MapControlInfo">
        <h4 class="fw-bold">
          {{ clickedSpecies[`common_name_${lang}`] }}
        </h4>
      </header>
      <div class="MapControlSplit right-margin-16 no-bottom-margin"></div>
      <div class="MapControlOverflow">
        <li class="MapControlDataOption top-margin-24">
          <img
            class="MapControlDataOptionIcon"
            src="/nav-bar/burger-black.svg"
          />
          {{ clickedSpecies.all_period.new_count }} donnée(s) sur la période
          Atlas 2019-2024
        </li>
        <li class="MapControlDataOption">
          <img class="MapControlDataOptionIcon" src="/prospecting.svg" />
          Espèce observée pour la dernière fois en
          {{ clickedSpecies.all_period.last_obs }}
        </li>
        <li class="MapControlDataOption">
          <img class="MapControlDataOptionIcon" src="/book.svg" />
          {{
            clickedSpecies.all_period.old_count > 0
              ? 'Espèce observée avant 2019'
              : 'Espèce non observée avant 2019'
          }}
        </li>
        <li class="MapControlDataOption">
          <img class="MapControlDataOptionIcon" src="/calendar.svg" />
          Calendrier d'observation sur la période Atlas 2019-2024 :
        </li>
        <div class="PhenologyWrapper">
          <div
            v-for="(item, index) in clickedSpeciesPhenology"
            :key="index"
            class="PhenologyItem"
            :class="item.is_present ? 'colored' : ''"
          >
            <span class="black02">{{ item.label }}</span>
          </div>
        </div>
        <nuxt-link
          :to="`/species/${clickedSpecies.cd_nom}`"
          class="PrimaryButton flex-1"
        >
          Voir la fiche espèce
        </nuxt-link>
      </div>
    </div>
    <!-- EPOC DASHBOARD -->
    <div v-if="clickedEpocItem" class="MapControlDashboard">
      <div class="MapControlComeBack" @click="deleteClickedEpocItem">
        <img class="MapControlComeBackIcon" src="/previous.svg" />
        <span class="fw-500">{{ featureProperties.area_name }}</span>
      </div>
      <epoc-dashboard-control
        v-if="clickedEpocItem"
        :clicked-epoc-point="clickedEpocItem"
        @mobileMapControl="closeMobileMapControl"
      />
    </div>
  </section>
</template>

<script>
import EpocDashboardControl from '~/components/prospecting/EpocDashboardControl.vue'
const d3 = require('d3')

export default {
  components: {
    'epoc-dashboard-control': EpocDashboardControl,
  },
  props: {
    clickedFeature: {
      type: Object,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    featureID: '',
    featureProperties: null,
    featureDataKey: null,
    timeDistributionIsOn: true,
    featureTaxaList: null,
    featureMunicipalitiesList: [],
    featureEpocOdfList: [],
    featureEpocOdfRealizedList: [],
    featureEpocRealizedList: [],
    search: '',
    seeMoreMunicipalitiesIsClicked: false,
    clickedSpecies: null,
    clickedEpocItem: null,
    lang: 'fr',
    months: [
      'Jan',
      'Fév',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sept',
      'Oct',
      'Nov',
      'Déc',
    ],
    tabs: [
      { label: 'Tableau de bord' },
      { label: 'Espèces' },
      { label: 'Prospection' },
    ],
    selectedTab: { label: 'Tableau de bord' },
    speciesStatusList: [
      { label: 'Toutes', value: 'all_period' },
      { label: 'Espèces nicheuses', value: 'breeding' },
      { label: 'Espèces hivernantes', value: 'wintering' },
    ],
    selectedSpeciesStatus: { label: 'Toutes', value: 'all_period' },
    scrolled: false,
  }),
  computed: {
    filteredSpecies() {
      if (this.featureTaxaList) {
        let filteredSpecies =
          this.featureTaxaList[this.selectedSpeciesStatus.value]
        if (this.search.length > 0) {
          filteredSpecies = this.featureTaxaList[
            this.selectedSpeciesStatus.value
          ].filter(
            (species) =>
              species[`common_name_${this.lang}`] &&
              species[`common_name_${this.lang}`]
                .toLowerCase()
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '')
                .includes(
                  this.search
                    .toLowerCase()
                    .normalize('NFD')
                    .replace(/[\u0300-\u036f]/g, '')
                )
          )
        }
        const speciesOldCount = filteredSpecies.filter((item) => {
          return item[this.selectedSpeciesStatus.value].old_count > 0
        }).length
        const speciesNewCount = filteredSpecies.filter((item) => {
          return item[this.selectedSpeciesStatus.value].new_count > 0
        }).length
        return {
          list: filteredSpecies,
          old_count: speciesOldCount,
          new_count: speciesNewCount,
        }
      } else {
        return {
          list: [],
          old_count: 0,
          new_count: 0,
        }
      }
    },
    clickedSpeciesPhenology() {
      const months = this.months.map((item) => {
        return item.charAt(0)
      })
      if (!this.clickedSpecies.phenology.length) {
        const phenology = months.map((item) => {
          return {
            label: item,
            is_present: false,
          }
        })
        return phenology
      } else {
        const phenology = months.map((item, index) => {
          return {
            label: item,
            is_present:
              this.clickedSpecies.phenology.find((d) => d === index + 1) !==
              undefined,
          }
        })
        return phenology
      }
    },
    prospectingHours() {
      if (this.featureDataKey) {
        if (this.selectedSeason.value === 'all_period') {
          return (
            Math.round(
              (this.featureDataKey.prospecting_hours_breeding +
                this.featureDataKey.prospecting_hours_wintering +
                this.featureDataKey.prospecting_hours_other_period) *
                10
            ) / 10
          )
        } else {
          return (
            Math.round(
              this.featureDataKey[
                'prospecting_hours_' + this.selectedSeason.value
              ] * 10
            ) / 10
          )
        }
      } else {
        return 0
      }
    },
  },
  watch: {
    clickedFeature(newVal) {
      this.clickedSpecies = null
      this.clickedEpocItem = null
      this.seeMoreMunicipalitiesIsClicked = false
      this.selectedTab = { label: 'Tableau de bord' }
      this.initiateFeatureData(newVal)
    },
  },
  mounted() {
    this.$refs.speciesOverflow.addEventListener('scroll', this.listener)
    const formattedData = this.months.map((item, index) => {
      return {
        label: item,
        count_data: 0,
      }
    })
    this.createBarPlot(formattedData, 'mounted')
    this.initiateFeatureData(this.clickedFeature)
  },
  methods: {
    initiateFeatureData(feature) {
      this.featureID = feature.id
      // console.debug('----------------------------------------')
      // console.debug('ID : ' + this.featureID)
      this.featureProperties = feature.properties
      this.featureProperties.area_name = this.featureProperties.area_name
        .replace('10kmL93', '')
        .replace('10kmUTM22', '')
      // console.debug('Properties :')
      // console.debug(this.featureProperties)
      this.$router.push({
        path: '/prospecting',
        query: {
          area: `${this.featureProperties.area_code}`,
          type: 'ATLAS_GRID',
        },
      })
      this.$axios
        .$get(`/api/v1/area/general_stats/${this.featureID}`)
        .then((data) => {
          // console.debug('General stats :')
          // console.debug(data)
          if (data) {
            this.featureDataKey = data
          } else {
            this.featureDataKey = null
          }
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
        .finally(() => {
          // Si la maille comporte des données...
          if (this.featureDataKey) {
            // ... alors on récupère la liste des espèces
            this.$axios
              .$get(`/api/v1/area/taxa_list/${this.featureID}`)
              .then((data) => {
                // console.debug(data)
                if (data) {
                  this.featureTaxaList = {}
                  this.featureTaxaList.all_period = data
                  this.featureTaxaList.breeding = data.filter((item) => {
                    return (
                      item.breeding.new_count > 0 || item.breeding.old_count > 0
                    )
                  })
                  this.featureTaxaList.wintering = data.filter((item) => {
                    return (
                      item.wintering.new_count > 0 ||
                      item.wintering.old_count > 0
                    )
                  })
                  // console.debug('Liste des espèces par période :')
                  // console.debug(this.featureTaxaList)
                } else {
                  this.featureTaxaList = null
                }
              })
              .catch((error) => {
                console.debug(`${error}`)
              })
          } else {
            // Sinon la liste des espèces est vide
            this.featureTaxaList = null
          }
        })
      const params = {
        id_area: this.featureID,
        area_type: 'COM',
      }
      this.$axios
        .$get(`/api/v1/area/list_areas`, { params })
        .then((data) => {
          // console.debug('Liste des communes :')
          // console.debug(data)
          this.featureMunicipalitiesList = data
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
      this.$axios
        .$get(`/api/v1/epoc?id_area=${this.featureID}`)
        .then((data) => {
          if (data) {
            // console.debug('Liste des points EPOC ODF statiques :')
            // console.debug(data.features)
            this.featureEpocOdfList = data.features
          } else {
            this.featureEpocOdfList = []
          }
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
      this.$axios
        .$get(`/api/v1/epoc/realized?id_area=${this.featureID}`)
        .then((data) => {
          if (data) {
            // console.debug('Liste des points EPOC réalisés :')
            // console.debug(data.features)
            this.featureEpocOdfRealizedList = data.features.filter((epoc) => {
              return epoc.properties.project_code === 'EPOC-ODF'
            })
            this.featureEpocRealizedList = data.features.filter((epoc) => {
              return epoc.properties.project_code === 'EPOC'
            })
          } else {
            this.featureEpocOdfRealizedList = []
            this.featureEpocRealizedList = []
          }
        })
        .catch((error) => {
          console.debug(`${error}`)
        })
      // Si la maille comporte des données après 2019...
      if (this.featureProperties.all_period.new_count) {
        // ... alors on récupère la répartition des données
        this.$axios
          .$get(`/api/v1/area/time_distrib/${this.featureID}/month`)
          .then((data) => {
            // console.debug(data)
            if (data) {
              this.timeDistributionIsOn = true
              const formattedData = this.months.map((item, index) => {
                return {
                  label: item,
                  count_data:
                    data.find((d) => d.label === index + 1)?.count_data || 0,
                }
              })
              this.createBarPlot(formattedData, 'watch')
            } else {
              this.timeDistributionIsOn = false
            }
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
      } else {
        // Sinon on n'affiche pas la répartition des données
        this.timeDistributionIsOn = false
      }
    },
    createBarPlot(formattedData, hook) {
      // Get bar plot size
      const margin = { top: 10, right: 0, bottom: 24, left: 48 }
      const barPlotWidth = Math.max(
        parseFloat(
          d3.select(this.$el).select('.TimeDistributionBarPlot').style('width')
        ) -
          margin.left -
          margin.right,
        360
      )
      const barPlotHeight =
        parseFloat(
          d3.select(this.$el).select('.TimeDistributionBarPlot').style('height')
        ) -
        margin.top -
        margin.bottom
      // Get bar plot svg and set size
      const barPlotSvg = d3
        .select(this.$el)
        .select('.BarPlotSvg')
        .attr('width', barPlotWidth + margin.left + margin.right)
        .attr('height', barPlotHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left}, ${margin.top})`)
      // Set X axis
      const xAxis = d3
        .scaleBand()
        .range([0, barPlotWidth])
        .padding(0.2)
        .domain(
          formattedData.map(function (d) {
            return d.label
          })
        )
      // Set Y axis
      const yAxis = d3
        .scaleLinear()
        .range([barPlotHeight, 0])
        .domain([
          0,
          d3.max(formattedData, function (d) {
            return d.count_data
          }),
        ])
      if (hook === 'mounted') {
        // Add X axis
        barPlotSvg
          .append('g')
          .attr('class', 'xAxis')
          .attr('transform', `translate(0, ${barPlotHeight})`)
          .call(d3.axisBottom(xAxis))
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
        // Add Y axis
        barPlotSvg
          .append('g')
          .attr('class', 'yAxis')
          .call(d3.axisLeft(yAxis))
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
        // Bars
        barPlotSvg
          .append('g')
          .attr('class', 'bars')
          .selectAll('rect')
          .data(formattedData)
          .enter()
          .append('rect')
          .attr('class', 'bar')
          .attr('x', function (d) {
            return xAxis(d.label)
          })
          .attr('y', function (d) {
            return yAxis(d.count_data)
          })
          .attr('width', xAxis.bandwidth())
          .attr('height', function (d) {
            return barPlotHeight - yAxis(d.count_data)
          })
          .attr('fill', 'rgba(57, 118, 90, 0.8)')
      } else {
        // Update X axis
        d3.select(this.$el)
          .select('.xAxis')
          .attr('transform', `translate(0, ${barPlotHeight})`)
          .call(d3.axisBottom(xAxis))
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
        // Update Y axis
        const formatter = d3
          .formatLocale({
            decimal: '.',
            thousands: ' ',
            grouping: [3],
            currency: ['', ''],
          })
          .format(',.0f')
        d3.select(this.$el)
          .select('.yAxis')
          .call(d3.axisLeft(yAxis).tickFormat(formatter))
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
        // Update bars
        const barPlotBars = d3
          .select(this.$el)
          .select('.BarPlotSvg')
          .selectAll('.bar')
          .data(formattedData)
        barPlotBars.exit().remove()
        barPlotBars
          .enter()
          .append('rect')
          .merge(barPlotBars)
          .attr('class', 'bar')
          .attr('x', function (d) {
            return xAxis(d.label)
          })
          .attr('y', function (d) {
            return yAxis(d.count_data)
          })
          .attr('width', xAxis.bandwidth())
          .attr('height', function (d) {
            return barPlotHeight - yAxis(d.count_data)
          })
          .attr('fill', 'rgba(57, 118, 90, 0.8)')
      }
      // Delete axis lines and tricks
      d3.select(this.$el)
        .select('.BarPlotSvg')
        .selectAll('path')
        .style('opacity', 0)
      d3.select(this.$el)
        .select('.BarPlotSvg')
        .selectAll('line')
        .style('opacity', 0)
    },
    clearResults() {
      this.search = ''
    },
    updateSeeMoreMunicipalities() {
      this.seeMoreMunicipalitiesIsClicked = true
    },
    deleteSeeMoreMunicipalities() {
      this.seeMoreMunicipalitiesIsClicked = false
    },
    updateClickedSpecies(taxon) {
      this.clickedSpecies = taxon
    },
    deleteClickedSpecies() {
      this.clickedSpecies = null
    },
    updateClickedEpocItem(epoc) {
      this.clickedEpocItem = epoc
    },
    deleteClickedEpocItem() {
      this.clickedEpocItem = null
    },
    updateSelectedTab(item) {
      this.selectedTab = item
    },
    updateSelectedSpeciesStatus(item) {
      this.selectedSpeciesStatus = item
    },
    listener() {
      this.$debounce(this.handleScroll())
    },
    handleScroll() {
      this.scrolled = this.$refs.speciesOverflow.scrollTop > 132
    },
    // MOBILE
    closeMobileMapControl() {
      this.$emit('mobileMapControl', false)
    },
  },
}
</script>

<style scoped>
.MapControl {
  width: 506px;
}

.DropdownListWrapper {
  margin-bottom: 24px !important;
}

.TimeDistributionBarPlot {
  /* width: 100%; */
  height: 300px;
  margin-bottom: 16px;
  overflow-y: hidden;
}

.TimeDistributionBarPlot.hidden {
  position: absolute !important;
  top: -9999px !important;
  left: -9999px !important;
}

.AutocompleteWrapper {
  margin: 24px 0;
}

.align-end {
  align-self: flex-end;
}

.TableHeader {
  background: #fcfcfc;
}

.TableHeader.fixed {
  position: sticky;
  z-index: 1;

  /* Pour que les .Dot ne passent pas par-dessus */
  top: 0;
}

.MapControlSplit.main.fixed {
  display: none;
}

.TableLineContent {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
}

.TableLineContent span {
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}

.TableLine:last-child .TableLineContent {
  margin-bottom: 0;
}

.TableColumnsWrapper {
  display: flex;
  align-items: center;
}

.TableColumn {
  width: 86px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

span.TableColumn.small {
  display: none;
}

.MapControlSplit.header {
  background: #000;
}

.MapControlSplit.table {
  margin-bottom: 8px;
}

.TableLine:last-child .MapControlSplit.table {
  display: none;
}

.TableCheckIcon {
  width: 15px;
}

.Dot {
  background: #fcfcfc;
  min-width: 12px;
  max-width: 12px;
  min-height: 12px;
  max-height: 12px;
  border-radius: 50%;
  margin-right: 10px;
}

.Dot.possible {
  background: #eece25;
}

.Dot.probable {
  background: #eb6a0a;
}

.Dot.certain {
  background: #932747;
}

.HelperTip {
  left: 20px;
  top: -2px;
}

.Dot:hover ~ .HelperTip {
  display: block;
}

.HelperContent {
  top: -19px;
  left: 28px;
}

.Dot:hover ~ .HelperContent {
  display: flex;
}

.PhenologyWrapper {
  width: 100%;
  margin: 16px 0 24px;
  display: flex;
  justify-content: space-between;
}

.PhenologyItem {
  min-width: 24px;
  max-width: 24px;
  min-height: 24px;
  max-height: 24px;
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.PhenologyItem.colored {
  background: rgba(57, 118, 90, 0.3);
}

/********** RESPONSIVE **********/

@media screen and (width <=680px) {
  h3.MapControlKeyDataValue {
    font-size: 24px;
    line-height: 36px;
  }
}

@media screen and (width <=400px) {
  .br,
  .MapControlSeeMore h5.large.green01,
  span.TableColumn.large,
  .MapControlKeyDataValue.large {
    display: none;
  }

  .MapControlSeeMore h5.small.green01,
  span.TableColumn.small,
  .MapControlKeyDataValue.small {
    display: flex;
  }

  .TableColumn {
    width: 66px;
  }

  .TableLineContent.pointer span.flex-1 {
    font-size: 12px;
    line-height: 18px;
  }

  .PhenologyItem {
    min-width: 20px;
    max-width: 20px;
    min-height: 20px;
    max-height: 20px;
  }

  .PhenologyItem span {
    font-size: 12px;
    line-height: 18px;
  }
}
</style>
