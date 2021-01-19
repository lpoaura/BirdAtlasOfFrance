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
    search: null,
    isLoading: false,
    areas: [],
    selectedCity: null,
  }),
  watch: {
    selectedCity(newVal) {
      this.$emit('selectedCity', newVal)
    },
    search(newVal) {
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
