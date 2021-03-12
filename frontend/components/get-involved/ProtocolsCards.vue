<template>
  <div class="ProtocolsCardsContent">
    <nuxt-link
      v-for="(card, index) in resultsCards"
      :key="index"
      :to="card.routerPath"
      class="ProtocolsCard"
    >
      <img class="ProtocolsCardsIcon" :src="card.icon" />
      <h6 class="ProtocolsCardsTitle">{{ card.title }}</h6>
      <span class="ProtocolsCardsSubtitle">{{ card.subtitle }}</span>
      <span
        class="ProtocolsCardsChip"
        :class="[card.season === 'Reproduction' ? 'breeding' : 'wintering']"
      >
        {{ card.season }}
      </span>
    </nuxt-link>
  </div>
</template>

<script>
export default {
  props: {
    speciesGroupFilter: {
      type: String,
      required: false,
      default: null,
    },
  },
  data: () => ({
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
        speciesGroup: 'Oiseaux communs',
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
        routerPath: '/get-involved/shoc',
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
      if (this.speciesGroupFilter === null) {
        return this.protocolsCards
      } else {
        return this.protocolsCards.filter((card) => {
          return card.speciesGroup === this.speciesGroupFilter
        })
      }
    },
  },
}
</script>

<style scoped>
.ProtocolsCardsContent {
  padding-left: 1.6vw;
  display: flex;
  flex-wrap: wrap;
}

.ProtocolsCard {
  background: #efefef;
  width: 16.5vw;
  height: 198px;
  border-radius: 16px;
  margin-right: 1.6vw;
  margin-bottom: 1.6vw;
  padding: 0 2%;
  text-decoration: none;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transition: 0.3s;
}

.ProtocolsCardsIcon {
  max-width: 120px;
  height: 48px;
  margin-bottom: 12px;
}

.ProtocolsCardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  text-align: center;
  margin-bottom: 4px;
  transition: 0.3s;
}

.ProtocolsCardsSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  text-align: center;
  color: rgba(38, 38, 38, 0.6);
  transition: 0.3s;
}

.ProtocolsCard:hover .ProtocolsCardsSubtitle {
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

.ProtocolsCard:hover .ProtocolsCardsChip {
  opacity: 1;
  padding: 2.5% 8%;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
}
</style>
