<template>
  <v-row justify="center" align="center">
    <v-col cols="12" sm="8" md="6">
      <div class="text-center">
        <h1>Page d'accueil</h1>
      </div>
      <species-search-bar @selectedSpecies="updateSelectedSpecies" />
    </v-col>
  </v-row>
</template>

<script>
import SpeciesSearchBar from '~/components/SpeciesSearchBar.vue'

export default {
  components: {
    'species-search-bar': SpeciesSearchBar,
  },
  data: () => ({
    selectedSpecies: null,
  }),
  methods: {
    updateSelectedSpecies(species) {
      this.selectedSpecies = species
      this.$router.push({ path: `/species-card/${species}` })
    },
  },
}
</script>
