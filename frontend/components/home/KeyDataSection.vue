<!-- Créer un composant avec des props pour le pie chart -->
<template>
  <section class="KeyDataSection">
    <h2 class="KeyDataTitle">L'Atlas en quelques chiffres...</h2>
    <div class="KeyDataContent">
      <div class="KeyDataCard">
        <div class="KeyDataBlock">
          <img class="KeyDataBlockIcon" src="/home/species-number.svg" />
          <div class="KeyDataBlockContent">
            <div class="KeyDataBlockData">
              {{ keyData.count_taxa.all_period }}
            </div>
            <div class="KeyDataBlockText" style="text-align: center">
              espèces recensées<br />sur la période 2019 - 2023
            </div>
          </div>
        </div>
        <div class="KeyDataBlock">
          <div class="KeyDataBlockDetails">
            <img
              class="KeyDataBlockDetailsIcon"
              src="/home/breeding-species-number.svg"
            />
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockDetailsData">
                {{ keyData.count_taxa.breeding }}
              </div>
              <div class="KeyDataBlockText">espèces nicheuses</div>
            </div>
          </div>
          <div class="KeyDataBlockDetails">
            <img
              class="KeyDataBlockDetailsIcon"
              src="/home/winter-species-number.svg"
            />
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockDetailsData">
                {{ keyData.count_taxa.wintering }}
              </div>
              <div class="KeyDataBlockText">espèces hivernantes</div>
            </div>
          </div>
        </div>
      </div>
      <div class="KeyDataCard">
        <div class="KeyDataBlock">
          <div class="KeyDataBlockIcon"><svg class="pieChartSvg"></svg></div>
          <div class="KeyDataBlockContent">
            <div class="KeyDataBlockData">
              {{ keyData.prospecting_hours.all_period }}
            </div>
            <div class="KeyDataBlockText" style="text-align: center">
              heures de prospection<br />sur la période 2019 - 2023
            </div>
          </div>
        </div>
        <div class="KeyDataBlock">
          <div class="KeyDataBlockDetails">
            <div
              class="KeyDataBlockDetailsDot"
              :style="{ background: pieChartColors[0] }"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockText" style="font-weight: 500">
                Période de reproduction
              </div>
              <div class="KeyDataBlockText">
                {{
                  Math.round(
                    (keyData.prospecting_hours.breeding /
                      keyData.prospecting_hours.all_period) *
                      100
                  )
                }}% | {{ keyData.prospecting_hours.breeding }} heures
              </div>
            </div>
          </div>
          <div class="KeyDataBlockDetails">
            <div
              class="KeyDataBlockDetailsDot"
              :style="{ background: pieChartColors[1] }"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockText" style="font-weight: 500">
                Période d'hivernage
              </div>
              <div class="KeyDataBlockText">
                {{
                  Math.round(
                    (keyData.prospecting_hours.wintering /
                      keyData.prospecting_hours.all_period) *
                      100
                  )
                }}% | {{ keyData.prospecting_hours.wintering }} heures
              </div>
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
  async fetch() {
    this.keyData = await this.$axios.$get('/api/v1/general_stats')
  },
  data: () => ({
    keyData: {},
    pieChartColors: ['#2A9D8F', '#264653'],
  }),
  mounted() {
    // Get pie chart size
    const pieChartHeight = parseFloat(
      d3.select('.KeyDataBlockIcon').style('height')
    )
    // Get pie chart svg and set size
    const pieChartSvg = d3
      .select('.pieChartSvg')
      .attr('width', pieChartHeight)
      .attr('height', pieChartHeight)
    // Define pie chart colors
    const color = d3.scaleOrdinal(this.pieChartColors)
    // Define pie chart shape
    const arcPath = d3
      .arc()
      .outerRadius(pieChartHeight / 2)
      .innerRadius(pieChartHeight / 5)
    // Define data
    const data = [
      { hours: 2374, label: 'Période de reproduction' },
      { hours: 1394, label: "Période d'hivernage" },
    ]
    const pieChartData = d3.pie().value(function (d) {
      return d.hours
    })(data)
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
  height: 47%;
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
