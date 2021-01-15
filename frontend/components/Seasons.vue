<template>
  <div>
    <v-select
      v-model="selectedSeason"
      :items="seasonsList"
      disabled
      label="Choisir une saison"
      prepend-icon="mdi-weather-sunny"
    ></v-select>
    <!-- <span>{{ selectedSeason }}</span> -->
  </div>
</template>

<script>
export default {
  data: () => ({
    seasonsList: ['Reproduction', 'Hiver', 'Toutes saisons'],
    selectedSeason: 'Reproduction',
  }),
}
</script>
