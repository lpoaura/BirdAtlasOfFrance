<template>
  <section class="KnowledgeLevelControl">
    <div class="KnowledgeLevelHeader">
      <div class="KnowledgeLevelTitle">
        <span>Indice de complétude</span>
        <img class="HelpIcon" src="/help.svg" title="DÉFINITION" />
      </div>
      <seasons-selector
        :selected-season="selectedSeason"
        @selectedSeason="updateSelectedSeason"
      />
    </div>
    <div class="KnowledgeLevelSubtitle">France métropolitaine</div>
    <div class="KnowledgeLevelPieChartContent">
      <div class="KnowledgeLevelPieChart">
        <svg class="pieChartSvg"></svg>
        <div class="KnowledgeLevelGlobalData">?? %</div>
      </div>
      <div class="KnowledgeLevelPieChartLegend">
        <div
          v-for="(item, index) in knowledgeLevelData"
          :key="index"
          class="PieChartLegendItem"
        >
          <div class="PieChartLegendLabel">
            <i
              :style="{
                background:
                  selectedSeason.value === 'breeding'
                    ? breedingFeaturesColors[index]
                    : selectedSeason.value === 'wintering'
                    ? winteringFeaturesColors[index]
                    : allPeriodFeaturesColors[index],
              }"
            ></i
            >{{ item.label }}
          </div>
          <span class="PieChartLegendData"
            >{{ Math.round((item.data / totalAreaCount) * 100) }}%</span
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
    allPeriodFeaturesColors: {
      type: Array,
      required: true,
    },
    breedingFeaturesColors: {
      type: Array,
      required: true,
    },
    winteringFeaturesColors: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
    knowledgeLevelData: [
      {
        data: 0,
        label: '0-25%',
      },
      {
        data: 0,
        label: '25-50%',
      },
      {
        data: 0,
        label: '50-75%',
      },
      {
        data: 0,
        label: '75-100%',
      },
      {
        data: 0,
        label: '100%+',
      },
    ],
    arcPath: {},
  }),
  computed: {
    totalAreaCount() {
      let totalCount = 0
      this.knowledgeLevelData.forEach((item) => {
        totalCount += item.data
      })
      return totalCount
    },
  },
  mounted() {
    this.$axios.$get('/api/v1/knowledge_level').then((data) => {
      console.log(data)
      const dataArray = Object.values(data)
      dataArray.forEach((item, index) => {
        this.knowledgeLevelData[index].data = item
      })
      // Get pie chart size
      const pieChartHeight = parseFloat(
        d3.select('.KnowledgeLevelPieChart').style('height')
      )
      // Get pie chart svg and set size
      const pieChartSvg = d3
        .select('.pieChartSvg')
        .attr('width', pieChartHeight)
        .attr('height', pieChartHeight)
      // Define pie chart colors
      const color = d3.scaleOrdinal(
        this.selectedSeason.value === 'breeding'
          ? this.breedingFeaturesColors
          : this.selectedSeason.value === 'wintering'
          ? this.winteringFeaturesColors
          : this.allPeriodFeaturesColors
      )
      // Define pie chart shape
      this.arcPath = d3
        .arc()
        .outerRadius(pieChartHeight / 2)
        .innerRadius(pieChartHeight / 3.2)
      // Define data
      const pieChartData = d3.pie().value(function (d) {
        return d.data
      })(this.knowledgeLevelData)
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
  },
  methods: {
    updateSelectedSeason(season) {
      this.$emit('selectedSeason', season)
      // Define pie chart colors
      const color = d3.scaleOrdinal(
        season.value === 'breeding'
          ? this.breedingFeaturesColors
          : season.value === 'wintering'
          ? this.winteringFeaturesColors
          : this.allPeriodFeaturesColors
      )
      // Define data
      const pieChartData = d3.pie().value(function (d) {
        return d.data
      })(this.knowledgeLevelData)
      // Create pie chart
      const pieChartSvg = d3
        .select('.pieChartSvg')
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

.HelpIcon {
  height: 20px;
  margin-left: 10px;
  cursor: pointer;
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
