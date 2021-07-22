<template>
  <section class="FeatureDashboardControl">
    <!-- MAIN DASHBOARD -->
    <div
      v-show="
        !clickedSpecies && !clickedEpocItem && !seeMoreMunicipalitiesIsClicked
      "
      class="SpecificSubDashboard"
    >
      <!-- HEADER -->
      <div class="FeatureDashboardHeader">
        <div class="FeatureDashboardHeaderText">
          <h1 class="FeatureDashboardTitle">
            {{ featureProperties.area_name }}
          </h1>
          <span class="FeatureDashboardLastUpdate"
            >Dernière actualisation le
            {{ $formatDate(featureDataKey.last_date) }}</span
          >
        </div>
        <a
          class="FeatureDashboardDownloadButton"
          :href="`/files/map/grid/${featureProperties.area_name}.pdf`"
          target="_blank"
        >
          <img class="FeatureDashboardDownloadButtonIcon" src="/download.svg" />
        </a>
      </div>
      <menu>
        <span
          v-for="(item, index) in menuItems"
          :key="index"
          class="MenuItem MainTextStyle"
          :class="[item === selectedMenuItem ? 'selected' : '']"
          @click="updateSelectedMenuItem(item)"
        >
          {{ item }}
        </span>
      </menu>
      <!-- TABLEAU DE BORD -->
      <div
        v-show="selectedMenuItem === 'Tableau de bord'"
        class="FeatureDashboardContent"
      >
        <div class="Split main"></div>
        <h2 class="FeatureDashboardTitle margin">
          Indice de complétude (toutes saisons)
        </h2>
        <div class="KeyDataContent">
          <div class="KeyDataValue">
            {{ $toPercent(featureProperties.all_period.percent_knowledge) }}%
          </div>
          <div class="KeyDataLabel">
            des espèces de référence ont été signalées<br />
            sur la période Atlas 2019-2024
          </div>
        </div>
        <div class="Split main"></div>
        <h2 class="FeatureDashboardTitle margin">
          Répartition temporelle des données ({{
            $thousandDelimiter(featureDataKey.data_count)
          }})
        </h2>
        <div class="TimeDistributionBarPlot">
          <svg class="BarPlotSvg"></svg>
        </div>
        <div class="Split main"></div>
        <div class="FeatureDashboardHeader margin">
          <h2 class="FeatureDashboardTitle">
            Communes ({{ featureMunicipalitiesList.length }})
          </h2>
          <div>
            <span class="SeeMoreData" @click="updateSeeMoreMunicipalities"
              >Voir toutes les communes</span
            >
            <img class="SeeMoreDataChevron" src="/chevron-right-green.svg" />
          </div>
        </div>
        <div class="DashboardSubDataWrapper">
          <span
            v-for="(municipality, index) in featureMunicipalitiesList.slice(
              0,
              3
            )"
            :key="index"
            class="DashboardSubData MainTextStyle"
          >
            {{ municipality.area_name }}
          </span>
        </div>
        <!-- <div class="Split main"></div>
        <nuxt-link to="#" class="PrimaryButton" style="margin-top: 6px"
          >Contacter le coordinateur local départemental</nuxt-link
        > -->
      </div>
      <!-- ESPÈCES -->
      <div
        v-show="selectedMenuItem === 'Espèces'"
        class="FeatureDashboardContent"
      >
        <div class="Split main"></div>
        <div class="AutocompleteWrapper">
          <input v-model="search" type="text" placeholder="Rechercher" />
          <div class="AutocompleteAdvanced">
            <div class="CloseIconBox">
              <img
                v-show="search.length > 0"
                class="CloseIcon"
                src="/close.svg"
                @click="clearResults"
              />
            </div>
            <div class="SearchIconBox">
              <img class="SearchIcon" src="/search.svg" />
            </div>
          </div>
        </div>
        <div class="SpeciesStatusMenu">
          <div
            v-for="(item, index) in speciesStatusList"
            :key="index"
            class="SpeciesStatusMenuItem"
            :class="[
              item.value === selectedSpeciesStatus.value ? 'selected' : '',
            ]"
            @click="updateSelectedSpeciesStatus(item)"
          >
            {{ item.label }}
          </div>
        </div>
        <div class="SpeciesTable MainTextStyle">
          <div class="SpeciesTableLine">
            <span class="SpeciesTableNumber"
              >{{ filteredSpecies.length }} espèce(s)</span
            >
            <div class="SpeciesTableColumnsContent">
              <span class="SpeciesTableColumn">Avant 2019</span
              ><span class="SpeciesTableColumn">Après 2019</span>
            </div>
          </div>
          <div v-for="taxon in filteredSpecies" :key="taxon.cd_nom">
            <div class="Split speciesTable"></div>
            <div
              class="SpeciesTableLine pointer"
              @click="updateClickedSpecies(taxon)"
            >
              <span>{{ taxon[`common_name_${lang}`] }}</span>
              <div class="SpeciesTableColumnsContent">
                <div class="SpeciesTableColumn">
                  <img
                    v-show="taxon[selectedSpeciesStatus.value].old_count > 0"
                    class="SpeciesTableColumnCheck"
                    src="/check.svg"
                  />
                </div>
                <div class="SpeciesTableColumn">
                  <img
                    v-show="taxon[selectedSpeciesStatus.value].new_count > 0"
                    class="SpeciesTableColumnCheck"
                    src="/check.svg"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- PROSPECTION -->
      <div
        v-show="selectedMenuItem === 'Prospection'"
        class="FeatureDashboardContent"
      >
        <div class="Split main"></div>
        <h2 class="FeatureDashboardTitle margin">
          Durée totale de prospection
        </h2>
        <div class="KeyDataContent">
          <div class="KeyDataValue">
            {{
              Math.round(
                (featureDataKey.prospecting_hours_breeding +
                  featureDataKey.prospecting_hours_wintering +
                  featureDataKey.prospecting_hours_other_period) *
                  10
              ) / 10
            }}
            heure(s)
          </div>
          <div class="KeyDataLabel">
            enregistrées sur la période Atlas 2019-2024
          </div>
        </div>
        <div class="Split main"></div>
        <h2 class="FeatureDashboardTitle margin">
          Points EPOC ODF ({{ featureEpocList.length }})
        </h2>
        <div
          v-for="(epoc, index) in featureEpocList"
          :key="index"
          class="DashboardSubData"
        >
          <img class="DashboardSubDataIcon" src="/location.svg" />
          <span
            class="MainTextStyle pointer"
            @click="updateClickedEpocItem(epoc)"
            >{{ epoc.properties.id_ff }}</span
          >
        </div>
        <span v-if="featureEpocList.length === 0" class="MainTextStyle"
          >Aucun point EPOC à afficher dans cette maille</span
        >
      </div>
    </div>
    <!-- MUNICIPALITIES DASHBOARD -->
    <div v-if="seeMoreMunicipalitiesIsClicked" class="SpecificSubDashboard">
      <div class="FeatureComeBack" @click="deleteSeeMoreMunicipalities">
        <img class="FeatureComeBackIcon" src="/previous.svg" />
        <span class="FeatureComeBackLabel">{{
          featureProperties.area_name
        }}</span>
      </div>
      <div class="FeatureDashboardHeader">
        <h1 class="FeatureDashboardTitle">
          Communes ({{ featureMunicipalitiesList.length }})
        </h1>
      </div>
      <div class="FeatureDashboardContent">
        <div class="Split main"></div>
        <span
          v-for="(municipality, index) in featureMunicipalitiesList"
          :key="index"
          class="DashboardSubData MainTextStyle"
        >
          {{ municipality.area_name }}
        </span>
      </div>
    </div>
    <!-- SPECIES DASHBOARD -->
    <div v-if="clickedSpecies" class="SpecificSubDashboard">
      <div class="FeatureComeBack" @click="deleteClickedSpecies">
        <img class="FeatureComeBackIcon" src="/previous.svg" />
        <span class="FeatureComeBackLabel">{{
          featureProperties.area_name
        }}</span>
      </div>
      <div class="FeatureDashboardHeader">
        <h1 class="FeatureDashboardTitle">
          {{ clickedSpecies[`common_name_${lang}`] }}
        </h1>
      </div>
      <div class="FeatureDashboardContent">
        <div class="Split main"></div>
        <div class="DashboardSubData">
          <img class="DashboardSubDataIcon" src="/burger.svg" />
          <span class="MainTextStyle"
            >{{ clickedSpecies.all_period.new_count }} donnée(s) sur la période
            Atlas 2019-2024
          </span>
        </div>
        <div class="DashboardSubData">
          <img class="DashboardSubDataIcon" src="/prospecting.svg" />
          <span class="MainTextStyle"
            >Espèce observée pour la dernière fois en
            {{ clickedSpecies.all_period.last_obs }}</span
          >
        </div>
        <div class="DashboardSubData">
          <img class="DashboardSubDataIcon" src="/book.svg" />
          <span
            v-if="clickedSpecies.all_period.old_count > 0"
            class="MainTextStyle"
            >Espèce observée avant 2019</span
          >
          <span v-else class="MainTextStyle"
            >Espèce non observée avant 2019</span
          >
        </div>
      </div>
    </div>
    <!-- EPOC DASHBOARD -->
    <div v-if="clickedEpocItem" class="SpecificSubDashboard">
      <div class="FeatureComeBack" @click="deleteClickedEpocItem">
        <img class="FeatureComeBackIcon" src="/previous.svg" />
        <span class="FeatureComeBackLabel">{{
          featureProperties.area_name
        }}</span>
      </div>
      <epoc-dashboard-control
        v-if="clickedEpocItem"
        :clicked-epoc-point="clickedEpocItem"
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
    menuItems: ['Tableau de bord', 'Espèces', 'Prospection'],
    selectedMenuItem: 'Tableau de bord',
    speciesStatusList: [
      { label: 'Toutes', value: 'all_period' },
      { label: 'Espèces nicheuses', value: 'breeding' },
      { label: 'Espèces hivernantes', value: 'wintering' },
    ],
    selectedSpeciesStatus: { label: 'Toutes', value: 'all_period' },
  }),
  computed: {
    filteredSpecies() {
      if (this.search.length > 0) {
        return this.featureTaxaList[this.selectedSpeciesStatus.value].filter(
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
      } else {
        return this.featureTaxaList[this.selectedSpeciesStatus.value]
      }
    },
  },
  watch: {
    clickedFeature(newVal) {
      this.clickedSpecies = null
      this.clickedEpocItem = null
      this.seeMoreMunicipalitiesIsClicked = false
      this.selectedMenuItem = 'Tableau de bord'
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
          const margin = { top: 10, right: 0, bottom: 30, left: 40 }
          const barPlotWidth =
            parseFloat(d3.select('.TimeDistributionBarPlot').style('width')) -
            margin.left -
            margin.right
          const barPlotHeight =
            parseFloat(d3.select('.TimeDistributionBarPlot').style('height')) -
            margin.top -
            margin.bottom
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
          d3.select('.yAxis')
            .call(d3.axisLeft(y))
            .selectAll('text')
            .attr(
              'style',
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 300; font-size: 11px; line-height: 12px; color: #000;"
            )
          d3.select('.BarPlotSvg').selectAll('path').style('opacity', 0)
          d3.select('.BarPlotSvg').selectAll('line').style('opacity', 0)
        })
        .catch((error) => {
          console.log(error)
        })
    },
  },
  mounted() {
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
        const margin = { top: 10, right: 0, bottom: 30, left: 40 }
        const barPlotWidth =
          parseFloat(d3.select('.TimeDistributionBarPlot').style('width')) -
          margin.left -
          margin.right
        const barPlotHeight =
          parseFloat(d3.select('.TimeDistributionBarPlot').style('height')) -
          margin.top -
          margin.bottom
        // Get bar plot svg and set size
        const barPlotSvg = d3
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
  },
}
</script>

<style scoped>
/* GLOBAL */

.FeatureDashboardControl {
  background: #fcfcfc;
  width: 506px;
  max-height: calc(100vh - 156px);
  padding: 16px 0 16px 16px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
}

.SpecificSubDashboard {
  max-height: calc(100vh - 186px);
  display: flex;
  flex-direction: column;
}

.MainTextStyle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.FeatureDashboardHeader {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.FeatureDashboardHeaderText {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.FeatureDashboardTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  display: flex;
  align-items: center;
}

.FeatureDashboardLastUpdate {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: rgba(38, 38, 38, 0.6);
}

.FeatureDashboardDownloadButton {
  width: 40px;
  height: 40px;
  margin-right: 16px;
  border: 2px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
}

.FeatureDashboardDownloadButtonIcon {
  width: 16px;
  margin: auto;
}

menu,
.SpeciesStatusMenu {
  margin-bottom: 16px;
  display: flex;
}

.MenuItem {
  padding: 10px 20px;
  margin-right: 6px;
  border-radius: 8px;
  cursor: pointer;
  white-space: nowrap;
}

.MenuItem.selected {
  background: rgba(57, 118, 90, 0.1);
  font-weight: bold;
  color: #39765a;
}

.FeatureDashboardContent {
  padding-right: 16px;
  overflow-y: auto;
  scrollbar-width: thin;
}

.Split {
  width: 100%;
  height: 0;
  border: 1px solid rgba(57, 118, 90, 0.1);
}

.Split.main {
  margin-bottom: 16px;
}

.FeatureComeBack {
  margin-bottom: 10px;
  display: flex;
  cursor: pointer;
}

.FeatureComeBackIcon {
  width: 12px;
  margin-right: 10px;
}

.FeatureComeBackLabel {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #262626;
}

.SeeMoreData {
  margin-right: 10px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 12px;
  line-height: 18px;
  color: #39765a;
  cursor: pointer;
}

.SeeMoreDataChevron {
  height: 7px;
}

.KeyDataContent {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.KeyDataValue {
  margin-right: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 24px;
  line-height: 36px;
  color: #39765a;
  white-space: nowrap;
}

.KeyDataLabel {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: rgba(38, 38, 38, 0.6);
}

.DashboardSubDataWrapper {
  margin-bottom: 16px;
}

.DashboardSubData {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
}

.DashboardSubDataIcon {
  width: 24px;
  margin-right: 20px;
}

.margin {
  margin-bottom: 10px;
}

.pointer {
  cursor: pointer;
}

/* SPECIFIC */

.TimeDistributionBarPlot {
  width: 100%;
  height: 300px;
}

.AutocompleteWrapper {
  position: relative;
  background: rgba(38, 38, 38, 0.03);
  width: 100%;
  margin-bottom: 16px;
  border: 1px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
}

.AutocompleteWrapper input {
  width: 100%;
  height: 42px;
  border: none;
  outline: none;
  box-sizing: border-box;
  border-radius: 8px;
  padding-left: 4%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.AutocompleteAdvanced {
  position: absolute;
  top: 0;
  right: 0;
  height: 42px;
  border-radius: 8px;
  padding: 0 6px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.CloseIconBox {
  width: 16px;
  height: 16px;
  display: flex;
}

.CloseIcon {
  width: 100%;
  margin: auto;
  cursor: pointer;
}

.SearchIconBox {
  background: #eece25;
  width: 30px;
  height: 30px;
  margin-left: 10px;
  border-radius: 4px;
  display: flex;
}

.SearchIcon {
  height: 16px;
  margin: auto;
}

.SpeciesStatusMenuItem {
  padding: 5px 12px;
  margin-right: 6px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 32px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  text-decoration: none;
  font-size: 12px;
  line-height: 18px;
  color: #000;
  white-space: nowrap;
}

.SpeciesStatusMenuItem.selected {
  background: rgba(238, 206, 37, 0.2);
  border: 2px solid #eece25;
}

.SpeciesTable {
  display: flex;
  flex-direction: column;
}

.SpeciesTableNumber {
  font-weight: 600;
}

.SpeciesTableLine {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SpeciesTableColumnsContent {
  display: flex;
}

.SpeciesTableColumn {
  width: 100px;
  height: 21px;
  font-weight: 500;
  display: flex;
  justify-content: center;
}

.SpeciesTableColumnCheck {
  width: 15px;
}

.Split.speciesTable {
  margin: 6px 0;
}

.SpeciesDashboard {
  max-height: calc(100vh - 186px);
  padding-right: 16px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}
</style>
