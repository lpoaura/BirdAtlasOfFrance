<template>
  <v-container fluid>
    <header>
      <breadcrumb style="margin-bottom: 20px" />
      <h1 class="PageTitle">Lexique</h1>
    </header>
    <section class="GlossarySection">
      <label>Espèces sensibles</label>
      <span class="Definition">
        Certaines espèces ont été masquées en raison de leur sensibilité. Les
        espèces concernées sont les suivantes : Aigle de Bonelli, Aigle pomarin,
        Grue cendrée, Gypaète barbu, Pie-grièche à poitrine rose, Pygargue à
        queue blanche, Vautour percnoptère.
      </span>
      <label>Indice de complétude</label>
      <span class="Definition">
        Rapport entre le nombre d'espèces observées sur la période 2019-2024 et
        le nombre d’espèces observées sur les périodes précédentes.
      </span>
      <label>Maille</label>
      <span class="Definition">
        Carré de 10km de côté dans lequel s’effectue une prospection.
      </span>
    </section>
  </v-container>
</template>

<script>
export default {
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

header {
  width: 100%;
  padding: 10px 16% 16px 16%;
  display: flex;
  flex-direction: column;
}

.PageTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 32px;
  line-height: 48px;
  color: #000;
  text-align: center;
}

.GlossarySection {
  width: 100%;
  padding: 0 16% 10px 16%;
  display: flex;
  flex-direction: column;
}

label {
  margin-bottom: 6px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: #000;
}

.Definition {
  margin-bottom: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

@media screen and (max-width: 768px) {
  header {
    padding: 10px 6% 16px 6%;
  }
  .GlossarySection {
    padding: 0 6% 10px 6%;
  }
}
</style>
