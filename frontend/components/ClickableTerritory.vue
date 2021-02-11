<template>
  <v-list-item @click="selectTerritory">
    <v-list-item-title>
      <span>{{ territoryData.name }}</span>
    </v-list-item-title>
  </v-list-item>
</template>

<script>
export default {
  props: {
    territoryData: {
      type: Object,
      required: true,
    },
  },
  methods: {
    selectTerritory() {
      this.$emit('selectedTerritory', this.territoryData.bounds)
    },
  },
}
</script>
