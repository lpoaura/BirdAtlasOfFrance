<template>
  <section class="KnowledgeLevelControl">
    <div class="KnowledgeLevelHeader">
      <div class="KnowledgeLevelTitle">
        <span class="fw-bold">Indice de complétude</span>
        <div class="HelpWrapper">
          <img class="HelpIcon" src="/help.svg" />
          <div class="HelpVocabularyTip"></div>
          <div class="HelpVocabularyInfo">
            Rapport entre le nombre d'espèces observées sur la période 2019-2024
            et le nombre d’espèces observées sur les périodes précédentes.
          </div>
        </div>
      </div>
      <seasons-selector
        :selected-season="selectedSeason"
        @selectedSeason="updateSelectedSeason"
      />
    </div>
    <span class="KnowledgeLevelSubtitle">France métropolitaine</span>
    <div class="KnowledgeLevelPieChartContent">
      <div class="KnowledgeLevelPieChart">
        <svg class="PieChartSvg"></svg>
        <div class="KnowledgeLevelGlobalData">
          {{ globalKnowledgeLevel[selectedSeason.value].average }}%
        </div>
      </div>
      <div class="KnowledgeLevelPieChartLegend">
        <div
          v-for="(item, index) in globalKnowledgeLevel[selectedSeason.value]
            .data"
          :key="index"
          class="PieChartLegendItem"
        >
          <div class="PieChartLegendLabel">
            <i
              :style="{
                background: selectedSeason.featuresColors[index],
              }"
            ></i
            >{{ item.label }}
          </div>
          <span class="PieChartLegendData"
            >{{ $toPercent(item.value / totalAreaCount) || 0 }} %</span
          >
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import SeasonsSelector from '~/components/prospecting/SeasonsSelector.vue'
const d3 = require('d3')

export default {
  components: {
    'seasons-selector': SeasonsSelector,
  },
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
  methods: {
    updateSelectedSeason(season) {
      this.$emit('selectedSeason', season)
    },
  },
}
</script>

<style scoped>
.KnowledgeLevelControl {
  background: #fcfcfc;
  width: 420px;
  padding: 16px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}

.KnowledgeLevelHeader {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.KnowledgeLevelTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
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
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #fcfcfc;
}

.HelpIcon:hover ~ .HelpVocabularyInfo {
  display: block;
}

.KnowledgeLevelSubtitle {
  margin-bottom: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.KnowledgeLevelPieChartContent {
  display: flex;
}

.KnowledgeLevelPieChart {
  position: relative;
  flex: 1.4;
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
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 24px;
  line-height: 36px;
  color: #000;
}

.KnowledgeLevelPieChartLegend {
  flex: 1;
  height: 175px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.PieChartLegendItem {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.PieChartLegendLabel {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.PieChartLegendLabel i {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  float: left;
  margin-right: 10px;
  display: flex;
}

.PieChartLegendData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}
</style>
