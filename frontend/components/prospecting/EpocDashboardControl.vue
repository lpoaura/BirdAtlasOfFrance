<template>
  <div class="EpocDashboardControl">
    <header class="MapControlHeader">
      <h4 class="fw-bold">
        {{ clickedEpocPoint.properties.id_ff }}
      </h4>
      <a
        class="MapControlDownloadButton"
        :href="`/files/map/epoc/${clickedEpocPoint.properties.id_epoc}.pdf`"
        target="_blank"
      >
        <img class="MapControlDownloadButtonIcon" src="/download.svg" />
      </a>
      <img
        class="MobileMapControlCloseIcon"
        src="/cross.svg"
        @click="closeMobileMapControl"
      />
    </header>
    <div class="MobileMapControlMenuWrapper">
      <a
        :href="`https://www.google.fr/maps/place/${epocPointCoordinates}`"
        target="_blank"
        class="PrimaryButton outlined bottom-margin-24"
      >
        Ouvrir sur Google Maps
      </a>
      <a
        class="MapControlDownloadButton"
        :href="`/files/map/epoc/${clickedEpocPoint.properties.id_epoc}.pdf`"
        target="_blank"
      >
        <img class="MapControlDownloadButtonIcon" src="/download.svg" />
      </a>
    </div>
    <div class="MapControlSplit right-margin-16"></div>
    <div class="MapControlOverflow">
      <li class="MapControlDataOption">
        <span class="EpocPropertyLabel fw-500">Type</span>
        <span class="EpocPropertyValue">
          {{
            clickedEpocPoint.properties.status === 'Officiel'
              ? 'EPOC ODF officiel'
              : 'EPOC ODF de réserve (rang ' +
                clickedEpocPoint.properties.rang_rsv +
                ')'
          }}
        </span>
      </li>
      <li class="MapControlDataOption">
        <div class="EpocPropertyLabel fw-500">Coordonnées</div>
        <div class="EpocPropertyValue">
          <span class="right-margin-8">
            {{ epocPointCoordinates[0] }}, {{ epocPointCoordinates[1] }}
          </span>
          <div class="HelperWrapper">
            <img
              v-clipboard:copy="epocPointCoordinates"
              class="MapControlDataOptionIcon"
              src="/copy.svg"
            />
            <div class="HelperTip"></div>
            <h5 class="HelperContent white02 nowrap">Copier les coordonnées</h5>
          </div>
        </div>
      </li>
      <a
        :href="`https://www.google.fr/maps/place/${epocPointCoordinates}`"
        target="_blank"
        class="PrimaryButton outlined bottom-margin-16"
      >
        Ouvrir sur Google Maps
      </a>
      <div class="MapControlSplit"></div>
      <div class="SeeMoreWrapper" @click="updateEpocHelpStatus">
        <h4 class="black02 fw-bold">Le point est inaccessible ?</h4>
        <img
          class="SeeMoreChevron"
          :src="epocHelpIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
        />
      </div>
      <span v-show="epocHelpIsOpen" class="black02">
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
    // MOBILE
    closeMobileMapControl() {
      this.$emit('mobileMapControl', false)
    },
  },
}
</script>

<style scoped>
.EpocDashboardControl {
  display: flex;
  flex-direction: column;
}

.EpocPropertyLabel {
  flex: 0.45;
}

.EpocPropertyValue {
  flex: 1;
  display: flex;
  align-items: center;
}

.MapControlDataOptionIcon {
  margin-right: 0;
  cursor: pointer;
}

.HelperTip {
  left: 4px;
  top: 34px;
}

.MapControlDataOptionIcon:hover ~ .HelperTip {
  display: block;
}

.HelperContent {
  top: 42px;
  left: -74px;
}

.MapControlDataOptionIcon:hover ~ .HelperContent {
  display: flex;
}

.MobileMapControl .MapControlOverflow .PrimaryButton.outlined {
  display: none;
}

.SeeMoreWrapper {
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SeeMoreChevron {
  width: 11px;
}

p {
  margin-top: 16px;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 400px) {
  .EpocPropertyLabel {
    flex: 0.8;
  }
}
</style>
