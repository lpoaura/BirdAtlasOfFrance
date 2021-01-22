<template>
  <h1>Fiche espèce {{ cdnom }}</h1>
</template>

<script>
export default {
  computed: {
    cdnom() {
      return this.$route.params.cdnom
    },
  },
}
</script>
