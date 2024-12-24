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
      <h4 class="black02 fw-600 bottom-margin-8">Phénologie</h4> 
            <span class="black02 bottom-margin-24">
      Science qui étudie les phénomènes qui marquent la vie des animaux et des plantes. Chez les oiseaux migrateurs on s’intéresse plus particulièrement aux périodes d’arrivée ou de départ en migration.
      </span>
      <h4 class="black02 fw-600 bottom-margin-8">Stratégie d’échantillonnage </h4>
      <span class="black02 bottom-margin-24">
      Comme il est impossible de recenser une population d’oiseaux entière sur le territoire, il est donc nécessaire de réaliser un échantillon sur une partie de la population qui sera analysé statistiquement pour produire des connaissances. En fonction du type de connaissances souhaitées (répartition, taille de population, phénologie*, tendances démographique), on définit une stratégie d’échantillonnage en établissant un plan d’échantillonnage qui va conditionner la façon dont on va collecter les données sur le terrain (protocole). 
      <a href="http://ct72.espaces-naturels.fr/definir-les-modalites-de-l%E2%80%99echantillonnage" target="_blank" title="Plus d’informations">Plus d’informations</a>
      </span>
      <h4 class="black02 fw-600 bottom-margin-8">Variable essentielle de biodiversité (EBV)</h4>
      <span class="black02 bottom-margin-24">
      Les variables essentielles de biodiversité correspondent à l’ensemble des paramètres que nous devrions idéalement pouvoir renseigner pour disposer d’une représentation précise de la biodiversité, afin d’en mesurer les évolutions au fil du temps. 
      <a href="https://naturefrance.fr/la-production-de-connaissances" target="_blank" title="Plus d’informations">Plus d’informations</a>
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
  padding: 16px 16% 0;
}

.Section {
  padding: 32px 16%;
}

/********** RESPONSIVE **********/

@media screen and (width <= 920px) {
  .TopSection {
    padding: 16px 5% 0;
  }

  .Section {
    padding: 32px 5%;
  }
}
</style>
