<template>
  <v-container fluid>
    <main class="TopSection">
      <header class="TopSectionContent">
        <h1 class="white02 fw-bold text-center bottom-margin-16">
          Participer via les dispositifs de suivi
        </h1>
        <h4 class="white01 fw-500 text-center text-shadow">
          Déterminer les <b>tendances</b> d'évolution et les
          <b>effectifs</b> chez les oiseaux <br class="br" />nécessite
          l'utilisation de dispositifs de suivi <b>adaptés</b>.
        </h4>
      </header>
    </main>
    <section class="Section">
      <menu class="TabMenu">
        <div
          v-for="(item, index) in speciesGroups"
          :key="index"
          class="TabItem"
          :class="item.hash === selectedSpeciesGroup.hash ? 'selected' : ''"
          @click="updateSelectedSpeciesGroup(item)"
        >
          {{ item.label }}
        </div>
      </menu>
      <dropdown-list
        v-model="selectedSpeciesGroupModel"
        :z-index="1"
        :items-list="speciesGroups"
      />
      <component :is="currentComponent" />
    </section>
  </v-container>
</template>

<script>
import ProtocolsCards from '~/components/get-involved/ProtocolsCards.vue'
import CalendarSection from '~/components/get-involved/CalendarSection.vue'

export default {
  components: {
    ProtocolsCards,
    CalendarSection,
  },
  data: () => ({
    speciesGroups: [
      { hash: 'all', label: 'Tous les dispositifs' },
      { hash: 'calendar', label: 'Calendrier' },
    ],
    selectedSpeciesGroup: { hash: 'all', label: 'Tous les dispositifs' },
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    };
  },
  computed: {
    // Permet de mettre à jour selectedSpeciesGroup seulement après le $router.push
    selectedSpeciesGroupModel: {
      get() {
        return this.selectedSpeciesGroup;
      },
      set(value) {
        this.$router.push(`#${value.hash}`);
      },
    },
    currentComponent() {
      return this.selectedSpeciesGroup.hash === 'calendar'
        ? 'CalendarSection'
        : 'ProtocolsCards';
    },
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      const hash = newVal.hash.replace('#', '') || 'all'; // Nettoyage du hash
      this.selectedSpeciesGroup = this.speciesGroups.find((item) => item.hash === hash) || this.speciesGroups[0];
    },
  },
  mounted() {
    const hash = this.$route.hash.replace('#', '') || 'all';
    this.selectedSpeciesGroup = this.speciesGroups.find((item) => item.hash === hash) || this.speciesGroups[0];
  },
  methods: {
    updateSelectedSpeciesGroup(item) {
      this.$router.push(`#${item.hash}`);
    },
  },
};
</script>

<style scoped>
.TopSection {
  height: 336px;
  background: linear-gradient(
      94.13deg,
      rgba(37, 39, 69, 0.46) 5.97%,
      rgba(37, 39, 69, 0.76) 38.61%,
      rgba(37, 39, 69, 0.76) 76.76%,
      rgba(37, 39, 69, 0) 98.47%
    ),
    url('/get-involved/get-involved-picture.webp') center / cover,
    rgba(47, 92, 105, 1);
}

.TopSectionContent {
  width: 90%;
  height: 40%;
}

.Section {
  padding: 32px 0 0;
  align-items: center;
}

.TabMenu {
  margin-bottom: 32px;
}

.DropdownListWrapper {
  display: none;
}

/********** RESPONSIVE **********/

@media screen and (width <= 680px) {
  .TopSection {
    height: 270px;
  }

  .br {
    display: none;
  }

  .TabMenu {
    display: none;
  }

  .DropdownListWrapper {
    display: block;
  }
}
</style>
