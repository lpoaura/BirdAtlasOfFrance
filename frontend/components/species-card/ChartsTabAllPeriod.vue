<template>
  <div class="SpeciesCardContent" :class="tabStatus">
    <div v-if="dataPhenology" id="phenology-all-period" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">Phénologie</h4>
      <h5 class="black03 bottom-margin-40">
        Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au
        31 décembre de l'année dernière.
      </h5>
      <phenology-all-period
        v-if="dataPhenology"
        :formatted-data="dataPhenology"
      />
    </div>
    <div
      v-if="dataPhenologyMigration"
      id="phenology-migration"
      class="ChartCard"
    >
      <h4 class="black02 fw-bold bottom-margin-8">Phénologie de migration</h4>
      <h5 class="black03 bottom-margin-24">
        Nombre de données cumulées par décade du 1<sup>er</sup> janvier 2019 au
        31 décembre de l'année dernière.
      </h5>
      <phenology-migration :formatted-data="dataPhenologyMigration" />
    </div>
    <div
      v-if="dataAltitude && dataAltitude.altitude.data.length > 0"
      id="altitude-all-period"
      class="ChartCard"
    >
      <h4 class="black02 fw-bold bottom-margin-8">
        Répartition altitudinale des observations
      </h4>
      <h5 class="black03 bottom-margin-40">
        Proportion des observations en fonction de l’altitude du territoire.
      </h5>
      <altitude v-if="dataAltitude" :formatted-data="dataAltitude" />
    </div>
    <div v-if="dataPopulationsTest" class="ChartCard">
      <h4 class="black02 fw-bold bottom-margin-8">
        Tailles de populations (CECI EST UN TEST QUI N'A RIEN À FAIRE ICI)
      </h4>
      <h5 class="black03 bottom-margin-40">
        Nombre d’individus comptabilisés au cours des années.
      </h5>
      <populations-sizes :formatted-data="dataPopulationsTest" />
    </div>
    <span
      v-if="!dataPhenology && !dataPhenologyMigration && !dataAltitude"
      class="black02 fw-600 text-center UnavailableData"
    >
      Aucun diagramme disponible pour le territoire et la période sélectionnés.
    </span>
  </div>
</template>

<script>
import PhenologyAllPeriod from '~/components/species-card/PhenologyAllPeriod.vue'
import PhenologyMigration from '~/components/species-card/PhenologyMigration.vue'
import Altitude from '~/components/species-card/Altitude.vue'
import PopulationsSizes from '~/components/species-card/PopulationsSizes.vue'

export default {
  components: {
    'phenology-all-period': PhenologyAllPeriod,
    'phenology-migration': PhenologyMigration,
    altitude: Altitude,
    'populations-sizes': PopulationsSizes
  },
  props: {
    tabStatus: {
      type: String,
      required: true
    },
    dataPhenology: {
      type: Object,
      required: false,
      default: null
    },
    dataPhenologyMigration: {
      type: Object,
      required: false,
      default: null
    },
    dataAltitude: {
      type: Object,
      required: false,
      default: null
    },
    dataPopulationsTest: {
      type: Object,
      required: false,
      default: null
    }
  },
  mounted() {
    console.log('ChartsPhenoAllPeriod', this.dataPhenology)
  }
}
</script>
