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
            <h4 class="fw-bold bottom-margin-4">
              {{ featureProperties.area_name }}
            </h4>
            <h5 class="black03">
              Dernière actualisation le
              {{ $formatDate(featureDataKey.last_date, false) }}
            </h5>
          </div>
          <a
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
            v-for="(item, index) in menuItems"
            :key="index"
            class="TabItem"
            :class="item.label === selectedMenuItem.label ? 'selected' : ''"
            @click="updateSelectedMenuItem(item)"
          >
            {{ item.label }}
          </span>
        </menu>
        <div class="MobileMapControlMenuWrapper">
          <dropdown-list
            v-model="selectedMenuItem"
            :z-index="3"
            :items-list="menuItems"
          />
          <a
            class="MapControlDownloadButton"
            :href="`/files/map/grid/${featureProperties.area_name}.pdf`"
            target="_blank"
          >
            <img class="MapControlDownloadButtonIcon" src="/download.svg" />
          </a>
        </div>
        <div
          class="MapControlSplit main right-margin-16"
          :class="
            scrolled && selectedMenuItem.label === 'Espèces' ? 'fixed' : ''
          "
        ></div>
      </header>
      <!-- Onglet "Tableau de bord" -->
      <div
        v-show="selectedMenuItem.label === 'Tableau de bord'"
        class="MapControlOverflow"
      >
        <h4 class="black02 fw-bold top-margin-24 bottom-margin-16">
          Indice de complétude ({{
            selectedSeason.label
              .replace('Période de ', '')
              .replace("Période d'", '')
              .toLowerCase()
          }})
        </h4>
        <div class="MapControlKeyData">
          <h3
            class="MapControlKeyDataValue fw-bold right-margin-24"
            :class="selectedSeason.value"
          >
            {{
              $toPercent(
                featureProperties[selectedSeason.value].percent_knowledge
              )
            }}%
          </h3>
          <h5 class="black03">
            des espèces de référence ont été signalées<br class="br" />
            sur la période Atlas 2019-2024
          </h5>
        </div>
        <div class="MapControlSplit"></div>
        <h4 class="black02 fw-bold bottom-margin-16">
          Répartition temporelle des données ({{
            $thousandDelimiter(featureDataKey.data_count)
          }})
        </h4>
        <div class="TimeDistributionBarPlot">
          <svg class="BarPlotSvg"></svg>
        </div>
        <div class="MapControlSplit"></div>
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
        v-show="selectedMenuItem.label === 'Espèces'"
        ref="speciesOverflow"
        class="MapControlOverflow"
      >
        <div class="AutocompleteWrapper map">
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
                <div class="flex">
                  <font style="font-family: sans-serif">&lt;</font>&nbsp;2019
                </div>
                <h5>({{ filteredSpecies.old_count }} esp.)</h5>
              </span>
              <span class="TableColumn large black02 fw-500">
                Après 2019
                <h5>({{ filteredSpecies.new_count }} esp.)</h5>
              </span>
              <span class="TableColumn small black02 fw-500">
                <div class="flex">
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
        v-show="selectedMenuItem.label === 'Prospection'"
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
          Points EPOC ODF ({{ featureEpocList.length }})
        </h4>
        <li
          v-for="(epoc, index) in featureEpocList"
          :key="index"
          class="MapControlDataOption pointer"
          @click="updateClickedEpocItem(epoc)"
        >
          <img class="MapControlDataOptionIcon" src="/location.svg" />
          {{ epoc.properties.id_ff }}
        </li>
        <span v-if="featureEpocList.length === 0" class="black02">
          Aucun point EPOC à afficher dans cette maille
        </span>
      </div>
    </div>
    <!-- MUNICIPALITIES DASHBOARD -->
    <div v-if="seeMoreMunicipalitiesIsClicked" class="MapControlDashboard">
      <div class="MapControlComeBack" @click="deleteSeeMoreMunicipalities">
        <img class="MapControlComeBackIcon" src="/previous.svg" />
        <span class="fw-500">{{ featureProperties.area_name }}</span>
      </div>
      <header class="MapControlHeader">
        <h4 class="fw-bold">
          Communes ({{ featureMunicipalitiesList.length }})
        </h4>
      </header>
      <div class="MapControlSplit right-margin-16"></div>
      <div class="MapControlOverflow">
        <li
          v-for="(municipality, index) in featureMunicipalitiesList"
          :key="index"
          class="MapControlDataOption"
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
      <header class="MapControlHeader">
        <h4 class="fw-bold">
          {{ clickedSpecies[`common_name_${lang}`] }}
        </h4>
      </header>
      <div class="MapControlSplit right-margin-16"></div>
      <div class="MapControlOverflow">
        <div class="MapControlDataOption">
          <img
            class="MapControlDataOptionIcon"
            src="/nav-bar/burger-black.svg"
          />
          {{ clickedSpecies.all_period.new_count }} donnée(s) sur la période
          Atlas 2019-2024
        </div>
        <div class="MapControlDataOption">
          <img class="MapControlDataOptionIcon" src="/prospecting.svg" />
          Espèce observée pour la dernière fois en
          {{ clickedSpecies.all_period.last_obs }}
        </div>
        <div class="MapControlDataOption">
          <img class="MapControlDataOptionIcon" src="/book.svg" />
          {{
            clickedSpecies.all_period.old_count > 0
              ? 'Espèce observée avant 2019'
              : 'Espèce non observée avant 2019'
          }}
        </div>
        <div class="MapControlDataOption">
          <img class="MapControlDataOptionIcon" src="/calendar.svg" />
          Calendrier d'observation sur la période Atlas 2019-2024 :
        </div>
        <div class="PhenologyWrapper">
          <div
            v-for="(item, index) in clickedSpecies.phenology"
            :key="index"
            class="PhenologyItem"
            :class="item.is_present ? 'colored' : ''"
          >
            <span class="black02">{{ item.label }}</span>
          </div>
        </div>
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
    featureProperties: {
      area_name: '',
      area_code: '',
      all_period: {
        old_count: 0,
        new_count: 0,
        percent_knowledge: 0,
      },
      breeding: {
        old_count: 0,
        new_count: 0,
        percent_knowledge: 0,
      },
      wintering: {
        old_count: 0,
        new_count: 0,
        percent_knowledge: 0,
      },
    },
    featureDataKey: {
      last_date: '',
      data_count: 0,
      taxa_count_all_period: 0,
      taxa_count_wintering: 0,
      taxa_count_breeding: 0,
      prospecting_hours_other_period: 0,
      prospecting_hours_wintering: 0,
      prospecting_hours_breeding: 0,
    },
    featureTaxaList: {
      all_period: [],
      breeding: [],
      wintering: [],
    },
    featureMunicipalitiesList: [],
    featureEpocList: {},
    search: '',
    seeMoreMunicipalitiesIsClicked: false,
    clickedSpecies: null,
    clickedEpocItem: null,
    lang: 'fr',
    // barPlotWidth: 0,
    // barPlotHeight: 0,
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
    menuItems: [
      { label: 'Tableau de bord' },
      { label: 'Espèces' },
      { label: 'Prospection' },
    ],
    selectedMenuItem: { label: 'Tableau de bord' },
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
      let filteredSpecies = this.featureTaxaList[
        this.selectedSpeciesStatus.value
      ]
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
    },
    prospectingHours() {
      if (this.selectedSeason.label === 'Toutes saisons') {
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
    },
  },
  watch: {
    clickedFeature(newVal) {
      this.clickedSpecies = null
      this.clickedEpocItem = null
      this.seeMoreMunicipalitiesIsClicked = false
      this.selectedMenuItem = { label: 'Tableau de bord' }
      this.initiateFeatureData(newVal)
      this.$axios
        .$get(`/api/v1/area/time_distrib/${this.featureID}/month`)
        .then((data) => {
          // console.log('Time distrib :')
          const formattedData = this.months.map((item, index) => {
            return {
              label: item,
              count_data:
                data.find((d) => d.label === index + 1)?.count_data || 0,
            }
          })
          // console.log(formattedData)
          // Get bar plot size
          const margin = { top: 10, right: 0, bottom: 24, left: 40 }
          const barPlotWidth = Math.max(
            parseFloat(
              d3
                .select(this.$el)
                .select('.TimeDistributionBarPlot')
                .style('width')
            ) -
              margin.left -
              margin.right,
            360
          )
          const barPlotHeight = 295 - margin.top - margin.bottom
          // Set X axis
          const x = d3
            .scaleBand()
            .range([0, barPlotWidth])
            .padding(0.2)
            .domain(
              formattedData.map(function (d) {
                return d.label
              })
            )
          // Set Y axis
          const y = d3
            .scaleLinear()
            .range([barPlotHeight, 0])
            .domain([
              0,
              d3.max(formattedData, function (d) {
                return d.count_data
              }),
            ])
          // Update bars
          const barPlotBars = d3
            .select(this.$el)
            .select('.BarPlotSvg')
            .selectAll('.bars')
            .data(formattedData)
          barPlotBars.exit().remove()
          barPlotBars
            .enter()
            .append('rect')
            .merge(barPlotBars)
            .attr('class', 'bars')
            .attr('x', function (d) {
              return x(d.label)
            })
            .attr('y', function (d) {
              return y(d.count_data)
            })
            .attr('width', x.bandwidth())
            .attr('height', function (d) {
              return barPlotHeight - y(d.count_data)
            })
            .attr('fill', 'rgba(57, 118, 90, 0.8)')
          // Update Y axis
          d3.select(this.$el)
            .select('.yAxis')
            .call(d3.axisLeft(y))
            .selectAll('text')
            .attr(
              'style',
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
            )
          d3.select(this.$el)
            .select('.BarPlotSvg')
            .selectAll('path')
            .style('opacity', 0)
          d3.select(this.$el)
            .select('.BarPlotSvg')
            .selectAll('line')
            .style('opacity', 0)
        })
        .catch((error) => {
          console.log(error)
        })
    },
  },
  mounted() {
    this.$refs.speciesOverflow.addEventListener('scroll', this.listener)
    this.initiateFeatureData(this.clickedFeature)
    this.$axios
      .$get(`/api/v1/area/time_distrib/${this.featureID}/month`)
      .then((data) => {
        // console.log('Time distrib :')
        const formattedData = this.months.map((item, index) => {
          return {
            label: item,
            count_data:
              data.find((d) => d.label === index + 1)?.count_data || 0,
          }
        })
        // console.log(formattedData)
        // Get bar plot size
        const margin = { top: 10, right: 0, bottom: 24, left: 40 }
        const barPlotWidth = Math.max(
          parseFloat(
            d3
              .select(this.$el)
              .select('.TimeDistributionBarPlot')
              .style('width')
          ) -
            margin.left -
            margin.right,
          360
        )
        const barPlotHeight = 295 - margin.top - margin.bottom
        // Get bar plot svg and set size
        const barPlotSvg = d3
          .select(this.$el)
          .select('.BarPlotSvg')
          .attr('width', barPlotWidth + margin.left + margin.right)
          .attr('height', barPlotHeight + margin.top + margin.bottom)
          .append('g')
          .attr('transform', `translate(${margin.left}, ${margin.top})`)
        // Set X axis and add it
        const x = d3
          .scaleBand()
          .range([0, barPlotWidth])
          .padding(0.2)
          .domain(
            formattedData.map(function (d) {
              return d.label
            })
          )
        barPlotSvg
          .append('g')
          .attr('transform', `translate(0, ${barPlotHeight})`)
          .call(d3.axisBottom(x))
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
        // Set Y axis and add it
        const y = d3
          .scaleLinear()
          .range([barPlotHeight, 0])
          .domain([
            0,
            d3.max(formattedData, function (d) {
              return d.count_data
            }),
          ])
        barPlotSvg
          .append('g')
          .attr('class', 'yAxis')
          .call(d3.axisLeft(y))
          .selectAll('text')
          .attr(
            'style',
            "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
          )
        barPlotSvg.selectAll('path').style('opacity', 0)
        barPlotSvg.selectAll('line').style('opacity', 0)
        // Bars
        barPlotSvg
          .selectAll('rect')
          .data(formattedData)
          .enter()
          .append('rect')
          .attr('class', 'bars')
          .attr('x', function (d) {
            return x(d.label)
          })
          .attr('y', function (d) {
            return y(d.count_data)
          })
          .attr('width', x.bandwidth())
          .attr('height', function (d) {
            return barPlotHeight - y(d.count_data)
          })
          .attr('fill', 'rgba(57, 118, 90, 0.8)')
      })
      .catch((error) => {
        console.log(error)
      })
  },
  methods: {
    initiateFeatureData(feature) {
      this.featureID = feature.id
      // console.log('----------------------------------------')
      // console.log('ID : ' + this.featureID)
      this.featureProperties = feature.properties
      this.featureProperties.area_name = this.featureProperties.area_name.replace(
        '10kmL93',
        ''
      )
      // console.log('Properties :')
      // console.log(this.featureProperties)
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
          // console.log('General stats :')
          // console.log(data)
          this.featureDataKey = data
        })
        .catch((error) => {
          console.log(error)
        })
      this.$axios
        .$get(`/api/v1/area/taxa_list/${this.featureID}`)
        .then((data) => {
          // console.log(data)
          this.featureTaxaList.all_period = data
          this.featureTaxaList.breeding = data.filter((item) => {
            return item.breeding.new_count > 0 || item.breeding.old_count > 0
          })
          this.featureTaxaList.wintering = data.filter((item) => {
            return item.wintering.new_count > 0 || item.wintering.old_count > 0
          })
          // console.log('Liste des espèces par période :')
          // console.log(this.featureTaxaList)
        })
        .catch((error) => {
          console.log(error)
        })
      this.$axios
        .$get(`/api/v1/area/list_areas/${this.featureID}/COM`)
        .then((data) => {
          // console.log('Liste des communes :')
          // console.log(data)
          this.featureMunicipalitiesList = data
        })
        .catch((error) => {
          console.log(error)
        })
      this.$axios
        .$get(`/api/v1/epoc?id_area=${this.featureID}`)
        .then((data) => {
          // console.log('Liste des points EPOC :')
          // console.log(data.features)
          this.featureEpocList = data.features
        })
        .catch((error) => {
          console.log(error)
        })
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
      if (!taxon.phenology[0].label) {
        const months = this.months.map((item) => {
          return item.charAt(0)
        })
        const phenology = months.map((item, index) => {
          return {
            label: item,
            is_present:
              taxon.phenology.find((d) => d === index + 1) !== undefined,
          }
        })
        taxon.phenology = phenology
      }
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
    updateSelectedMenuItem(item) {
      this.selectedMenuItem = item
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
  width: 100%;
  margin-bottom: 16px;
}

.AutocompleteWrapper {
  margin: 24px 0;
}

.pointer {
  cursor: pointer;
}

.align-end {
  align-self: flex-end;
}

.flex-1 {
  flex: 1;
}

.TableHeader {
  background: #fcfcfc;
}

.TableHeader.fixed {
  position: -webkit-sticky;
  position: sticky;
  z-index: 1; /* Pour que les .Dot ne passent pas par-dessus */
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
  margin-top: 16px;
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

@media screen and (max-width: 680px) {
  h3.MapControlKeyDataValue {
    font-size: 24px;
    line-height: 36px;
  }
}

@media screen and (max-width: 400px) {
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
