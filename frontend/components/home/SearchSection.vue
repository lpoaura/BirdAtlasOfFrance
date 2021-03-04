<template>
  <main class="SearchSection">
    <div class="HomePicture">
      <div class="SearchContent">
        <header class="SearchText">
          <h1 class="SearchTitle">
            Explorer l'Atlas<br />des Oiseaux de France
          </h1>
          <label class="SearchSubtitle">
            (Re)découvrez les oiseaux présents sur le territoire français, leurs
            répartitions, tendances et effectifs
          </label>
        </header>
        <div class="SearchBar">
          <search-bar />
        </div>
      </div>
    </div>
    <div class="CardsContent">
      <nuxt-link
        v-for="(card, index) in cards"
        :key="index"
        :to="card.routerPath"
        class="Card"
      >
        <img class="CardsIcon" :src="card.icon" />
        <div class="CardsTitle" v-html="card.title"></div>
      </nuxt-link>
    </div>
  </main>
</template>

<script>
import SearchBar from '~/components/home/SearchBar.vue'

export default {
  components: {
    'search-bar': SearchBar,
  },
  data: () => ({
    cards: [
      {
        icon: '/home/book.svg',
        title: 'Consulter les<br />fiches espèces',
        routerPath: '#',
      },
      {
        icon: '/home/prospecting.svg',
        title: 'Voir la carte<br />de prospection',
        routerPath: '/prospecting',
      },
      {
        icon: '/home/protocol.svg',
        title: 'Découvrir<br />les dispositifs',
        routerPath: '/get-involved',
      },
      {
        icon: '/home/ODF.svg',
        title: "Qu'est-ce que le projet Oiseaux de France ?",
        routerPath: '/what-is-ODF-project',
      },
    ],
  }),
}
</script>

<style scoped>
.SearchSection {
  /* border-bottom: 5px solid cadetblue; */
  position: relative;
  width: 100%;
  height: clamp(500px, 90vh, 784px);
}

.HomePicture {
  position: relative;
  background: linear-gradient(
      180deg,
      rgba(47, 92, 105, 0.76) 0%,
      rgba(47, 92, 105, 0.55) 10.25%,
      rgba(47, 92, 105, 0.2) 20.95%,
      rgba(47, 92, 105, 0.2) 31.47%,
      rgba(8, 43, 8, 0.2) 100%
    ),
    linear-gradient(
      89.84deg,
      rgba(47, 92, 105, 0.81) 0.14%,
      rgba(47, 92, 105, 0.72) 21.44%,
      rgba(47, 92, 105, 0.63) 37.28%,
      rgba(47, 92, 105, 0) 74.41%,
      rgba(47, 92, 105, 0.27) 99.86%
    ),
    url('/home/home-picture.png') 0 0 / 1635px, rgba(47, 92, 105, 1);
  width: 100%;
  height: 85%;
  display: flex;
}

.SearchContent {
  position: absolute;
  z-index: 5;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  width: 64%;
  height: clamp(200px, 34vh, 302px);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.SearchText {
  height: 65.5%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.SearchTitle {
  font-family: 'Playfair Display', sans-serif;
  font-style: normal;
  font-weight: 900;
  font-size: clamp(42px, 7vh, 56px);
  line-height: clamp(50px, 8.4vh, 75px);
  color: #fff;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.25);
}

.SearchSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: clamp(12px, 1.2vw, 16px);
  line-height: 24px;
  color: #fff;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.25);
}

a.Vocabulary {
  position: relative;
  overflow: hidden;
  color: #fff;
  text-decoration: none;
}

a.Vocabulary:hover {
  font-weight: bold;
  color: #eece25;
}

a.Vocabulary::after {
  position: absolute;
  z-index: -1;
  left: 0;
  bottom: 0;
  background: rgba(238, 206, 37, 0.6);
  content: '';
  width: 100%;
  height: 48%;
  transition: 0.35s;
}

a.Vocabulary:hover::after {
  bottom: 0;
  height: 2px;
  background: rgba(238, 206, 37, 1);
}

.SearchBar {
  width: 80%;
  height: clamp(46px, 24.5%, 72px);
}

.CardsContent {
  position: absolute;
  z-index: 1;
  left: 13vw;
  bottom: 0;
  background: #fcfcfc;
  width: 74vw;
  height: 30%;
  border-radius: 24px;
  padding: 1.6vw;
  display: flex;
  justify-content: space-between;
}

.Card {
  background: #efefef;
  width: 16.5vw;
  height: 100%;
  border-radius: 16px;
  padding: 0 2%;
  text-decoration: none;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.Card:hover {
  background: rgba(238, 206, 37, 0.2);
}

.CardsIcon {
  height: 34%;
  margin-bottom: 6%;
}

.CardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: clamp(14px, 2vh, 16px);
  line-height: clamp(20px, 3.2vh, 24px);
  color: #262626;
  text-align: center;
}
</style>
