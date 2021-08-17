<template>
  <div class="ProtocolsCardsGrid">
    <nuxt-link
      v-for="(card, index) in resultsCards"
      :key="index"
      :to="card.route"
      class="ProtocolCard"
      :class="[
        card.title === 'Listes complètes et données ponctuelles'
          ? 'special'
          : '',
      ]"
    >
      <img v-if="card.icon" class="CardIcon" :src="card.icon" />
      <h4 class="CardTitle fw-500 text-center bottom-margin-8">
        {{ card.title }}
      </h4>
      <h5 v-if="card.subtitle" class="CardSubtitle black03 text-center">
        {{ card.subtitle }}
      </h5>
      <span
        v-if="card.season"
        class="Badge"
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
      type: Object,
      required: false,
      default: null,
    },
  },
  data: () => ({
    // RÉCUPÉRER LES PROTOCOLES DEPUIS LE DOSSIER content
    protocolsCards: [
      {
        icon: '/get-involved/EPOC-ODF-logo.svg',
        title: 'EPOC ODF',
        subtitle: "Estimation des Populations d'Oiseaux Communs ODF",
        route: '/get-involved/epoc-odf',
        season: 'Reproduction',
        speciesGroup: ['Oiseaux communs'],
      },
      {
        icon: '/get-involved/EPOC-logo.svg',
        title: 'EPOC',
        subtitle: "Estimation des Populations d'Oiseaux Communs",
        route: '/get-involved/epoc',
        season: 'Reproduction',
        speciesGroup: ['Oiseaux communs'],
      },
      {
        icon: '/get-involved/STOC-logo.svg',
        title: 'STOC',
        subtitle: 'Suivi Temporel des Oiseaux Communs',
        route: '/get-involved/stoc',
        season: 'Reproduction',
        speciesGroup: ['Oiseaux communs'],
      },
      {
        icon: '/get-involved/SHOC-logo.svg',
        title: 'SHOC',
        subtitle: 'Suivi Hivernal des Oiseaux Communs',
        route: '/get-involved/shoc',
        season: 'Hivernage',
        speciesGroup: ['Oiseaux communs'],
      },
      // {
      //   icon: '/get-involved/STOM-logo.svg',
      //   title: 'STOM',
      //   subtitle: 'Suivi Temporel des Oiseaux de Montagne',
      //   route: '/get-involved/stom',
      //   season: 'Reproduction',
      //   speciesGroup: ['Oiseaux communs'],
      // },
      {
        icon: '/get-involved/Observatoire-Rapaces-logo.svg',
        title: 'Observatoire Rapaces',
        subtitle: '',
        route: '/get-involved/observatoire-rapaces',
        season: 'Reproduction',
        speciesGroup: ['Rapaces'],
      },
      {
        icon: '/get-involved/LIMAT-logo.svg',
        title: 'LIMAT',
        subtitle: 'Limicoles et Anatidés Nicheurs',
        route: '/get-involved/limat',
        season: 'Reproduction',
        speciesGroup: ["Oiseaux d'eau"],
      },
      {
        icon: '/get-involved/Wetlands-logo.svg',
        title: 'Wetlands',
        subtitle: "Recensement des Oiseaux d'Eau",
        route: '/get-involved/wetlands',
        season: 'Hivernage',
        speciesGroup: ["Oiseaux d'eau"],
      },
      {
        icon: '/get-involved/complete-lists-logo.svg',
        title: 'Listes complètes et données ponctuelles',
        subtitle: null,
        route: '/get-involved/complete-lists',
        season: null,
        speciesGroup: ['Oiseaux communs', 'Rapaces', "Oiseaux d'eau"],
      },
    ],
  }),
  computed: {
    resultsCards() {
      if (this.speciesGroupFilter.label === 'Tous les dispositifs') {
        return this.protocolsCards
      } else {
        return this.protocolsCards.filter((card) => {
          return card.speciesGroup.includes(this.speciesGroupFilter.label)
        })
      }
    },
  },
}
</script>

<style scoped>
.ProtocolsCardsGrid {
  width: 100%;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  grid-gap: 24px;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
  .ProtocolsCardsGrid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    grid-gap: 16px;
  }

  .ProtocolCard {
    height: 210px;
    padding: 0 12px;
  }

  h4.CardTitle {
    font-size: 16px;
    line-height: 24px;
  }
}
</style>
