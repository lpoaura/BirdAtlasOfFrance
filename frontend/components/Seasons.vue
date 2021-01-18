<template>
  <div>
    <v-select
      v-model="selectedSeason"
      :items="seasonsList"
      item-text="name"
      item-value="value"
      label="Choisir une saison"
      prepend-icon="mdi-weather-sunny"
    ></v-select>
    <!-- <span>{{ selectedSeason }}</span> -->
  </div>
</template>

<script>
export default {
  data: () => ({
    seasonsList: [
      { name: 'Reproduction', value: 'breeding' },
      { name: 'Hiver', value: 'wintering' },
      { name: 'Toutes saisons', value: ' all_period' },
    ],
    selectedSeason: 'breeding',
  }),
  watch: {
    selectedSeason(newVal) {
      this.$emit('selectedSeason', newVal)
    },
  },
}
</script>
