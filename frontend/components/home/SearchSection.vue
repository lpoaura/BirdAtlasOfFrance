<template>
  <main class="TopSection">
    <div class="HomePicture">
      <div class="HomePictureGradient"></div>
      <div class="TopSectionContent">
        <header>
          <h1 class="PlayfairDisplayTypo">
            Explorer l'Atlas<br />des Oiseaux de France
          </h1>
          <h4 class="white01 fw-600">
            (Re)découvrez les oiseaux présents sur le territoire français, leurs
            répartitions, tendances et effectifs
          </h4>
        </header>
        <div class="SearchBar">
          <search-bar />
        </div>
      </div>
    </div>
    <h6 class="PictureCredit white01 fw-300">
      Photo : Phatéon à bec jaune, Florent Bignon
    </h6>
    <div class="MenuCardsContent">
      <nuxt-link
        v-for="(card, index) in cards"
        :key="index"
        :to="card.route"
        class="MenuCard"
      >
        <img class="CardIcon" :src="card.icon" />
        <h4 class="CardTitle fw-500 text-center" v-html="card.title"></h4>
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
      // {
      //   icon: '/book.svg',
      //   title: 'Consulter les<br />fiches espèces',
      //   route: '#',
      // },
      {
        icon: '/prospecting.svg',
        title: 'Voir la carte<br />de prospection',
        route: '/prospecting',
      },
      {
        icon: '/protocol.svg',
        title: 'Découvrir<br />les dispositifs',
        route: '/get-involved',
      },
      {
        icon: '/ODF.svg',
        title: 'Le projet Oiseaux<br />de France',
        route: '/about/what-is-ODF-project',
      },
    ],
  }),
}
</script>

<style scoped>
.TopSection {
  position: relative;

  /* height: clamp(580px, 94vh, 784px); */
  min-height: 580px;
  height: 94vh;
  max-height: 784px;
  align-items: flex-start;
}

.HomePicture {
  position: relative;
  background: linear-gradient(
      101.98deg,
      #3957a4 0%,
      rgba(57, 87, 164, 0) 69.37%
    ),
    url('/home/home-picture.jpg') center / cover, #3957a4;
  width: 100%;
  height: 86%;
  display: flex;
}

.HomePictureGradient {
  position: absolute;
  z-index: 1;
  background: linear-gradient(
    185.18deg,
    #3957a4 -29.97%,
    rgba(57, 87, 164, 0) 64.13%
  );
  width: 100%;
  height: 60%;
}

.TopSectionContent {
  position: absolute;
  z-index: 5;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  width: 64%;
  min-width: 820px;
  max-width: 1020px;
  height: 48%;
  min-height: 272px;
  max-height: 282px;
}

.SearchBar /* Évite que la barre de recherche ne remonte (car position: absolute) */ {
  width: 710px;
  height: 60px;
}

.PictureCredit {
  position: absolute;
  z-index: 1;
  left: max(12%, calc((100% - 1200px) / 2));
  bottom: 29%;
  width: 76%;
  max-width: 1200px;
  text-align: right;
}

.MenuCardsContent {
  position: absolute;
  z-index: 1;
  left: max(12%, calc((100% - 1200px) / 2));
  bottom: 0;
  background: #fcfcfc;
  width: 76%;
  max-width: 1200px;
  height: 28%;
  border-radius: 24px;
  padding: 12px;
  display: flex;
}

.MenuCard {
  flex: 1;
}

.CardIcon {
  height: 40%;
  min-height: 30px;
  max-height: 48px;
  margin-bottom: 1.2vh;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 920px) {
  .HomePicture /* Recentrer l'image d'accueil */ {
    background: linear-gradient(
        101.98deg,
        #3957a4 0%,
        rgba(57, 87, 164, 0) 69.37%
      ),
      url('/home/home-picture.jpg') 66% / cover, #3957a4;
  }

  .TopSectionContent {
    width: 86%;
    min-width: 0;
  }

  .SearchBar {
    width: 100%;
    max-width: 710px;
  }

  h4.CardTitle {
    font-size: 14px;
    line-height: 21px;
  }
}

@media screen and (max-width: 680px) {
  .TopSection {
    height: 380px;
    min-height: 0;
  }

  .HomePicture /* Modifier l'image d'accueil sur mobile */ {
    height: 100%;
    background: linear-gradient(
        101.98deg,
        #3957a4 0%,
        rgba(57, 87, 164, 0) 69.37%
      ),
      url('/home/home-picture-mobile.jpg') 70% / cover, #3957a4;
  }

  .HomePictureGradient {
    height: 100%;
  }

  .TopSectionContent {
    height: 56%;
    min-height: 202px;
  }

  h4.fw-600 {
    font-weight: normal;
  }

  .SearchBar {
    height: 50px;
  }

  .PictureCredit {
    left: 7%;
    bottom: 8px;
    width: 86%;
  }

  .MenuCardsContent {
    display: none;
  }
}

@media screen and (max-width: 340px) {
  .TopSectionContent {
    min-height: 240px;
  }
}

@media screen and (max-height: 650px) {
  h4.CardTitle {
    font-size: 14px;
    line-height: 21px;
  }
}
</style>
