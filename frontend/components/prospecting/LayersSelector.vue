<!-- Refaire les switchers... -->
<template>
  <div v-click-outside="closeSelectBox" class="SelectLayerWrapper">
    <div class="SelectedLayerContent" @click="openOrCloseSelectBox">
      <img class="SelectedLayerIcon" src="/layers.svg" />
      <span class="SelectedLayerText">Couches</span>
      <img
        class="SelectedLayerChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="SelectBox">
      <div class="SelectBoxHeader">
        <span class="SelectBoxTitle">Couches</span>
      </div>
      <div class="LayersList">
        <div
          v-for="(layer, index) in layersList"
          :key="index"
          class="LayersLi"
          :class="layer === selectedLayer ? 'selected' : ''"
          @click="updateSelectedLayer(layer)"
        >
          <div class="LayersLiRadio">
            <div
              v-show="layer === selectedLayer"
              class="LayersLiRadioSelected"
            ></div>
          </div>
          <span class="LayersLiText">{{ layer }}</span>
        </div>
        <div v-show="selectedLayer === 'Points EPOC'" class="EpocList">
          <!-- Ajouter les points EPOC classiques -->
          <div class="EpocLi">
            <v-switch
              v-model="epocOdfOfficialIsOn"
              inset
              dense
              color="#EECE25"
            ></v-switch>
            <span class="LayersLiText">EPOC ODF</span>
          </div>
          <div class="EpocLi">
            <v-switch
              v-model="epocOdfReserveIsOn"
              inset
              dense
              color="#EECE25"
            ></v-switch>
            <span class="LayersLiText">EPOC ODF de réserve</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectedLayer: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    selectIsOpen: false,
    layersList: ['Aucune', 'Indice de complétude', 'Points EPOC'],
    epocPointsIsOn: true,
    epocOdfOfficialIsOn: true,
    epocOdfReserveIsOn: true,
  }),
  computed: {
    filteredTerritories() {
      return this.territoriesList.filter((territory) =>
        territory.name.toLowerCase().includes(this.search.toLowerCase())
      )
    },
  },
  watch: {
    epocOdfOfficialIsOn(newVal) {
      this.$emit('epocOdfOfficialIsOn', newVal)
    },
    epocOdfReserveIsOn(newVal) {
      this.$emit('epocOdfReserveIsOn', newVal)
    },
  },
  methods: {
    openOrCloseSelectBox() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSelectBox() {
      this.selectIsOpen = false
    },
    updateSelectedLayer(layer) {
      this.$emit('selectedLayer', layer)
    },
  },
}
</script>

<style scoped>
.SelectLayerWrapper {
  position: relative;
  margin-left: 20px;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.SelectedLayerContent {
  cursor: pointer;
  display: flex;
  align-items: center;
}

.SelectedLayerIcon {
  width: 16px;
  margin-right: 12px;
}

.SelectedLayerText {
  margin-right: 12px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SelectedLayerChevron {
  width: 8px;
}

.SelectBox {
  position: absolute;
  z-index: 5;
  top: 30px;
  background: #fcfcfc;
  width: 334px;
  max-height: calc(100vh - 136px);
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.16);
  border-radius: 8px;
  padding: 16px;
  overflow: auto;
  display: flex;
  flex-direction: column;
}

.SelectBoxHeader {
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SelectBoxTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: #000;
}

.LayersList,
.EpocList {
  display: flex;
  flex-direction: column;
}

.LayersLi {
  width: 100%;
  height: 39.2px;
  padding-left: 10px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.LayersLi.selected {
  background: rgba(238, 206, 37, 0.2);
}

.LayersLiRadio {
  margin-right: 12px;
  min-width: 16px;
  max-width: 16px;
  min-height: 16px;
  max-height: 16px;
  border-radius: 50%;
  border: 1px solid rgba(38, 38, 38, 0.2);
  display: flex;
}

.LayersLi.selected .LayersLiRadio {
  border: none;
  background: #eece25;
}

.LayersLiRadioSelected {
  background: #fcfcfc;
  margin: auto;
  min-width: 6px;
  max-width: 6px;
  min-height: 6px;
  max-height: 6px;
  border-radius: 50%;
}

.LayersLiText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.EpocLi {
  width: 100%;
  height: 39.2px;
  padding-left: 38px;
  display: flex;
  align-items: center;
}
</style>
