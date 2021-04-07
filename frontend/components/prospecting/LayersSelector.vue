<!-- Attendre l'API des points EPOC ODF + ajouter maillage transparent -->
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
          class="LayersLi"
          :class="noLayerIsOn ? 'selected' : ''"
          @click="setNoLayerToTrue"
        >
          <div class="LayersLiRadio">
            <div v-show="noLayerIsOn" class="LayersLiRadioSelected"></div>
          </div>
          <span class="LayersLiText">Aucune</span>
        </div>
        <div
          class="LayersLi"
          :class="knowledgeLevelLayerIsOn ? 'selected' : ''"
          @click="setKnowledgeLevelLayerToTrue"
        >
          <div class="LayersLiRadio">
            <div
              v-show="knowledgeLevelLayerIsOn"
              class="LayersLiRadioSelected"
            ></div>
          </div>
          <span class="LayersLiText">Indice de complétude</span>
        </div>
        <div
          class="LayersLi"
          :class="epocLayerIsOn ? 'selected' : ''"
          @click="setEpocLayerToTrue"
        >
          <div class="LayersLiRadio">
            <div v-show="epocLayerIsOn" class="LayersLiRadioSelected"></div>
          </div>
          <span class="LayersLiText">Points EPOC</span>
        </div>
        <div v-show="epocLayerIsOn" class="EpocList">
          <!-- <div class="EpocLi">
            <span class="LayersLiText">EPOC</span>
          </div> -->
          <div class="EpocLi">
            <v-switch
              v-model="epocODFPointsIsOn"
              inset
              dense
              color="#EECE25"
            ></v-switch>
            <span class="LayersLiText">EPOC ODF</span>
          </div>
          <div class="EpocLi">
            <v-switch
              v-model="epocODFReservePointsIsOn"
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
  data: () => ({
    selectIsOpen: false,
    noLayerIsOn: false,
    knowledgeLevelLayerIsOn: true,
    epocLayerIsOn: false,
    epocPointsIsOn: true,
    epocODFPointsIsOn: true,
    epocODFReservePointsIsOn: true,
  }),
  computed: {
    filteredTerritories() {
      return this.territoriesList.filter((territory) =>
        territory.name.toLowerCase().includes(this.search.toLowerCase())
      )
    },
  },
  methods: {
    openOrCloseSelectBox() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSelectBox() {
      this.selectIsOpen = false
    },
    setNoLayerToTrue() {
      this.noLayerIsOn = true
      this.knowledgeLevelLayerIsOn = false
      this.$emit('knowledgeLevelLayer', this.knowledgeLevelLayerIsOn)
      this.epocLayerIsOn = false
    },
    setKnowledgeLevelLayerToTrue() {
      this.knowledgeLevelLayerIsOn = true
      this.$emit('knowledgeLevelLayer', this.knowledgeLevelLayerIsOn)
      this.noLayerIsOn = false
      this.epocLayerIsOn = false
    },
    setEpocLayerToTrue() {
      this.epocLayerIsOn = true
      this.noLayerIsOn = false
      this.knowledgeLevelLayerIsOn = false
      this.$emit('knowledgeLevelLayer', this.knowledgeLevelLayerIsOn)
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
