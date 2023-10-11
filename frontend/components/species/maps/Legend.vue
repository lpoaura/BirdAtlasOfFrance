<template>
  <section class="MapControl">
    <header class="MapControlInfo">
      <div class="MapControlInfoTitles">
        <div class="KnowledgeLevel">
          <h4 class="fw-bold">Légende</h4>
          <!-- <div class="HelperWrapper">
            <img class="HelpIcon" src="/help.svg" />
            <div class="HelperTip"></div>
            <h5 class="HelperContent white02 nowrap">
              Rapport entre le nombre d'espèces<br />observées sur la période
              2019-2024<br />et le nombre d’espèces observées<br />sur les
              périodes précédentes.
            </h5>
          </div> -->
        </div>
      </div>
    </header>
    <div class="KnowledgeLevelPieChartWrapper display-flex">
      <div class="Legend">
        <div
          v-for="(item, index) in legendItems"
          :key="index"
          class="LegendItem"
        >
          <span class="black02 fw-500">
            <i
              :style="{
                background: item.color,
              }"
            ></i
            >{{ item.label }}
          </span>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  data: () => ({}),
  computed: {
    selectedTerritory() {
      return this.$store.state.species.selectedTerritory
    },
    selectedSeason() {
      return this.$store.state.species.selectedSeason
    },
    selectedSubject() {
      return this.$store.state.species.selectedSubject
    },
    legendItems() {
      console.debug(
        'SET LEGEND ITEMS',
        this.selectedSeason,
        this.selectedSubject
      )
      let labels = []
      if (this.selectedSeason.speciesDistributionColors) {
        if (!this.selectedSubject.slug.startsWith('compare')) {
          if (this.selectedSeason.value === 'breeding') {
            labels = ['Nicheur certain', 'Nicheur probable', 'Nicheur possible']
          }
          else if (this.selectedSeason.value === 'wintering') {
            labels = ['Hivernant']
          } else {
            labels = ['Présence']
          }
        } else {
          labels = ['ODF uniquement', 'AOFM uniquement', 'AOFM & ODF']
        }
      }
      console.log('LABELS2', labels)
      return this.generateLegendItems(labels)
    },
  },
  mounted() {
  },
  methods: {
    generateLegendItems(labels) {
      const colors = !this.selectedSubject.slug.startsWith('compare')
          ? this.selectedSeason.speciesDistributionColors
          : ['#D999EF', '#4C61F4', '#EB6A0A']
      return labels.map((e, i) => {
        return {
          label: e,
          color: colors[colors.length - i - 1],
        }
      })
    },
  },
}
</script>

<style scoped>
.MapControl {
  width: 250px;
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

.Legend {
  padding-top: 20px;
}

.LegendItem {
  margin-bottom: 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.LegendItem:last-child {
  margin-bottom: 0;
}

.LegendItem i {
  width: 22px;
  height: 22px;
  border-radius: 6px;
  float: left;
  margin-right: 16px;
}

/********** RESPONSIVE **********/

@media screen and (width <= 400px) {
  .KnowledgeLevelPieChartWrapper {
    flex-direction: column;
    align-items: center;
  }

  .MapLegend {
    width: 180px;
  }
}
</style>
