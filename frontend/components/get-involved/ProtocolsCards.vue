<template>
  <div class="ProtocolsCardsContent">
    <nuxt-link
      v-for="(card, index) in resultsCards"
      :key="index"
      :to="card.routerPath"
      class="ProtocolsCard"
      :class="[
        card.title === 'Listes complètes et données ponctuelles'
          ? 'completeLists'
          : '',
      ]"
    >
      <img
        v-if="card.icon !== null"
        class="ProtocolsCardsIcon"
        :src="card.icon"
      />
      <h6 class="ProtocolsCardsTitle">{{ card.title }}</h6>
      <span v-if="card.subtitle !== null" class="ProtocolsCardsSubtitle">{{
        card.subtitle
      }}</span>
      <span
        v-if="card.season !== null"
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
        icon: '/get-involved/EPOC-ODF-logo.svg',
        title: 'EPOC ODF',
        subtitle: "Estimation des Populations d'Oiseaux Communs ODF",
        routerPath: '/get-involved/epoc-odf',
        season: 'Reproduction',
        speciesGroup: ['Oiseaux communs'],
      },
      {
        icon: '/get-involved/EPOC-logo.svg',
        title: 'EPOC',
        subtitle: "Estimation des Populations d'Oiseaux Communs",
        routerPath: '/get-involved/epoc',
        season: 'Reproduction',
        speciesGroup: ['Oiseaux communs'],
      },
      {
        icon: '/get-involved/STOC-logo.svg',
        title: 'STOC',
        subtitle: 'Suivi Temporel des Oiseaux Communs',
        routerPath: '/get-involved/stoc',
        season: 'Reproduction',
        speciesGroup: ['Oiseaux communs'],
      },
      {
        icon: '/get-involved/SHOC-logo.svg',
        title: 'SHOC',
        subtitle: 'Suivi Hivernal des Oiseaux Communs',
        routerPath: '/get-involved/shoc',
        season: 'Hivernage',
        speciesGroup: ['Oiseaux communs'],
      },
      // {
      //   icon: '/get-involved/STOM-logo.svg',
      //   title: 'STOM',
      //   subtitle: 'Suivi Temporel des Oiseaux de Montagne',
      //   routerPath: '/get-involved/stom',
      //   season: 'Reproduction',
      //   speciesGroup: ['Oiseaux communs'],
      // },
      {
        icon: '/get-involved/Observatoire-Rapaces-logo.svg',
        title: 'Observatoire Rapaces',
        subtitle: '',
        routerPath: '/get-involved/observatoire-rapaces',
        season: 'Reproduction',
        speciesGroup: ['Rapaces'],
      },
      {
        icon: '/get-involved/LIMAT-logo.svg',
        title: 'LIMAT',
        subtitle: 'Limicoles et Anatidés Nicheurs',
        routerPath: '/get-involved/limat',
        season: 'Reproduction',
        speciesGroup: ["Oiseaux d'eau"],
      },
      {
        icon: '/get-involved/Wetlands-logo.svg',
        title: 'Wetlands',
        subtitle: "Recensement des Oiseaux d'Eau",
        routerPath: '/get-involved/wetlands',
        season: 'Hivernage',
        speciesGroup: ["Oiseaux d'eau"],
      },
      {
        icon: '/get-involved/complete-lists-logo.svg',
        title: 'Listes complètes et données ponctuelles',
        subtitle: null,
        routerPath: '/get-involved/complete-lists',
        season: null,
        speciesGroup: ['Oiseaux communs', 'Rapaces', "Oiseaux d'eau"],
      },
    ],
  }),
  computed: {
    resultsCards() {
      if (this.speciesGroupFilter === 'Tous les dispositifs') {
        return this.protocolsCards
      } else {
        return this.protocolsCards.filter((card) => {
          return card.speciesGroup.includes(this.speciesGroupFilter)
        })
      }
    },
  },
}
</script>

<style scoped>
.ProtocolsCardsContent {
  display: flex;
  flex-wrap: wrap;
}

.ProtocolsCard {
  background: #efefef;
  width: 17vw;
  height: 230px;
  border-radius: 8px;
  margin-right: 1.45vw;
  margin-bottom: 1.45vw;
  padding: 0 2%;
  text-decoration: none;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transition: 0.3s;
}

.ProtocolsCard.completeLists {
  background: rgba(238, 206, 37, 0.2);
}

.ProtocolsCard.completeLists:hover {
  background: rgba(238, 206, 37, 0.8);
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
