<template>
  <div v-show="selectIsOpen" class="MapSelectorBox">
    <header class="MapSelectorHeader">
      <div class="MapSelectorInfo">
        <h4 class="black02 fw-600">Couches</h4>
      </div>
    </header>
    <div class="MapSelectorOverflow">
      <li
        v-for="(layer, index) in layersList"
        :key="index"
        class="RadioOption"
        :class="layer.label === selectedLayer ? 'selected' : ''"
        @click="updateSelectedLayer(layer.label)"
      >
        <div class="RadioLabel">
          <div class="RadioButton">
            <div
              v-show="layer.label === selectedLayer"
              class="RadioButtonSelected"
            ></div>
          </div>
          {{ layer.label }}
        </div>
        <h5 v-if="layer.subtitle" class="RadioSubtitle black04">
          {{ layer.subtitle }}
        </h5>
      </li>
      <div v-show="selectedLayer === 'Points EPOC'">
        <div class="RadioOption epoc">
          <div class="RadioLabel">
            <switch-button v-model="epocRealizedIsOn" />
            EPOC réalisés
          </div>
        </div>
        <div class="RadioOption epoc">
          <div class="RadioLabel">
            <switch-button v-model="epocOdfIsOn" />
            EPOC ODF 2021
            <!-- EPOC ODF {{ new Date().getFullYear() }} -->
          </div>
        </div>
      </div>
      <div
        v-if="selectedSpecies"
        class="RadioOption"
        :class="speciesDistributionLayer === selectedLayer ? 'selected' : ''"
        @click="updateSelectedLayer(speciesDistributionLayer)"
      >
        <div class="RadioLabel">
          <div class="RadioButton">
            <div
              v-show="speciesDistributionLayer === selectedLayer"
              class="RadioButtonSelected"
            ></div>
          </div>
          {{ speciesDistributionLayer }}
        </div>
        <!-- <h5 class="RadioSubtitle black04">
            Non compatible avec les fonds carthographiques Plan et
            Orthophotographies
          </h5> -->
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
      type: String,
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
      { label: 'Aucune', subtitle: null },
      {
        label: 'Indice de complétude',
        subtitle: null,
        // subtitle:
        //   'Non compatible avec les fonds carthographiques Plan et Orthophotographies',
      },
      { label: "Nombre d'espèces par maille", subtitle: null },
      { label: 'Points EPOC', subtitle: null },
    ],
    speciesDistributionLayer: "Répartition de l'espèce",
    epocRealizedIsOn: true,
    epocOdfIsOn: true,
    planIsOn: false,
    planOpacity: '50',
    orthophotoIsOn: false,
    orthophotoOpacity: '50',
  }),
  computed: {
    filteredTerritories() {
      return this.territoriesList.filter((territory) =>
        territory.name.toLowerCase().includes(this.search.toLowerCase())
      )
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
        this.$emit('selectedLayer', this.speciesDistributionLayer)
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
