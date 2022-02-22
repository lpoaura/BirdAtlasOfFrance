<template>
  <div class="SpeciesCardContent" :class="tabStatus">
    <div id="phenology-breeding" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
      <h5 class="black03 bottom-margin-40">
        Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au
        31 décembre de l'année dernière.
      </h5>
      <phenology-breeding :formatted-data="dataPhenologyBreeding" />
    </div>
    <div id="trend-breeding" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">Tendance d'évolution</h4>
      <h5 class="black03 bottom-margin-40">
        Évolution de l’indice d’abondance en fonction des années.
      </h5>
      <trend :formatted-data="dataTrend" />
    </div>
    <div id="populations-size-breeding" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">Tailles de populations</h4>
      <h5 class="black03 bottom-margin-40">
        Estimation des effectifs nicheurs au cours du temps.
      </h5>
      <populations-sizes :formatted-data="dataPopulationsBreeding" />
    </div>
    <div id="altitude-breeding" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">
        Répartition altitudinale des observations
      </h4>
      <h5 class="black03 bottom-margin-40">
        Proportion des observations en fonction de l’altitude du territoire.
      </h5>
      <altitude :formatted-data="dataAltitude" />
    </div>
  </div>
</template>

<script>
import PhenologyBreeding from '~/components/species-card/PhenologyBreeding.vue'
import Trend from '~/components/species-card/Trend.vue'
import PopulationsSizes from '~/components/species-card/PopulationsSizes.vue'
import Altitude from '~/components/species-card/Altitude.vue'

export default {
  components: {
    'phenology-breeding': PhenologyBreeding,
    trend: Trend,
    'populations-sizes': PopulationsSizes,
    altitude: Altitude,
  },
  props: {
    tabStatus: {
      type: String,
      required: true,
    },
    dataPhenologyBreeding: {
      type: Object,
      required: false,
      default: null,
    },
    dataTrend: {
      type: Object,
      required: false,
      default: null,
    },
    dataPopulationsBreeding: {
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
