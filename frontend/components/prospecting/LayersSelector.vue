<template>
  <div v-show="selectIsOpen" class="MapSelectorBox">
    <header class="MapSelectorHeader">
      <div class="MapSelectorInfo">
        <h4 class="black02 fw-600">Couches</h4>
      </div>
    </header>
    <div class="MapSelectorOverflow">
      <li
        v-for="(layer, index) in resultsLayers"
        :key="index"
        class="RadioOption"
        :class="layer.value === selectedLayer.value ? 'selected' : ''"
        @click="updateSelectedLayer(layer)"
      >
        <div class="RadioLabel">
          <div class="RadioButton">
            <div
              v-show="layer.value === selectedLayer.value"
              class="RadioButtonSelected"
            ></div>
          </div>
          {{ layer.label }}
        </div>
        <h5 v-if="layer.subtitle" class="RadioSubtitle black04">
          {{ layer.subtitle }}
        </h5>
      </li>
      <div v-show="selectedLayer.value === 'epoc'">
        <div class="RadioOption epoc">
          <div class="RadioLabel">
            <switch-button v-model="epocRealizedIsOn" />
            EPOC réalisés
          </div>
        </div>
        <div class="RadioOption epoc">
          <div class="RadioLabel">
            <switch-button v-model="epocOdfIsOn" />
            EPOC ODF {{ new Date().getFullYear() }}
          </div>
        </div>
      </div>
      <!-- v-show="['Aucune', 'Points EPOC'].includes(selectedLayer)" -->
      <div class="BackgroundMapsWrapper">
        <div class="BackgroundMapsSplit"></div>
        <h4 class="black02 fw-600 bottom-margin-16">Fonds carthographiques</h4>
        <div class="BackgroundMap">
          <switch-button v-model="planIsOn" />
          <div class="BackgroundMapSlider">
            <span class="BackgroundMapLabel black02"> Plan </span>
            <range-slider
              v-show="planIsOn"
              v-model="planOpacity"
              :min="0"
              :max="100"
            />
          </div>
          <div v-show="planIsOn" class="BackgroundMapInput">
            <input
              v-model="planOpacity"
              type="number"
              value="50"
              min="0"
              max="100"
            />
            <span class="black04 unit">%</span>
          </div>
        </div>
        <div class="BackgroundMap">
          <switch-button v-model="orthophotoIsOn" />
          <div class="BackgroundMapSlider">
            <span class="BackgroundMapLabel black02"> Orthophotographies </span>
            <range-slider
              v-show="orthophotoIsOn"
              v-model="orthophotoOpacity"
              :min="0"
              :max="100"
            />
          </div>
          <div v-show="orthophotoIsOn" class="BackgroundMapInput">
            <input
              v-model="orthophotoOpacity"
              type="number"
              value="50"
              min="0"
              max="100"
            />
            <span class="black04 unit">%</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectIsOpen: {
      type: Boolean,
      required: true,
    },
    selectedLayer: {
      type: Object,
      required: true,
    },
    selectedSpecies: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data: () => ({
    layersList: [
      { value: 'none', label: 'Aucune', subtitle: null, permanent: true },
      {
        value: 'knowledge-level',
        label: 'Indice de complétude',
        subtitle: null,
        // subtitle: 'Non compatible avec les fonds carthographiques Plan et Orthophotographies',
        permanent: true,
      },
      {
        value: 'species-number',
        label: "Nombre d'espèces par maille",
        subtitle: null,
        permanent: true,
      },
      {
        value: 'species-distribution',
        label: "Répartition de l'espèce",
        subtitle: null,
        // subtitle: 'Non compatible avec les fonds carthographiques Plan et Orthophotographies',
        permanent: false,
      },
      { value: 'epoc', label: 'Points EPOC', subtitle: null, permanent: true },
    ],
    epocRealizedIsOn: true,
    epocOdfIsOn: true,
    planIsOn: false,
    planOpacity: '50',
    orthophotoIsOn: false,
    orthophotoOpacity: '50',
  }),
  computed: {
    resultsLayers() {
      if (this.selectedSpecies) {
        return this.layersList
      } else {
        return this.layersList.filter((layer) => {
          return layer.permanent
        })
      }
    },
  },
  watch: {
    epocRealizedIsOn(newVal) {
      this.$emit('epocRealizedIsOn', newVal)
    },
    epocOdfIsOn(newVal) {
      this.$emit('epocOdfIsOn', newVal)
    },
    planIsOn(newVal) {
      this.$emit('planIsOn', newVal)
    },
    planOpacity(newVal) {
      this.$emit('planOpacity', newVal)
    },
    orthophotoIsOn(newVal) {
      this.$emit('orthophotoIsOn', newVal)
    },
    orthophotoOpacity(newVal) {
      this.$emit('orthophotoOpacity', newVal)
    },
    selectedSpecies(newVal) {
      if (newVal) {
        const speciesDistributionLayer = this.layersList.filter((layer) => {
          return layer.value === 'species-distribution'
        })[0]
        this.$emit('selectedLayer', speciesDistributionLayer)
      }
    },
  },
  methods: {
    updateSelectedLayer(layer) {
      this.$emit('selectedLayer', layer)
    },
  },
}
</script>

<style scoped>
.BackgroundMapsSplit {
  width: 100%;
  height: 1px;
  min-height: 1px;
  margin: 10px 0 16px;
  background: rgba(57, 118, 90, 0.1);
}

.BackgroundMap {
  padding: 10px 0 10px 12px;
  display: flex;
  justify-content: space-between;
}

.BackgroundMapLabel {
  line-height: 16px;
}

.BackgroundMapSlider {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.BackgroundMapInput {
  position: relative;
  width: 60px;
  height: 32px;
  padding-left: 8px;
  margin-left: 12px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  display: flex;
  align-items: center;
}

.BackgroundMapInput input {
  width: 26px;
  outline: none;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: rgba(38, 38, 38, 0.4);
  text-align: right;
}

.BackgroundMapInput .unit {
  position: absolute;
  top: 0;
  bottom: 0;
  right: 11px;
  display: flex;
  align-items: center;
}

/* Mozilla Firefox */
input[type='number'] {
  appearance: textfield;
}

/* Chrome */
input[type='number']::-webkit-inner-spin-button,
input[type='number']::-webkit-outer-spin-button {
  appearance: none;
  margin: 0;
}

.leaflet-control .MapSelectorBox {
  right: -58px;
}
</style>
