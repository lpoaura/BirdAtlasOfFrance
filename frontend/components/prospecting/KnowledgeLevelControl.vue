<template>
  <section class="MapControl">
    <header class="MapControlInfo">
      <div class="MapControlInfoTitles">
        <div class="KnowledgeLevel">
          <h4 class="fw-bold">Indice de complétude</h4>
          <div class="HelperWrapper">
            <img class="HelpIcon" src="/help.svg" />
            <div class="HelperTip"></div>
            <h5 class="HelperContent white02 nowrap">
              Rapport entre le nombre d'espèces<br />observées sur la période
              2019-2024<br />et le nombre d’espèces observées<br />sur les
              périodes précédentes.
            </h5>
          </div>
        </div>
        <h5 v-if="currentTerritory.area_code" class="fw-500 bottom-margin-24">
          {{ currentTerritory.area_name }}
        </h5>
        <h5 v-else class="fw-500">
          Placez le centre de la carte sur un territoire français pour
          visualiser l'indice de complétude.
        </h5>
      </div>
      <img
        class="MobileMapControlCloseIcon"
        src="/cross.svg"
        @click="closeMobileMapControl"
      />
    </header>
    <div
      v-show="currentTerritory.area_code && !noAvailableData"
      class="KnowledgeLevelPieChartWrapper display-flex"
    >
      <div class="KnowledgeLevelPieChart">
        <svg class="PieChartSvg"></svg>
        <h3 class="KnowledgeLevelGlobalData black02 fw-bold">
          {{ globalKnowledgeLevel[selectedSeason.value].average }}%
        </h3>
      </div>
      <div class="PieChartLegend">
        <div
          v-for="(item, index) in globalKnowledgeLevel[selectedSeason.value]
            .data"
          :key="index"
          class="PieChartLegendItem"
        >
          <span class="black02 fw-500">
            <i
              :style="{
                background: selectedSeason.featuresColors[index + 1],
              }"
            ></i
            >{{ item.label }}
          </span>
          <span class="black02">
            {{ $toPercent(item.value / totalAreaCount) || 0 }} %
          </span>
        </div>
      </div>
    </div>
    <span v-show="currentTerritory.area_code && noAvailableData" class="fw-500">
      Les données de ce territoire ne sont pas encore disponibles.
    </span>
  </section>
</template>

<script>
const d3 = require('d3')

export default {
  props: {
    currentTerritory: {
      type: Object,
      required: true,
    },
    selectedSeason: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    globalKnowledgeLevel: {
      all_period: {
        average: 0,
        data: [
          {
            value: 0,
            label: '0-25%',
          },
          {
            value: 0,
            label: '25-50%',
          },
          {
            value: 0,
            label: '50-75%',
          },
          {
            value: 0,
            label: '75-100%',
          },
          {
            value: 0,
            label: '100%+',
          },
        ],
      },
      breeding: {
        average: 0,
        data: [
          {
            value: 0,
            label: '0-25%',
          },
          {
            value: 0,
            label: '25-50%',
          },
          {
            value: 0,
            label: '50-75%',
          },
          {
            value: 0,
            label: '75-100%',
          },
          {
            value: 0,
            label: '100%+',
          },
        ],
      },
      wintering: {
        average: 0,
        data: [
          {
            value: 0,
            label: '0-25%',
          },
          {
            value: 0,
            label: '25-50%',
          },
          {
            value: 0,
            label: '50-75%',
          },
          {
            value: 0,
            label: '75-100%',
          },
          {
            value: 0,
            label: '100%+',
          },
        ],
      },
    },
    noAvailableData: false,
    arcPath: {},
  }),
  computed: {
    totalAreaCount() {
      let totalCount = 0
      this.globalKnowledgeLevel[this.selectedSeason.value].data.forEach(
        (item) => {
          totalCount += item.value
        }
      )
      return totalCount
    },
  },
  watch: {
    currentTerritory(newVal) {
      if (newVal.area_code) {
        this.updateGlobalKnowledgeLevel()
      }
    },
    selectedSeason(newVal) {
      // Le watch permet de mettre à jour le graphe quand on change la saison sur la répartition de l'espèce
      // Define pie chart colors
      const color = d3.scaleOrdinal(newVal.featuresColors.slice(1))
      // Define data
      const pieChartData = d3
        .pie()
        .value(function (d) {
          return d.value
        })
        .sort(null)(this.globalKnowledgeLevel[this.selectedSeason.value].data)
      // Create pie chart
      const pieChartSvg = d3
        .select(this.$el)
        .select('.PieChartSvg')
        .selectAll('path')
        .data(pieChartData)
      pieChartSvg.exit().remove()
      pieChartSvg
        .enter()
        .append('path')
        .merge(pieChartSvg)
        .transition()
        .duration(150)
        .attr('class', 'arc')
        .attr('d', this.arcPath)
        .attr('fill', function (d) {
          return color(d.data.label)
        })
    },
  },
  mounted() {
    // Get pie chart size
    const pieChartHeight = parseFloat(
      d3.select(this.$el).select('.KnowledgeLevelPieChart').style('height')
    )
    // Get pie chart svg and set size
    const pieChartSvg = d3
      .select(this.$el)
      .select('.PieChartSvg')
      .attr('width', pieChartHeight)
      .attr('height', pieChartHeight)
    // Define pie chart colors
    const color = d3.scaleOrdinal(this.selectedSeason.featuresColors.slice(1))
    // Define pie chart shape
    this.arcPath = d3
      .arc()
      .outerRadius(pieChartHeight / 2)
      .innerRadius(pieChartHeight / 3.2)
    // Define default data (0)
    const pieChartData = d3
      .pie()
      .value(function (d) {
        return d.value
      })
      .sort(null)(this.globalKnowledgeLevel.all_period.data)
    // Create pie chart
    pieChartSvg
      .append('g')
      .attr(
        'transform',
        `translate(${pieChartHeight / 2}, ${pieChartHeight / 2})`
      )
      .selectAll('path')
      .data(pieChartData)
      .join('path')
      .attr('class', 'arc')
      .attr('d', this.arcPath)
      .attr('fill', function (d) {
        return color(d.data.label)
      })
    // Nécessaire pour la version mobile
    if (this.currentTerritory.area_code) {
      this.updateGlobalKnowledgeLevel()
    }
  },
  methods: {
    updateGlobalKnowledgeLevel() {
      const periods = ['allperiod', 'breeding', 'wintering']
      Promise.all(
        periods.map((i) => {
          const params = {
            id_area: this.currentTerritory.id,
            period: i,
          }
          return this.$axios.$get(`/api/v1/knowledge_level`, { params })
        })
      )
        .then((responses) => {
          if (responses[0].average !== 0) {
            this.noAvailableData = false
            const seasons = ['all_period', 'breeding', 'wintering']
            responses.forEach((item, index) => {
              this.globalKnowledgeLevel[seasons[index]].average =
                this.$toPercent(item.average)
              const dataArray = Object.values(item)
              dataArray.slice(1, dataArray.length).forEach((i, j) => {
                this.globalKnowledgeLevel[seasons[index]].data[j].value = i
              })
            })
            // Define pie chart colors
            const color = d3.scaleOrdinal(
              this.selectedSeason.featuresColors.slice(1)
            )
            // Update data
            const pieChartData = d3
              .pie()
              .value(function (d) {
                return d.value
              })
              .sort(null)(
              this.globalKnowledgeLevel[this.selectedSeason.value].data
            )
            // Create pie chart
            const pieChartSvg = d3
              .select(this.$el)
              .select('.PieChartSvg')
              .selectAll('path')
              .data(pieChartData)
            pieChartSvg.exit().remove()
            pieChartSvg
              .enter()
              .append('path')
              .merge(pieChartSvg)
              .transition()
              .duration(150)
              .attr('class', 'arc')
              .attr('d', this.arcPath)
              .attr('fill', function (d) {
                return color(d.data.label)
              })
          } else {
            this.noAvailableData = true
          }
        })
        .catch((errors) => {
          console.debug(errors)
        })
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
  width: 420px;
  padding: 16px;
}

.MapControlInfo {
  margin-bottom: 0;
  margin-right: 0;
}

.KnowledgeLevel {
  display: flex;
  align-items: center;
}

.HelpIcon {
  height: 20px;
  margin-left: 10px;
  cursor: pointer;
}

.HelperTip {
  left: 12px;
  top: 32px;
}

.HelpIcon:hover ~ .HelperTip {
  display: block;
}

.HelperContent {
  top: 40px;
  left: -156px;
}

.HelpIcon:hover ~ .HelperContent {
  display: flex;
}

.KnowledgeLevelPieChart {
  position: relative;
  flex: 1;
  height: 166px;
  display: flex;
  justify-content: center;
}

.KnowledgeLevelGlobalData {
  position: absolute;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.PieChartLegend {
  flex: 0.8;
  display: flex;
  flex-direction: column;
}

.PieChartLegendItem {
  margin-bottom: 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.PieChartLegendItem:last-child {
  margin-bottom: 0;
}

.PieChartLegendItem i {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  float: left;
  margin-right: 16px;
}

/********** RESPONSIVE **********/

@media screen and (width <= 680px) {
  h3.KnowledgeLevelGlobalData {
    font-size: 24px;
    line-height: 36px;
  }
}

@media screen and (width <= 400px) {
  .KnowledgeLevelPieChartWrapper {
    flex-direction: column;
    align-items: center;
  }

  .KnowledgeLevelPieChart {
    margin-bottom: 24px;
  }

  .PieChartLegend {
    width: 180px;
  }
}
</style>
