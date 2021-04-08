<template>
  <section class="FeatureDashboardControl">
    <div class="FeatureDashboardHeader">
      <div class="FeatureDashboardHeaderText">
        <h1 class="FeatureDashboardTitle">{{ featureProperties.area_name }}</h1>
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
        class="MenuItem"
        :class="[item === selectedMenuItem ? 'selected' : '']"
        @click="updateSelectedMenuItem(item)"
      >
        {{ item }}
      </span>
    </menu>
    <div
      v-show="selectedMenuItem === 'Tableau de bord'"
      class="FeatureDashboardContent"
    >
      <div class="MainSplit"></div>
      <h2 class="FeatureDashboardTitle sub">Indice de complétude</h2>
      <div class="KnowledgeLevelContent">
        <div class="KnowledgeLevelData">
          {{ $toPercent(featureProperties.all_period.percent_knowledge) }} %
        </div>
        <div class="KnowledgeLevelLabel">
          des espèces de référence ont été signalées<br />
          sur la période Atlas 2019-2024
        </div>
      </div>
      <div class="MainSplit"></div>
      <h2 class="FeatureDashboardTitle sub">
        Répartition temporelle des données ({{
          $thousandDelimiter(featureDataKey.data_count)
        }})
      </h2>
      HISTOGRAMME À FAIRE<br /><br />
      <div class="MainSplit"></div>
      <div class="FeatureDashboardHeader sub">
        <h2 class="FeatureDashboardTitle">Communes (???)</h2>
        <div>
          <span class="SeeMoreData">Voir toutes les communes</span>
          <img class="SeeMoreDataChevron" src="/chevron-right-green.svg" />
        </div>
      </div>
      MANQUE L'API<br /><br />
      <nuxt-link to="#" class="PrimaryButton" style="width: 100%"
        >Contacter le coordinateur local départemental</nuxt-link
      >
    </div>
    <div
      v-show="selectedMenuItem === 'Espèces'"
      class="FeatureDashboardContent"
    >
      <div class="MainSplit"></div>
      <div class="SpeciesTable">
        <div class="SpeciesTableLine">
          <span class="SpeciesTableNumber"
            >{{ featureDataKey.taxa_count_all_period }} espèces</span
          >
          <div class="SpeciesTableColumnsContent">
            <span class="SpeciesTableColumn">Avant 2019</span
            ><span class="SpeciesTableColumn">Après 2019</span>
          </div>
        </div>
        <div v-for="taxon in featureTaxaList" :key="taxon.cd_nom">
          <div class="SpeciesTableSplit"></div>
          <div class="SpeciesTableLine">
            <span>{{ taxon.common_name }}</span>
            <div class="SpeciesTableColumnsContent">
              <div class="SpeciesTableColumn">
                <img
                  v-show="taxon.all_period.old_count > 0"
                  class="SpeciesTableColumnCheck"
                  src="/check.svg"
                />
              </div>
              <div class="SpeciesTableColumn">
                <img
                  v-show="taxon.all_period.new_count > 0"
                  class="SpeciesTableColumnCheck"
                  src="/check.svg"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
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
    featureTaxaList: [],
    menuItems: ['Tableau de bord', 'Espèces', 'Prospection'],
    selectedMenuItem: 'Tableau de bord',
  }),
  watch: {
    clickedFeature(newVal) {
      this.featureID = newVal.id
      console.log(this.featureID)
      this.featureProperties = newVal.properties
      console.log(this.featureProperties)
      this.$router.push({
        path: '/prospecting',
        query: { area: `${this.featureProperties.area_code}`, type: 'M10' },
      })
      this.$axios
        .$get(`/api/v1/area/general_stats/${this.featureID}`)
        .then((data) => {
          console.log(data)
          this.featureDataKey = data
        })
        .catch((error) => {
          console.log(error)
        })
      this.$axios
        .$get(`/api/v1/area/taxa_list/${this.featureID}`)
        .then((data) => {
          console.log(data)
          this.featureTaxaList = data
        })
        .catch((error) => {
          console.log(error)
        })
    },
  },
  mounted() {
    this.featureID = this.clickedFeature.id
    console.log(this.featureID)
    this.featureProperties = this.clickedFeature.properties
    console.log(this.featureProperties)
    this.$router.push({
      path: '/prospecting',
      query: { area: `${this.featureProperties.area_code}`, type: 'M10' },
    })
    this.$axios
      .$get(`/api/v1/area/general_stats/${this.featureID}`)
      .then((data) => {
        console.log(data)
        this.featureDataKey = data
      })
      .catch((error) => {
        console.log(error)
      })
    this.$axios
      .$get(`/api/v1/area/taxa_list/${this.featureID}`)
      .then((data) => {
        console.log(data)
        this.featureTaxaList = data
      })
      .catch((error) => {
        console.log(error)
      })
  },
  methods: {
    updateSelectedMenuItem(item) {
      this.selectedMenuItem = item
    },
  },
}
</script>

<style scoped>
.FeatureDashboardControl {
  background: #fcfcfc;
  width: 506px;
  max-height: calc(100vh - 156px);
  padding: 16px 0 16px 16px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}

.FeatureDashboardHeader {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.FeatureDashboardHeader.sub {
  margin-bottom: 10px;
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

.FeatureDashboardTitle.sub {
  margin-bottom: 10px;
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

menu {
  margin-bottom: 16px;
  display: flex;
  justify-content: flex-start;
}

.MenuItem {
  border-radius: 8px;
  padding: 10px 20px;
  margin-right: 6px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  text-decoration: none;
  font-size: 14px;
  line-height: 21px;
  color: #000;
  white-space: nowrap;
}

.MenuItem.selected {
  background: rgba(57, 118, 90, 0.1);
  font-weight: bold;
  color: #39765a;
}

.MainSplit {
  width: 100%;
  height: 0;
  margin-bottom: 16px;
  border: 1px solid rgba(57, 118, 90, 0.1);
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

.SeeMoreDataIcon {
  height: 7px;
}

.FeatureDashboardContent {
  padding-right: 16px;
  overflow-y: auto;
}

.KnowledgeLevelContent {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.KnowledgeLevelData {
  margin-right: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 24px;
  line-height: 36px;
  color: #39765a;
  white-space: nowrap;
}

.KnowledgeLevelLabel {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: rgba(38, 38, 38, 0.6);
}

.SpeciesTable {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
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

.SpeciesTableSplit {
  width: 100%;
  height: 0;
  margin: 6px 0;
  border: 1px solid rgba(57, 118, 90, 0.1);
}
</style>
