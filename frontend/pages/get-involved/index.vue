<!-- Pages de chaque protocole -->
<template>
  <v-container fluid>
    <section class="IntroSection">
      <div class="BackgroundPicture">
        <header class="IntroContent">
          <h1 class="IntroTitle">Participer via les dispositifs de suivi</h1>
          <h4 class="IntroSubtitle">
            Déterminer les <b>tendances</b> d'évolution et les
            <b>effectifs</b> chez les oiseaux<br />nécessite l'utilisation de
            dispositifs de suivi <b>adaptés</b>.
          </h4>
        </header>
      </div>
      <div class="CardsContent">
        <nuxt-link to="/about/what-is-ODF-project#get-involved" class="Card"
          >Découvrir les bases de la prospection</nuxt-link
        >
        <nuxt-link to="/get-involved/which-protocol-to-use" class="Card"
          >Quel dispositif dois-je utiliser ?</nuxt-link
        >
      </div>
    </section>
    <section class="ProtocolsSection">
      <h2 class="ProtocolsTitle">Tous les dispositifs</h2>
      <protocols-cards />
    </section>
  </v-container>
</template>

<script>
import ProtocolsCards from '~/components/get-involved/ProtocolsCards.vue'

export default {
  components: {
    'protocols-cards': ProtocolsCards,
  },
  head: {
    title: 'Participer',
  },
}
</script>

<style scoped>
.IntroSection {
  position: relative;
  width: 100%;
  height: 470px;
}

.BackgroundPicture {
  position: relative;
  background: linear-gradient(
      94.13deg,
      rgba(37, 39, 69, 0.46) 5.97%,
      rgba(37, 39, 69, 0.76) 38.61%,
      rgba(37, 39, 69, 0.76) 76.76%,
      rgba(37, 39, 69, 0) 98.47%
    ),
    url('/get-involved/get-involved-picture.png') center / 100%,
    rgba(47, 92, 105, 1);
  width: 100%;
  height: 87%;
  display: flex;
}

.IntroContent {
  position: absolute;
  z-index: 5;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  width: 100%;
  height: 30%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
}

.IntroTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 40px;
  line-height: 60px;
  text-align: center;
  color: #fcfcfc;
}

.IntroSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  text-align: center;
  color: #fff;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.25);
}

.CardsContent {
  position: absolute;
  z-index: 1;
  left: 13vw;
  bottom: 0;
  background: #fcfcfc;
  width: 74vw;
  height: 26%;
  border-radius: 24px;
  padding: 1.6vw;
  display: flex;
  justify-content: space-between;
}

.Card {
  background: #efefef;
  width: 34.6vw;
  height: 100%;
  border-radius: 16px;
  padding: 0 2%;
  text-decoration: none;
  display: flex;
  justify-content: center;
  align-items: center;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
}

.Card:hover {
  background: rgba(238, 206, 37, 0.2);
}

.ProtocolsSection {
  padding-left: 13vw;
  padding-bottom: 1%;
}

.ProtocolsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
  margin-left: 1.6vw;
  margin-bottom: 1.6vw;
}
</style>
