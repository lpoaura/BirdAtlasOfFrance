<!-- Attendre l'API des points EPOC ODF -->
<template>
  <div v-click-outside="closeSelectBox" class="SelectLayerWrapper">
    <div class="SelectLayerContent" @click="openOrCloseSelectBox">
      <img class="SelectLayerIcon" src="/layers.svg" />
      <span class="SelectLayerText">Couches</span>
      <img
        class="SelectLayerChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="SelectBox">
      <div class="SelectBoxHeader">
        <span class="SelectBoxTitle">Couches</span>
      </div>
      <div class="LayersList">
        <!-- <div
          class="LayersLi"
          :class="noLayerIsOn ? 'selected' : ''"
          @click="setNoLayerToTrue"
        >
          <div class="LayersLiRadio">
            <div v-if="noLayerIsOn" class="LayersLiRadioSelected"></div>
          </div>
          <span class="LayersLiText">Aucune</span>
        </div> -->
        <div
          class="LayersLi"
          :class="knowledgeLevelLayerIsOn ? 'selected' : ''"
          @click="setKnowledgeLevelLayerToTrue"
        >
          <div class="LayersLiRadio">
            <div
              v-if="knowledgeLevelLayerIsOn"
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
            <div v-if="epocLayerIsOn" class="LayersLiRadioSelected"></div>
          </div>
          <span class="LayersLiText">Points EPOC ODF</span>
        </div>
        <!-- <div v-show="epocLayerIsOn" class="EpocList">
          <div class="EpocLi">
            <span class="LayersLiText">EPOC</span>
          </div>
          <div class="EpocLi">
            <span class="LayersLiText">EPOC ODF</span>
          </div>
          <div class="EpocLi">
            <span class="LayersLiText">EPOC ODF de réserve</span>
          </div>
        </div> -->
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({
    selectIsOpen: false,
    // noLayerIsOn: false,
    knowledgeLevelLayerIsOn: true,
    epocLayerIsOn: false,
    epocPointsIsOn: false,
    epocODFPointsIsOn: false,
    epocODFReserveIsOn: false,
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
      this.autocompleteIsOpen = false
    },
    closeSelectBox() {
      this.selectIsOpen = false
      this.autocompleteIsOpen = false
    },
    updateSelectedDisplayingType(type) {
      this.selectedDisplayingType = type
    },
    clearResults() {
      this.autocompleteIsOpen = false
      this.search = ''
    },
    closeSearchBar() {
      this.autocompleteIsOpen = false
    },
    // setNoLayerToTrue() {
    //   this.noLayerIsOn = true
    //   this.knowledgeLevelLayerIsOn = false
    //   this.epocLayerIsOn = false
    // },
    setKnowledgeLevelLayerToTrue() {
      this.knowledgeLevelLayerIsOn = !this.knowledgeLevelLayerIsOn
      this.$emit('knowledgeLevelLayer', this.knowledgeLevelLayerIsOn)
    },
    setEpocLayerToTrue() {
      this.epocLayerIsOn = !this.epocLayerIsOn
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

.SelectLayerContent {
  height: 44px;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.SelectLayerIcon {
  width: 16px;
  margin-right: 12px;
}

.SelectLayerText {
  margin-right: 12px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.SelectLayerChevron {
  width: 8px;
}

.SelectBox {
  position: absolute;
  z-index: 5;
  top: 44px;
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
  margin-bottom: 16px;
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
