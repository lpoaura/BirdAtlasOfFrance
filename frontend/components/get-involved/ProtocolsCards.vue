<template>
  <section class="ProtocolCardSection">
    <div class="table-container">

      <!-- Ligne 1 : Dispositifs annuels -->
      <div class="row">
        <div class="cell cell-first">
          <div class="TabItem vertical selected">Dispositifs annuels</div>
        </div>
        <div class="cell">
          <div class="ProtocolsCardsGrid">
            <nuxt-link
              v-for="(card, index) in annualCards"
              :key="index"
              :to="card.route"
              class="ProtocolCard"
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
                :class="card.season === 'Reproduction' ? 'breeding' : 'wintering'"
              >
                {{ card.season }}
              </span>
            </nuxt-link>
          </div>
        </div>
      </div>

      <!-- Ligne 2 : Dispositifs périodiques -->
      <div class="row">
        <div class="cell cell-first">
          <div class="TabItem vertical selected">Dispositifs périodiques</div>
        </div>
        <div class="cell">
          <div class="ProtocolsCardsGrid">
            <nuxt-link
              v-for="(card, index) in periodicCards"
              :key="index"
              :to="card.route"
              class="ProtocolCard"
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
                :class="card.season === 'Reproduction' ? 'breeding' : 'wintering'"
              >
                {{ card.season }}
              </span>
            </nuxt-link>
          </div>
        </div>
      </div>

      <!-- Ligne 3 : Dispositifs permanents -->
      <div class="row">
        <div class="cell cell-first">
          <div class="TabItem vertical selected">Dispositifs permanents</div>
        </div>
        <div class="cell">
          <div class="ProtocolsCardsGrid">
            <nuxt-link
              v-for="(card, index) in permanentCards"
              :key="index"
              :to="card.route"
              class="ProtocolCard"
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
                :class="card.season === 'Reproduction' ? 'breeding' : 'wintering'"
              >
                {{ card.season }}
              </span>
            </nuxt-link>
          </div>
        </div>
      </div>

    </div>
  </section>
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
    protocolsCards: [
      {
        icon: '/get-involved/EPOC-ODF-logo.svg',
        title: 'EPOC ODF',
        subtitle: "Estimation des Populations d'Oiseaux Communs ODF",
        route: '/get-involved/epoc-odf',
        season: 'Reproduction',
        speciesGroup: ['#periodic'],
      },
      {
        icon: '/get-involved/LIMAT-logo.svg',
        title: 'LIMAT',
        subtitle: 'Limicoles et Anatidés Nicheurs',
        route: '/get-involved/limat',
        season: 'Reproduction',
        speciesGroup: ['#periodic'],
      },
      // {
      //  icon: '/get-involved/Observatoire-Rapaces-logo.svg',
      //   title: 'Observatoire Rapaces',
      //   subtitle: '',
      //   route: '/get-involved/observatoire-rapaces',
      //   season: 'Reproduction',
      //   speciesGroup: ['#periodic'],
      // },
      {
        icon: '/get-involved/STOC-logo.svg',
        title: 'STOC',
        subtitle: 'Suivi Temporel des Oiseaux Communs',
        route: '/get-involved/stoc',
        season: 'Reproduction',
        speciesGroup: ['#annuel'],
      },
      {
        icon: '/get-involved/SHOC-logo.svg',
        title: 'SHOC',
        subtitle: 'Suivi Hivernal des Oiseaux Communs',
        route: '/get-involved/shoc',
        season: 'Hivernage',
        speciesGroup: ['#annuel'],
      },
      // {
      //   icon: '/get-involved/STOM-logo.svg',
      //   title: 'STOM',
      //   subtitle: 'Suivi Temporel des Oiseaux de Montagne',
      //   route: '/get-involved/stom',
      //   season: 'Reproduction',
      //   speciesGroup: ['#annuel'],
      // },
      {
        icon: '/get-involved/Wetlands-logo.svg',
        title: 'Wetlands',
        subtitle: "Recensement des Oiseaux d'Eau",
        route: '/get-involved/wetlands',
        season: 'Hivernage',
        speciesGroup: ['#annuel'],
      },
      {
        icon: '/get-involved/EPOC-logo.svg',
        title: 'EPOC',
        subtitle: "Estimation des Populations d'Oiseaux Communs",
        route: '/get-involved/epoc',
        season: 'Reproduction',
        speciesGroup: ['#permanent'],
      },
      {
        icon: '/get-involved/complete-lists-logo.svg',
        title: 'Prospections Atlas',
        subtitle: null,
        route: '/get-involved/complete-lists',
        season: null,
        speciesGroup: ['#permanent'],
      },
    ],
  }),
  computed: {
    // Filtre les cartes pour les dispositifs permanents
    permanentCards() {
      return this.protocolsCards.filter((card) =>
        card.speciesGroup.includes("#permanent")
      );
    },
    // Filtre les cartes pour les dispositifs annuels
    annualCards() {
      return this.protocolsCards.filter((card) =>
        card.speciesGroup.includes("#annuel")
      );
    },
    // Filtre les cartes pour les dispositifs périodiques
    periodicCards() {
      return this.protocolsCards.filter((card) =>
        card.speciesGroup.includes("#periodic")
      );
    },
  },
};
</script>

<style scoped>
.ProtocolCardSection {
  flex: 1;
  position: relative;
  display: flex;
  padding: 0;
  margin: 0;
  background-repeat: no-repeat;
  box-sizing: border-box;
  width: auto;
  justify-content: center;
  align-items: center;
}

.table-container {
  display: flex;
  flex-direction: column;
  border: none;
  width: 100%;
}

.row {
  display: flex;
  gap: 10px; /* Espacement entre les colonnes */
  border: none;
}

.cell {
  padding: 24px;
  border: none;
}

.cell-first {
  width: 250px; /* Largeur fixe pour la première colonne */
  flex: none; /* Empêche la première colonne de s'étirer */
}

.cell:not(.cell-first) {
  flex: 1; /* Laisse la deuxième colonne s'étirer pour occuper l'espace restant */
}

.TabItem {
  background: #efefef ;
  color: black;
  font-weight: 500;
}

.ProtocolsCardsGrid {
  width: 100%;
  display: flex; /* Utiliser flexbox pour gérer l'agencement des cartes */
  flex-wrap: wrap; /* Permet aux cartes de se répartir sur plusieurs lignes si nécessaire */
  gap: 24px;
  justify-content: flex-start; /* Assure que les cartes s'alignent à gauche */
}

.ProtocolCard {
  width: 210px;
  height: 210px;
  box-sizing: border-box; /* Inclure les bordures et le padding dans les dimensions */
}


/********** RESPONSIVE **********/

@media screen and (width <= 745px) {
  .table-container {
    display: flex;
    flex-direction: column; /* En une seule colonne */
  }

  .row {
    flex-direction: column; /* Chaque ligne devient une colonne */
    gap: 0; /* Supprime l'écart entre les lignes */
  }

  .cell-first {
    width: 100%; /* Prend toute la largeur disponible */
    flex: none; /* Empêche l'étirement */
    order: -1; /* Place la cellule "cell-first" au-dessus */
  }

  .cell {
    width: 100%; /* Les autres cellules prennent toute la largeur disponible */
    padding: 12px; /* Ajuste un peu le padding pour plus de confort */
  }

  .ProtocolsCardsGrid {
    display: flex;
    flex-direction: column; /* Les cartes sont empilées verticalement */
    gap: 16px; /* Espacement entre les cartes */
  }

  .ProtocolCard {
    width: 210px;
    height: 210px;
    box-sizing: border-box;
  }

  h4.CardTitle {
    font-size: 16px;
    line-height: 24px;
  }

  h5.CardSubtitle {
    font-size: 14px; /* Réduit la taille du texte des sous-titres */
  }

  .Badge {
    font-size: 12px; /* Réduit la taille des badges */
  }
}

</style>