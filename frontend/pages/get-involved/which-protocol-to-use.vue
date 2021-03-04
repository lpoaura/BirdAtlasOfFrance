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
          class="Card speciesGroups"
          @click="updateSelectedSpeciesGroup(card.title)"
        >
          <div class="SpeciesGroupsCardsIcon" :class="card.class"></div>
          <div class="CardsTitle">{{ card.title }}</div>
          <div class="CardsSubtitle">{{ card.subtitle }}</div>
        </div>
      </div>
    </section>
    <section v-if="selectedSpeciesGroup !== null" class="CardsSection">
      <h2 class="CardsSectionTitle">
        Dispositifs adaptés
        <span v-if="selectedSpeciesGroup !== 'Autres'">
          aux <b>{{ selectedSpeciesGroup.toLowerCase() }}</b>
        </span>
      </h2>
      <div class="CardsContent">
        <nuxt-link
          v-for="(card, index) in resultsCards"
          :key="index"
          :to="card.routerPath"
          class="Card protocols"
        >
          <img class="ProtocolsCardsIcon" :src="card.icon" />
          <div class="CardsTitle">{{ card.title }}</div>
          <div class="CardsSubtitle">{{ card.subtitle }}</div>
          <div
            class="ProtocolsCardsChip"
            :class="[card.season === 'Reproduction' ? 'breeding' : 'wintering']"
          >
            {{ card.season }}
          </div>
        </nuxt-link>
      </div>
    </section>
  </v-container>
</template>

<script>
export default {
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
    protocolsCards: [
      {
        icon: '/get-involved/EPOC-logo.svg',
        title: 'EPOC',
        subtitle: "Estimation des Populations d'Oiseaux Communs",
        routerPath: '#',
        season: 'Reproduction',
        speciesGroup: 'Oiseaux communs',
      },
      {
        icon: '/get-involved/STOC-logo.svg',
        title: 'STOC',
        subtitle: 'Suivi Temporel des Oiseaux Communs',
        routerPath: '#',
        season: 'Reproduction',
        speciesGroup: 'Oiseaux communs',
      },
      {
        icon: '/get-involved/STOM-logo.svg',
        title: 'STOM',
        subtitle: 'Suivi Temporel des Oiseaux de Montagne',
        routerPath: '#',
        season: 'Reproduction',
        speciesGroup: 'Autres',
      },
      {
        icon: '/get-involved/Observatoire-Rapaces-logo.svg',
        title: 'Observatoire Rapaces',
        subtitle: '',
        routerPath: '#',
        season: 'Reproduction',
        speciesGroup: 'Rapaces',
      },
      {
        icon: '/get-involved/LIMAT-logo.svg',
        title: 'LIMAT',
        subtitle: 'Limicoles et Anatidés Nicheurs',
        routerPath: '#',
        season: 'Reproduction',
        speciesGroup: 'Autres',
      },
      {
        icon: '/get-involved/SHOC-logo.svg',
        title: 'SHOC',
        subtitle: 'Suivi Hivernal des Oiseaux Communs',
        routerPath: '#',
        season: 'Hivernage',
        speciesGroup: 'Oiseaux communs',
      },
      {
        icon: '/get-involved/Wetlands-logo.svg',
        title: 'Wetlands',
        subtitle: "Recensement des Oiseaux d'Eau",
        routerPath: '#',
        season: 'Hivernage',
        speciesGroup: "Oiseaux d'eau",
      },
    ],
  }),
  computed: {
    resultsCards() {
      return this.protocolsCards.filter((card) => {
        return card.speciesGroup === this.selectedSpeciesGroup
      })
    },
  },
  methods: {
    updateSelectedSpeciesGroup(speciesGroup) {
      this.selectedSpeciesGroup = speciesGroup
      console.log(this.selectedSpeciesGroup)
    },
  },
  head: {
    title: 'Quel dispositif dois-je utiliser ?',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 80px;
}

header {
  width: 100%;
  margin: 32px 0 50px 0;
  display: flex;
  justify-content: center;
}

.PageTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
  align-items: center;
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

.Card.speciesGroups:hover {
  background: rgba(238, 206, 37, 0.2);
}

.SpeciesGroupsCardsIcon {
  width: 54px;
  height: 54px;
  margin-bottom: 16px;
}

.SpeciesGroupsCardsIcon.commonBirds {
  background: url('/get-involved/common-birds-no-color.svg') 0 0 / 100%;
}

.Card:hover .SpeciesGroupsCardsIcon.commonBirds {
  background: url('/get-involved/common-birds-color.svg') 0 0 / 100%;
}

.SpeciesGroupsCardsIcon.raptors {
  background: url('/get-involved/raptors-no-color.svg') 0 0 / 100%;
}

.Card:hover .SpeciesGroupsCardsIcon.raptors {
  background: url('/get-involved/raptors-color.svg') 0 0 / 100%;
}

.SpeciesGroupsCardsIcon.waterBirds {
  background: url('/get-involved/water-birds-no-color.svg') 0 0 / 100%;
}

.Card:hover .SpeciesGroupsCardsIcon.waterBirds {
  background: url('/get-involved/water-birds-color.svg') 0 0 / 100%;
}

.SpeciesGroupsCardsIcon.otherBirds {
  background: url('/get-involved/other-birds-no-color.svg') 0 0 / 100%;
}

.Card:hover .SpeciesGroupsCardsIcon.otherBirds {
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

.ProtocolsCardsIcon {
  height: 48px;
  margin-bottom: 12px;
}

.Card.protocols:hover .CardsSubtitle {
  margin-bottom: 12px;
}

.ProtocolsCardsChip {
  opacity: 0;
  border-radius: 61px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 0;
  font-size: 0;
  line-height: 0;
  transition: 0.3s;
}

.ProtocolsCardsChip.breeding {
  background: #fb7971;
  color: #000;
}

.ProtocolsCardsChip.wintering {
  background: #9eb9ff;
  color: #fcfcfc;
}

.Card:hover .ProtocolsCardsChip {
  opacity: 1;
  padding: 2.5% 8%;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
}
</style>
