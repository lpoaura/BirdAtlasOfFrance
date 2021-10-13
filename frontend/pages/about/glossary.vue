<template>
  <v-container fluid>
    <main class="TopSection breadcrumb">
      <breadcrumb />
      <header>
        <h2 class="black02 fw-600 text-center">Lexique</h2>
      </header>
    </main>
    <section class="Section">
      <h4 class="black02 fw-600 bottom-margin-8">Espèces sensibles</h4>
      <span class="black02 bottom-margin-24">
        Certaines espèces ont été masquées en raison de leur sensibilité. Les
        espèces concernées sont les suivantes : Aigle de Bonelli, Aigle pomarin,
        Balbuzard pêcheur, Grue cendrée, Gypaète barbu, Pie-grièche à poitrine
        rose, Pygargue à queue blanche, Vautour percnoptère.
      </span>
      <h4 class="black02 fw-600 bottom-margin-8">Indice de complétude</h4>
      <span class="black02 bottom-margin-24">
        Rapport entre le nombre d'espèces observées sur la période 2019-2024 et
        le nombre d’espèces observées sur les périodes précédentes.
      </span>
      <h4 class="black02 fw-600 bottom-margin-8">Maille</h4>
      <span class="black02 bottom-margin-24">
        Carré de 10km de côté dans lequel s’effectue une prospection.
      </span>
    </section>
  </v-container>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}

.TopSection {
  padding: 16px 16% 0 16%;
}

.Section {
  padding: 32px 16%;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 920px) {
  .TopSection {
    padding: 16px 5% 0 5%;
  }

  .Section {
    padding: 32px 5%;
  }
}
</style>
