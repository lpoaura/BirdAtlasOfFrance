<template>
  <section class="KeyDataSection">
    <h2 class="KeyDataTitle">L'Atlas en quelques chiffres...</h2>
    <div class="KeyDataContent">
      <div class="KeyDataCard">
        <div class="KeyDataBlock">
          <img class="KeyDataBlockIcon" src="/home/species-number.svg" />
          <div class="KeyDataBlockContent">
            <span class="KeyDataBlockData">
              {{ $thousandDelimiter(keyData.count_taxa.all_period) }}
            </span>
            <span class="KeyDataBlockText" style="text-align: center">
              espèces recensées<br />sur la période 2019 - 2024
            </span>
          </div>
        </div>
        <div class="KeyDataBlock">
          <div class="KeyDataBlockDetails" style="height: 47%">
            <img
              class="KeyDataBlockDetailsIcon"
              src="/home/breeding-species-number.svg"
            />
            <div class="KeyDataBlockDetailsContent">
              <span class="KeyDataBlockDetailsData">
                {{ $thousandDelimiter(keyData.count_taxa.breeding) }}
              </span>
              <span class="KeyDataBlockText">espèces nicheuses</span>
            </div>
          </div>
          <div class="KeyDataBlockDetails" style="height: 47%">
            <img
              class="KeyDataBlockDetailsIcon"
              src="/home/winter-species-number.svg"
            />
            <div class="KeyDataBlockDetailsContent">
              <span class="KeyDataBlockDetailsData">
                {{ $thousandDelimiter(keyData.count_taxa.wintering) }}
              </span>
              <span class="KeyDataBlockText">espèces hivernantes</span>
            </div>
          </div>
        </div>
      </div>
      <div class="KeyDataCard">
        <div class="KeyDataBlock">
          <div class="KeyDataBlockIcon"><svg class="PieChartSvg"></svg></div>
          <div class="KeyDataBlockContent">
            <span class="KeyDataBlockData">
              {{ $thousandDelimiter(totalProspectingHours) }}
            </span>
            <span class="KeyDataBlockText" style="text-align: center">
              heures de prospection<br />sur la période 2019 - 2024
            </span>
          </div>
        </div>
        <div class="KeyDataBlock">
          <div class="KeyDataBlockDetails" style="height: 30%">
            <div
              class="KeyDataBlockDetailsDot"
              :style="{ background: pieChartColors.breeding }"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <span class="KeyDataBlockText" style="font-weight: 500">
                {{ pieChartLabels.breeding }}
              </span>
              <span class="KeyDataBlockText">
                {{
                  $toPercent(
                    keyData.prospecting_hours.breeding / totalProspectingHours
                  )
                }}% |
                {{ $thousandDelimiter(keyData.prospecting_hours.breeding) }}
                heures
              </span>
            </div>
          </div>
          <div class="KeyDataBlockDetails" style="height: 30%">
            <div
              class="KeyDataBlockDetailsDot"
              :style="{ background: pieChartColors.wintering }"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <span class="KeyDataBlockText" style="font-weight: 500">
                {{ pieChartLabels.wintering }}
              </span>
              <span class="KeyDataBlockText">
                {{
                  $toPercent(
                    keyData.prospecting_hours.wintering / totalProspectingHours
                  )
                }}% |
                {{ $thousandDelimiter(keyData.prospecting_hours.wintering) }}
                heures
              </span>
            </div>
          </div>
          <div class="KeyDataBlockDetails" style="height: 30%">
            <div
              class="KeyDataBlockDetailsDot"
              :style="{ background: pieChartColors.other_period }"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <span class="KeyDataBlockText" style="font-weight: 500">
                {{ pieChartLabels.other_period }}
              </span>
              <span class="KeyDataBlockText">
                {{
                  $toPercent(
                    keyData.prospecting_hours.other_period /
                      totalProspectingHours
                  )
                }}% |
                {{ $thousandDelimiter(keyData.prospecting_hours.other_period) }}
                heures
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
const d3 = require('d3')

export default {
  data: () => ({
    keyData: {
      prospecting_hours: {
        other_period: 0,
        breeding: 0,
        wintering: 0,
      },
      count_taxa: {
        all_period: 0,
        breeding: 0,
        wintering: 0,
      },
    },
    pieChartLabels: {
      breeding: 'Période de reproduction',
      wintering: "Période d'hivernage",
      other_period: 'Périodes intermédiaires',
    },
    pieChartColors: {
      breeding: '#2A9D8F',
      wintering: '#2673AB',
      other_period: '#264653',
    },
  }),
  computed: {
    totalProspectingHours() {
      return (
        this.keyData.prospecting_hours.other_period +
        this.keyData.prospecting_hours.breeding +
        this.keyData.prospecting_hours.wintering
      )
    },
  },
  mounted() {
    this.$axios
      .$get('/api/v1/period_stats')
      .then((data) => {
        this.keyData = data
        // Get pie chart size
        const pieChartHeight = parseFloat(
          d3.select('.KeyDataBlockIcon').style('height')
        )
        // Get pie chart svg and set size
        const pieChartSvg = d3
          .select('.PieChartSvg')
          .attr('width', pieChartHeight)
          .attr('height', pieChartHeight)
        // Define pie chart colors
        const color = d3.scaleOrdinal(Object.values(this.pieChartColors))
        // Define pie chart shape
        const arcPath = d3
          .arc()
          .outerRadius(pieChartHeight / 2)
          .innerRadius(pieChartHeight / 5)
        // Define data
        const formattedData = [
          {
            hours: this.keyData.prospecting_hours.breeding,
            label: this.pieChartLabels.breeding,
          },
          {
            hours: this.keyData.prospecting_hours.wintering,
            label: this.pieChartLabels.wintering,
          },
          {
            hours: this.keyData.prospecting_hours.other_period,
            label: this.pieChartLabels.other_period,
          },
        ]
        const pieChartData = d3
          .pie()
          .value(function (d) {
            return d.hours
          })
          .sort(null)(formattedData)
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
          .attr('d', arcPath)
          .attr('fill', function (d) {
            return color(d.data.label)
          })
      })
      .catch((error) => {
        console.log(error)
      })
  },
}
</script>

<style scoped>
.KeyDataSection {
  width: 100%;

  /* À MODIFIER LORSQU'IL Y AURA LES AUTRES BLOCS */
  height: 470px;

  /* À modifier en : padding: 3.5% 5%; */
  padding: 0 5% 3.5% 5%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.KeyDataTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
}

.KeyDataContent {
  display: flex;
  justify-content: space-between;
}

.KeyDataCard {
  background: rgba(57, 118, 90, 0.1);
  width: 49%;
  height: 354px;
  border-radius: 12px;

  /* padding: 1.8% 2.5%; */
  padding: 1.6vw 1.6vw;
  display: flex;
  justify-content: space-between;
}

.KeyDataBlock {
  width: 49%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
}

.KeyDataBlockIcon {
  height: 188px;
  margin-top: 16px;
}

.KeyDataBlockContent {
  height: 92px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.KeyDataBlockData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
}

.KeyDataBlockText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
}

.KeyDataBlockDetails {
  background: rgba(57, 118, 90, 0.1);
  width: 100%;
  border-radius: 8px;
  padding-left: 10%;
  padding-right: 2%;
  display: flex;
  align-items: center;
}

.KeyDataBlockDetailsIcon {
  height: 52px;
  margin-right: 8%;
}

.KeyDataBlockDetailsDot {
  min-width: 12px;
  max-width: 12px;
  min-height: 12px;
  max-height: 12px;
  border-radius: 50%;
  margin-right: 8%;
}

.KeyDataBlockDetailsContent {
  display: flex;
  flex-direction: column;
}

.KeyDataBlockDetailsData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 24px;
  line-height: 36px;
}
</style>
