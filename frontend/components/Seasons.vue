<template>
  <div>
    <v-select
      v-model="selectedSeason"
      :items="seasonsList"
      label="Choisir une saison"
    >
      {{ season }}
    </v-select>
    <!-- <span>{{ selectedSeason }}</span> -->
  </div>
</template>

<script>
export default {
  data: () => ({
    seasonsList: ['Reproduction', 'Hiver', 'Toutes saisons'],
    selectedSeason: null,
  }),
}
</script>
