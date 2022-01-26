<template>
  <section class="Section">
    <h2 class="fw-bold bottom-margin-40">L'Atlas en quelques chiffres</h2>
    <div class="KeyDataContent">
      <div class="KeyDataCard">
        <div class="KeyDataColumn-1">
          <img class="Column-1-Icon" src="/home/species-number.svg" />
          <h2 class="black02 fw-bold">
            {{
              keyData.count_taxa
                ? $thousandDelimiter(keyData.count_taxa.all_period)
                : 0
            }}
          </h2>
          <span class="black02 text-center">
            espèces recensées<br />sur la période 2019 - 2024
          </span>
        </div>
        <div class="KeyDataColumn-2">
          <div class="Column-2-Subcard">
            <img
              class="Column-2-Icon"
              src="/home/breeding-species-number.svg"
            />
            <div class="Column-2-LabelWrapper">
              <h3 class="black02 fw-bold">
                {{
                  keyData.count_taxa
                    ? $thousandDelimiter(keyData.count_taxa.breeding)
                    : 0
                }}
              </h3>
              <span class="black02">espèces nicheuses</span>
            </div>
          </div>
          <div class="Column-2-Subcard">
            <img class="Column-2-Icon" src="/home/winter-species-number.svg" />
            <div class="Column-2-LabelWrapper">
              <h3 class="black02 fw-bold">
                {{
                  keyData.count_taxa
                    ? $thousandDelimiter(keyData.count_taxa.wintering)
                    : 0
                }}
              </h3>
              <span class="black02">espèces hivernantes</span>
            </div>
          </div>
        </div>
      </div>
      <div class="KeyDataCard">
        <div class="KeyDataColumn-1">
          <div class="Column-1-Icon"><svg class="PieChartSvg"></svg></div>
          <h2 class="black02 fw-bold">
            {{
              keyData.prospecting_hours
                ? $thousandDelimiter(totalProspectingHours)
                : 0
            }}
          </h2>
          <span class="black02 text-center">
            heures de prospection<br />sur la période 2019 - 2024
          </span>
        </div>
        <div class="KeyDataColumn-2">
          <div
            v-for="(season, index) in ['breeding', 'wintering', 'other_period']"
            :key="index"
            class="Column-2-Subcard"
          >
            <div
              class="Column-2-Dot"
              :style="{ background: pieChartColors[season] }"
            ></div>
            <div class="Column-2-LabelWrapper">
              <span class="black02 fw-500">
                {{ pieChartLabels[season] }}
              </span>
              <span class="black02 flex">
                <div class="right-margin-16">
                  {{
                    keyData.prospecting_hours
                      ? $toPercent(
                          keyData.prospecting_hours[season] /
                            totalProspectingHours
                        )
                      : 0
                  }}%
                </div>
                <div class="right-margin-16">|</div>
                <div>
                  {{
                    keyData.prospecting_hours
                      ? $thousandDelimiter(keyData.prospecting_hours[season])
                      : 0
                  }}
                  heures
                </div>
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
    keyData: {},
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
          d3.select('.Column-1-Icon').style('height')
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
.KeyDataContent {
  display: flex;
  justify-content: space-between;
}

.KeyDataCard {
  background: #eef3ef;
  width: 49%;
  padding: 24px;
  border-radius: 12px;
  display: flex;
  justify-content: space-between;
}

.KeyDataColumn-1,
.KeyDataColumn-2 {
  width: 49%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.KeyDataColumn-1 {
  justify-content: center;
}

.KeyDataColumn-2 {
  justify-content: space-between;
}

.Column-1-Icon {
  height: 188px;
  margin-bottom: 24px;
}

.Column-2-Subcard {
  flex: 1;
  background: rgba(57, 118, 90, 0.1);
  width: 100%;
  padding: 12px 24px;
  margin-bottom: 16px;
  border-radius: 8px;
  display: flex;
  align-items: center;
}

.Column-2-Subcard:last-child {
  margin-bottom: 0;
}

.Column-2-Icon {
  height: 52px;
  margin-right: 16px;
}

.Column-2-Dot {
  min-width: 12px;
  max-width: 12px;
  min-height: 12px;
  max-height: 12px;
  border-radius: 50%;
  margin-right: 16px;
}

.Column-2-LabelWrapper {
  display: flex;
  flex-direction: column;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 1070px) {
  h2.bottom-margin-40 {
    margin-bottom: 24px !important;
  }

  .KeyDataContent {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .KeyDataCard {
    width: 100%;
    margin-bottom: 24px;
  }

  .KeyDataCard:last-child {
    margin-bottom: 0;
  }
}

@media screen and (max-width: 612px) {
  .KeyDataCard {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .KeyDataColumn-1 {
    width: 100%;
    margin-bottom: 16px;
  }

  .KeyDataColumn-2 {
    width: 100%;
    justify-content: flex-start;
  }

  .Column-2-Subcard {
    padding: 16px;
    justify-content: center;
  }
}
</style>
