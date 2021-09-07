<template>
  <section class="MapControl">
    <header class="MapControlHeader">
      <div class="MapControlHeaderTitles">
        <div class="KnowledgeLevel">
          <h4 class="fw-bold">Indice de complétude</h4>
          <div class="HelpWrapper">
            <img class="HelpIcon" src="/help.svg" />
            <div class="HelpVocabularyTip"></div>
            <h5 class="HelpVocabularyInfo white02">
              Rapport entre le nombre d'espèces observées sur la période
              2019-2024 et le nombre d’espèces observées sur les périodes
              précédentes.
            </h5>
          </div>
        </div>
        <h5 class="fw-500">France métropolitaine</h5>
      </div>
    </header>
    <div class="KnowledgeLevelPieChartWrapper">
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
                background: selectedSeason.featuresColors[index],
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
  </section>
</template>

<script>
const d3 = require('d3')

export default {
  props: {
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
    selectedSeason(newVal) {
      // Le watch permet de mettre à jour le graphe quand on change la saison sur la répartition de l'espèce
      // Define pie chart colors
      const color = d3.scaleOrdinal(newVal.featuresColors)
      // Define data
      const pieChartData = d3
        .pie()
        .value(function (d) {
          return d.value
        })
        .sort(null)(this.globalKnowledgeLevel[this.selectedSeason.value].data)
      // Create pie chart
      const pieChartSvg = d3
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
    this.$axios.$get('/api/v1/knowledge_level').then((data) => {
      // console.log(data)
      this.globalKnowledgeLevel.all_period.average = this.$toPercent(
        data.average
      )
      const dataArray = Object.values(data)
      dataArray.slice(1, dataArray.length).forEach((item, index) => {
        this.globalKnowledgeLevel.all_period.data[index].value = item
      })
      // Get pie chart size
      const pieChartHeight = parseFloat(
        d3.select('.KnowledgeLevelPieChart').style('height')
      )
      // Get pie chart svg and set size
      const pieChartSvg = d3
        .select('.PieChartSvg')
        .attr('width', pieChartHeight)
        .attr('height', pieChartHeight)
      // Define pie chart colors
      const color = d3.scaleOrdinal(this.selectedSeason.featuresColors)
      // Define pie chart shape
      this.arcPath = d3
        .arc()
        .outerRadius(pieChartHeight / 2)
        .innerRadius(pieChartHeight / 3.2)
      // Define data
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
    })
    this.$axios.$get('/api/v1/knowledge_level?period=breeding').then((data) => {
      // console.log(data)
      this.globalKnowledgeLevel.breeding.average = this.$toPercent(data.average)
      const dataArray = Object.values(data)
      dataArray.slice(1, dataArray.length).forEach((item, index) => {
        this.globalKnowledgeLevel.breeding.data[index].value = item
      })
    })
    this.$axios
      .$get('/api/v1/knowledge_level?period=wintering')
      .then((data) => {
        // console.log(data)
        this.globalKnowledgeLevel.wintering.average = this.$toPercent(
          data.average
        )
        const dataArray = Object.values(data)
        dataArray.slice(1, dataArray.length).forEach((item, index) => {
          this.globalKnowledgeLevel.wintering.data[index].value = item
        })
      })
  },
}
</script>

<style scoped>
.MapControl {
  width: 420px;
  padding: 16px;
}

.KnowledgeLevel {
  display: flex;
  align-items: center;
}

.HelpWrapper {
  position: relative;
  margin-left: 10px;
  display: flex;
}

.HelpIcon {
  height: 20px;
  cursor: pointer;
}

.HelpVocabularyTip {
  display: none;
  position: absolute;
  z-index: 6;
  background: #262626;
  width: 12px;
  height: 12px;
  left: 28px;
  top: 4px;
  transform: rotate(45deg);
}

.HelpIcon:hover ~ .HelpVocabularyTip {
  display: block;
}

.HelpVocabularyInfo {
  display: none;
  position: absolute;
  z-index: 6;
  top: -10px;
  left: 34px;
  background: #262626;
  width: 266px;
  padding: 10px;
  border-radius: 8px;
  filter: drop-shadow(0 0 16px rgba(0, 0, 0, 0.32));
}

.HelpIcon:hover ~ .HelpVocabularyInfo {
  display: block;
}

.KnowledgeLevelPieChartWrapper {
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
</style>
