<template>
  <div>
    <v-card @click="selectTerritory">
      <v-card-text>
        <span>{{ territoryData.name }}</span>
      </v-card-text>
    </v-card>
  </div>
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
