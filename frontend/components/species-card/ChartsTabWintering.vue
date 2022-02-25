<template>
  <div class="SpeciesCardContent" :class="tabStatus">
    <div v-if="dataTrend" id="trend-wintering" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">Tendance d'évolution</h4>
      <h5 class="black03 bottom-margin-40">
        Évolution de l’indice d’abondance en fonction des années.
      </h5>
      <trend :formatted-data="dataTrend" />
    </div>
    <div
      v-if="dataPopulationsWintering"
      id="populations-sizes-wintering"
      class="ChartCard"
    >
      <h4 class="black02 fw-bold bottom-margin-8">Tailles de populations</h4>
      <h5 class="black03 bottom-margin-40">
        Estimation des effectifs nicheurs au cours du temps.
      </h5>
      <populations-sizes :formatted-data="dataPopulationsWintering" />
    </div>
    <div v-if="dataAltitude" id="altitude-wintering" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">
        Répartition altitudinale des observations
      </h4>
      <h5 class="black03 bottom-margin-40">
        Proportion des observations en fonction de l’altitude du territoire.
      </h5>
      <altitude :formatted-data="dataAltitude" />
    </div>
    <span
      v-if="!dataTrend && !dataPopulationsWintering && !dataAltitude"
      class="black02 fw-600 text-center UnavailableData"
    >
      Aucun diagramme disponible pour le territoire et la période sélectionnés.
    </span>
  </div>
</template>

<script>
import Trend from '~/components/species-card/Trend.vue'
import PopulationsSizes from '~/components/species-card/PopulationsSizes.vue'
import Altitude from '~/components/species-card/Altitude.vue'

export default {
  components: {
    trend: Trend,
    'populations-sizes': PopulationsSizes,
    altitude: Altitude,
  },
  props: {
    tabStatus: {
      type: String,
      required: true,
    },
    dataTrend: {
      type: Object,
      required: false,
      default: null,
    },
    dataPopulationsWintering: {
      type: Object,
      required: false,
      default: null,
    },
    dataAltitude: {
      type: Object,
      required: false,
      default: null,
    },
  },
}
</script>
