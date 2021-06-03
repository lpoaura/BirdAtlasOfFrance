<template>
  <div class="EpocDashboardControl">
    <!-- HEADER -->
    <div class="EpocDashboardHeader">
      <div class="EpocDashboardHeaderText">
        <h1 class="EpocDashboardTitle">
          {{ clickedEpocPoint.properties.id_ff }}
        </h1>
      </div>
      <a
        class="EpocDashboardDownloadButton"
        :href="`/files/map/epoc/${clickedEpocPoint.properties.id_epoc}.pdf`"
        target="_blank"
      >
        <img class="EpocDashboardDownloadButtonIcon" src="/download.svg" />
      </a>
    </div>
    <!-- CONTENT -->
    <div class="EpocDashboardContent">
      <div class="Split"></div>
      <div class="EpocPropertyContent">
        <div class="EpocPropertyLabel">Type</div>
        <div
          v-if="clickedEpocPoint.properties.status === 'Officiel'"
          class="EpocPropertyValue"
        >
          EPOC ODF officiel
        </div>
        <div v-else class="EpocPropertyValue">
          EPOC ODF de réserve (rang {{ clickedEpocPoint.properties.rang_rsv }})
        </div>
        <div class="EpocPropertyCopy"></div>
      </div>
      <div class="EpocPropertyContent">
        <div class="EpocPropertyLabel">Coordonnées</div>
        <div class="EpocPropertyValue">
          {{ epocPointCoordinates[0] }}, {{ epocPointCoordinates[1] }}
        </div>
        <div class="EpocPropertyCopy">
          <img
            v-clipboard:copy="epocPointCoordinates"
            class="EpocPropertyCopyIcon"
            src="/copy.svg"
            title="Copier les coordonnées"
          />
        </div>
      </div>
      <a
        :href="`https://www.google.fr/maps/place/${epocPointCoordinates}`"
        target="_blank"
        class="PrimaryButton outlined"
        style="margin-bottom: 16px"
        >Ouvrir sur Google Maps</a
      >
      <div class="Split"></div>
      <div
        class="EpocDashboardHeader no-bottom-margin pointer"
        @click="updateEpocHelpStatus"
      >
        <h2 class="EpocDashboardTitle">Le point est inaccessible ?</h2>
        <img
          class="EpocDashboardChevron"
          :src="epocHelpIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
        />
      </div>
      <span v-show="epocHelpIsOpen" class="EpocDashboardHelp">
        <p class="no-bottom-margin">
          Si le point EPOC est inaccessible (propriété privée, terrain
          millitaire, zone aquatique...), merci de sélectionner le premier point
          EPOC de réserve disponible.
        </p>
        <p class="no-bottom-margin">
          Pour afficher les points EPOC de réserve, cliquez sur “Couches”,
          sélectionnez “Points EPOC” puis activez “EPOC de réserve”.
        </p>
      </span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    clickedEpocPoint: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    epocHelpIsOpen: false,
  }),
  computed: {
    epocPointCoordinates() {
      return [
        this.clickedEpocPoint.geometry.coordinates[1],
        this.clickedEpocPoint.geometry.coordinates[0],
      ]
    },
  },
  methods: {
    updateEpocHelpStatus() {
      this.epocHelpIsOpen = !this.epocHelpIsOpen
    },
  },
}
</script>

<style scoped>
.EpocDashboardControl {
  display: flex;
  flex-direction: column;
}

.EpocDashboardHeader {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.EpocDashboardHeaderText {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.EpocDashboardTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  display: flex;
  align-items: center;
}

.EpocDashboardTitle.margin {
  margin-bottom: 10px;
}

.EpocDashboardDownloadButton {
  width: 40px;
  height: 40px;
  margin-right: 16px;
  border: 2px solid rgba(57, 118, 90, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
}

.EpocDashboardDownloadButtonIcon {
  width: 16px;
  margin: auto;
}

.EpocDashboardContent {
  padding-right: 16px;
  overflow-y: auto;
}

.Split {
  width: 100%;
  height: 0;
  margin-bottom: 16px;
  border: 1px solid rgba(57, 118, 90, 0.1);
}

.EpocPropertyContent {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.EpocPropertyLabel {
  flex: 0.8;
  font-weight: 500;
}

.EpocPropertyValue {
  flex: 2;
  font-weight: normal;
}

.EpocPropertyCopy {
  flex: 0.4;
  display: flex;
  justify-content: flex-end;
}

.EpocPropertyCopyIcon {
  width: 24px;
  cursor: pointer;
}

.EpocDashboardChevron {
  width: 11px;
}

.EpocDashboardHelp {
  margin-top: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.pointer {
  cursor: pointer;
}

p {
  margin-top: 16px;
}
</style>
