<template>
  <v-container fluid>
    <header>
      <h1 class="PageTitle">Quel dispositif dois-je utiliser ?</h1>
    </header>
    <section class="CardsSection">
      <h2 class="CardsSectionTitle">Choisissez un groupe d'espèces</h2>
      <div class="CardsContent">
        <div
          v-for="(card, index) in speciesGroupsCards"
          :key="index"
          class="Card"
          :class="[selectedSpeciesGroup === card.title ? 'selected' : '']"
          @click="updateSelectedSpeciesGroup(card.title)"
        >
          <div
            class="CardsIcon"
            :class="[
              card.class,
              selectedSpeciesGroup === card.title ? 'selected' : '',
            ]"
          ></div>
          <h6 class="CardsTitle">{{ card.title }}</h6>
          <span class="CardsSubtitle">{{ card.subtitle }}</span>
        </div>
      </div>
    </section>
    <section v-if="selectedSpeciesGroup" class="CardsSection">
      <h2 class="CardsSectionTitle">
        Dispositifs adaptés
        <span v-if="selectedSpeciesGroup !== 'Autres'">
          aux <b>{{ selectedSpeciesGroup.toLowerCase() }}</b>
        </span>
      </h2>
      <protocols-cards :species-group-filter="selectedSpeciesGroup" />
    </section>
  </v-container>
</template>

<script>
import ProtocolsCards from '~/components/get-involved/ProtocolsCards.vue'

export default {
  components: {
    'protocols-cards': ProtocolsCards,
  },
  data: () => ({
    speciesGroupsCards: [
      {
        title: 'Oiseaux communs',
        subtitle: 'Passereaux, Pics...',
        class: 'commonBirds',
      },
      {
        title: 'Rapaces',
        subtitle: 'Buses, Milans, Faucons...',
        class: 'raptors',
      },
      {
        title: "Oiseaux d'eau",
        subtitle: 'Canards, Limicoles, Hérons...',
        class: 'waterBirds',
      },
      {
        title: 'Autres',
        subtitle: 'Cigognes, Oiseaux marins...',
        class: 'otherBirds',
      },
    ],
    selectedSpeciesGroup: null,
  }),
  computed: {
    resultsCards() {
      if (!this.selectedSpeciesGroup) {
        return this.protocolsCards
      } else {
        return this.protocolsCards.filter((card) => {
          return card.speciesGroup === this.selectedSpeciesGroup
        })
      }
    },
  },
  methods: {
    updateSelectedSpeciesGroup(speciesGroup) {
      this.selectedSpeciesGroup = speciesGroup
    },
  },
  head: {
    title: 'Quel dispositif dois-je utiliser ?',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}

header {
  width: 100%;
  margin: 32px 0;
  display: flex;
  justify-content: center;
}

.PageTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
  color: #000;
}

.CardsSection {
  padding-left: 13vw;
  padding-bottom: 1%;
}

.CardsSectionTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 24px;
  line-height: 36px;
  margin-left: 1.6vw;
  margin-bottom: 1.6vw;
}

.CardsContent {
  padding-left: 1.6vw;
  display: flex;
  flex-wrap: wrap;
}

.Card {
  background: #efefef;
  width: 16.5vw;
  height: 198px;
  border-radius: 16px;
  margin-right: 1.6vw;
  margin-bottom: 1.6vw;
  padding: 0 2%;
  text-decoration: none;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.Card:hover {
  background: rgba(238, 206, 37, 0.2);
}

.Card.selected {
  background: rgba(238, 206, 37, 0.2);
  border: 3px solid #eece25;
}

.CardsIcon {
  width: 54px;
  height: 54px;
  margin-bottom: 16px;
}

.CardsIcon.commonBirds {
  background: url('/get-involved/common-birds-no-color.svg') 0 0 / 100%;
}

.Card:hover .CardsIcon.commonBirds,
.CardsIcon.commonBirds.selected {
  background: url('/get-involved/common-birds-color.svg') 0 0 / 100%;
}

.CardsIcon.raptors {
  background: url('/get-involved/raptors-no-color.svg') 0 0 / 100%;
}

.Card:hover .CardsIcon.raptors,
.CardsIcon.raptors.selected {
  background: url('/get-involved/raptors-color.svg') 0 0 / 100%;
}

.CardsIcon.waterBirds {
  background: url('/get-involved/water-birds-no-color.svg') 0 0 / 100%;
}

.Card:hover .CardsIcon.waterBirds,
.CardsIcon.waterBirds.selected {
  background: url('/get-involved/water-birds-color.svg') 0 0 / 100%;
}

.CardsIcon.otherBirds {
  background: url('/get-involved/other-birds-no-color.svg') 0 0 / 100%;
}

.Card:hover .CardsIcon.otherBirds,
.CardsIcon.otherBirds.selected {
  background: url('/get-involved/other-birds-color.svg') 0 0 / 100%;
}

.CardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  text-align: center;
  margin-bottom: 4px;
}

.CardsSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  text-align: center;
  color: rgba(38, 38, 38, 0.6);
}
</style>
