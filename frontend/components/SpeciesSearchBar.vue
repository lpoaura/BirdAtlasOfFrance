<template>
  <v-autocomplete
    v-model="selectedSpecies"
    :items="species"
    :loading="isLoading"
    :search-input.sync="search"
    hide-no-data
    clearable
    item-text="name"
    item-value="code"
    label="Rechercher une espèce"
    placeholder="Tapez le nom d'une espèce..."
    prepend-icon="mdi-bird"
  ></v-autocomplete>
</template>

<script>
export default {
  data: () => ({
    search: null,
    isLoading: false,
    species: [],
    selectedSpecies: null,
  }),
  watch: {
    selectedSpecies(newVal) {
      this.$emit('selectedSpecies', newVal)
    },
    search(newVal) {
      this.isLoading = true
      this.$axios
        .$get(
          `http://localhost:8888/api/v1/search_taxa?limit=50&search=${newVal}`
        )
        .then((data) => {
          this.species = data
        })
        .catch((error) => {
          console.log(error)
        })
        .finally(() => (this.isLoading = false))
    },
  },
}
</script>
