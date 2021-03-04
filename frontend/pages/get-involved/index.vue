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
      <div class="HelpingCardsContent">
        <nuxt-link
          to="/about/what-is-ODF-project#get-involved"
          class="HelpingCard"
          >Découvrir les bases de la prospection</nuxt-link
        >
        <nuxt-link to="/get-involved/which-protocol-to-use" class="HelpingCard"
          >Quel dispositif dois-je utiliser ?</nuxt-link
        >
      </div>
    </section>
    <section class="ProtocolsSection">
      <h2 class="ProtocolsTitle">Tous les dispositifs</h2>
      <div class="ProtocolsCardsContent">
        <nuxt-link
          v-for="(card, index) in protocolsCards"
          :key="index"
          :to="card.routerPath"
          class="ProtocolsCard"
        >
          <img class="ProtocolsCardsIcon" :src="card.icon" />
          <div class="ProtocolsCardsTitle">{{ card.title }}</div>
          <div class="ProtocolsCardsSubtitle">{{ card.subtitle }}</div>
          <div
            class="ProtocolsCardsChip"
            :class="[card.season === 'Reproduction' ? 'breeding' : 'wintering']"
          >
            {{ card.season }}
          </div>
        </nuxt-link>
      </div>
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    protocolsCards: [
      {
        icon: '/get-involved/EPOC-logo.svg',
        title: 'EPOC',
        subtitle: "Estimation des Populations d'Oiseaux Communs",
        routerPath: '#',
        season: 'Reproduction',
      },
      {
        icon: '/get-involved/STOC-logo.svg',
        title: 'STOC',
        subtitle: 'Suivi Temporel des Oiseaux Communs',
        routerPath: '#',
        season: 'Reproduction',
      },
      {
        icon: '/get-involved/STOM-logo.svg',
        title: 'STOM',
        subtitle: 'Suivi Temporel des Oiseaux de Montagne',
        routerPath: '#',
        season: 'Reproduction',
      },
      {
        icon: '/get-involved/Observatoire-Rapaces-logo.svg',
        title: 'Observatoire Rapaces',
        subtitle: '',
        routerPath: '#',
        season: 'Reproduction',
      },
      {
        icon: '/get-involved/LIMAT-logo.svg',
        title: 'LIMAT',
        subtitle: 'Limicoles et Anatidés Nicheurs',
        routerPath: '#',
        season: 'Reproduction',
      },
      {
        icon: '/get-involved/SHOC-logo.svg',
        title: 'SHOC',
        subtitle: 'Suivi Hivernal des Oiseaux Communs',
        routerPath: '#',
        season: 'Hivernage',
      },
      {
        icon: '/get-involved/Wetlands-logo.svg',
        title: 'Wetlands',
        subtitle: "Recensement des Oiseaux d'Eau",
        routerPath: '#',
        season: 'Hivernage',
      },
    ],
  }),
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
  width: 64%;
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

.HelpingCardsContent {
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

.HelpingCard {
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

.HelpingCard:hover {
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

.ProtocolsCardsContent {
  padding-left: 1.6vw;
  display: flex;
  flex-wrap: wrap;
}

.ProtocolsCard {
  background: #efefef;
  width: 16.5vw;
  height: 198px;
  border-radius: 16px;
  margin-right: 1.6vw;
  margin-bottom: 1.6vw;
  padding: 0 2%;
  text-decoration: none;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transition: 0.3s;
}

.ProtocolsCardsIcon {
  height: 48px;
  margin-bottom: 12px;
}

.ProtocolsCardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  text-align: center;
  margin-bottom: 4px;
  transition: 0.3s;
}

.ProtocolsCardsSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  text-align: center;
  color: rgba(38, 38, 38, 0.6);
  transition: 0.3s;
}

.ProtocolsCard:hover .ProtocolsCardsSubtitle {
  margin-bottom: 12px;
}

.ProtocolsCardsChip {
  opacity: 0;
  border-radius: 61px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 0;
  font-size: 0;
  line-height: 0;
  transition: 0.3s;
}

.ProtocolsCardsChip.breeding {
  background: #fb7971;
  color: #000;
}

.ProtocolsCardsChip.wintering {
  background: #9eb9ff;
  color: #fcfcfc;
}

.ProtocolsCard:hover .ProtocolsCardsChip {
  opacity: 1;
  padding: 2.5% 8%;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
}
</style>
