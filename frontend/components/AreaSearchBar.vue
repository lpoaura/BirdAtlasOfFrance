<!-- Reste à récupérer l'emprise de la commune et à centrer la carte sur cette emprise -->
<template>
  <div>
    <!-- item-text correspond au label qui est affiché dans la liste déroulante -->
    <!-- return-object permet de renvoyer l'intégralité de la donnée, et pas juste le code de la commune -->
    <v-autocomplete
      v-model="selectedCity"
      :items="areas"
      :loading="isLoading"
      :search-input.sync="search"
      hide-no-data
      clearable
      item-text="html_repr"
      item-value="code"
      label="Rechercher une commune"
      placeholder="Tapez le nom d'une commune..."
      prepend-icon="mdi-map-marker"
      return-object
    ></v-autocomplete>
    <!-- <span>{{ selectedCity }}</span> -->
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
    search(newVal) {
      // Areas have already been requested
      if (this.isLoading) return
      // Lazily load input areas
      this.isLoading = true
      this.$axios
        .$get(
          `http://localhost:8888/api/v1/search?limit=10&type_code=COM&search=${newVal}`
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
