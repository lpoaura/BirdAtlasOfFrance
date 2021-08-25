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
          v-for="(item, index) in menuItems"
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
        :items-list="menuItems"
      />
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
    menuItems: [
      { hash: '', label: 'Tous les dispositifs' },
      { hash: '#common-birds', label: 'Oiseaux communs' },
      { hash: '#raptors', label: 'Rapaces' },
      { hash: '#water-birds', label: "Oiseaux d'eau" },
      // { hash: '#other-birds', label: 'autres' },
    ],
    selectedSpeciesGroup: { hash: '', label: 'Tous les dispositifs' },
  }),
  computed: {
    // Permet de mettre à jour selectedSpeciesGroup seulement après le $router.push
    selectedSpeciesGroupModel: {
      get() {
        return this.selectedSpeciesGroup
      },
      set(value) {
        this.$router.push(`${value.hash}`)
      },
    },
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.selectedSpeciesGroup = this.menuItems.filter((item) => {
        return item.hash === newVal.hash
      })[0]
    },
  },
  mounted() {
    this.selectedSpeciesGroup = this.menuItems.filter((item) => {
      return item.hash === this.$route.hash
    })[0]
  },
  methods: {
    updateSelectedSpeciesGroup(item) {
      this.$router.push(`${item.hash}`)
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
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
    url('/get-involved/get-involved-picture.jpg') center / cover,
    rgba(47, 92, 105, 1);
}

.TopSectionContent {
  width: 90%;
  height: 40%;
}

.Section {
  padding: 32px 5% 40px 5%;
  align-items: center;
}

.TabMenu {
  margin-bottom: 32px;
}

.DropdownListWrapper {
  display: none;
}

@media screen and (max-width: 680px) {
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
