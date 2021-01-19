<template>
  <div>
    <v-autocomplete
      v-model="selectedCity"
      :items="areas"
      :loading="isLoading"
      :search-input.sync="search"
      hide-no-data
      clearable
      item-text="html_repr"
      item-value="bounds"
      label="Rechercher une commune"
      placeholder="Tapez le nom d'une commune..."
      prepend-icon="mdi-map-marker"
    ></v-autocomplete>
  </div>
</template>

<script>
export default {
  data: () => ({
    selectedCity: null,
    areas: [],
    isLoading: false,
    search: null,
  }),
  watch: {
    selectedCity(newVal) {
      this.$emit('selectedCity', newVal)
    },
    search(newVal) {
      // Areas have already been requested
      // if (this.isLoading) return
      this.isLoading = true
      this.$axios
        .$get(
          `http://localhost:8888/api/v1/search_areas?limit=10&type_code=COM&search=${newVal}`
        )
        .then((data) => {
          this.areas = data
        })
        .catch((error) => {
          console.log(error)
        })
        .finally(() => (this.isLoading = false))
    },
  },
}
</script>
