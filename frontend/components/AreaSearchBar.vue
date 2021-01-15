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
      item-text="name"
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
    search(val) {
      // Areas have already been loaded
      if (this.areas.length > 0) return
      // Areas have already been requested
      if (this.isLoading) return
      this.isLoading = true
      // Lazily load input areas
      fetch(
        'http://localhost:8888/api/v1/search?limit=1000&search=a&type_code=COM'
      )
        .then((response) => response.json())
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
