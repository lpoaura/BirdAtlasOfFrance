<template>
  <v-container fluid>
    <main class="TopSection">
      <div class="BackgroundPicture">
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
      </div>
    </main>
    <section class="Section">
      <menu class="TabMenu">
        <span
          v-for="(item, index) in menuItems"
          :key="index"
          :to="item.route"
          class="TabItem"
          :class="[item.label === selectedSpeciesGroup ? 'selected' : '']"
          @click="updateSelectedSpeciesGroup(item)"
        >
          {{ item.label }}
        </span>
      </menu>
      <dropdown-list
        v-model="selectedSpeciesGroup"
        :z-index="1"
        :items-list="itemsList"
      />
      <protocols-cards :species-group-filter="selectedSpeciesGroup" />
    </section>
  </v-container>
</template>

<script>
import DropdownList from '~/components/global/DropdownList.vue'
import ProtocolsCards from '~/components/get-involved/ProtocolsCards.vue'

export default {
  components: {
    'dropdown-list': DropdownList,
    'protocols-cards': ProtocolsCards,
  },
  data: () => ({
    menuItems: [
      { label: 'Tous les dispositifs', route: '' },
      { label: 'Oiseaux communs', route: '#common-birds' },
      { label: 'Rapaces', route: '#raptors' },
      { label: "Oiseaux d'eau", route: '#water-birds' },
      // { label: 'autres', route: '#other-birds' },
    ],
    selectedSpeciesGroup: 'Tous les dispositifs',
  }),
  computed: {
    itemsList() {
      return this.menuItems.map((item) => item.label)
    },
  },
  // mounted() {
  //   this.selectedMenuItem = this.$route.hash
  // },
  methods: {
    updateSelectedSpeciesGroup(item) {
      this.selectedSpeciesGroup = item.label
      // this.selectedMenuItem = item.route
      // this.$router.push(`${item.route}`)
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
}

.BackgroundPicture {
  position: relative;
  background: linear-gradient(
      94.13deg,
      rgba(37, 39, 69, 0.46) 5.97%,
      rgba(37, 39, 69, 0.76) 38.61%,
      rgba(37, 39, 69, 0.76) 76.76%,
      rgba(37, 39, 69, 0) 98.47%
    ),
    url('/get-involved/get-involved-picture.jpg') center / cover,
    rgba(47, 92, 105, 1);
  width: 100%;
  height: 100%;
  display: flex;
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
