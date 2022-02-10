<template>
  <main class="TopSection">
    <div class="TopSectionPicture">
      <!-- <div
      class="TopSectionPicture"
      :style="{
        '--largeUrl': homePicture.largeUrl,
        '--mobileUrl': homePicture.mobileUrl,
        '--largeFocus': `${homePicture.largeFocus}%`,
        '--mobileFocus': `${homePicture.mobileFocus}%`,
      }"
    > -->
      <div class="PictureGradient"></div>
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
    <h6 class="TopSectionPictureCredit white01 fw-300">
      <!-- Photo : {{ homePicture.title }}, {{ homePicture.author }} -->
      Photo : Phaéton à bec jaune, Florent Bignon
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
// const ExifReader = require('exifreader')

export default {
  components: {
    'search-bar': SearchBar,
  },
  data: () => ({
    randomInt: 0,
    homePicture: {
      title: '',
      author: '',
      largeUrl: '',
      mobileUrl: '',
      largeFocus: 0,
      mobileFocus: 0,
    },
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
  // created() {
  //   this.randomInt = Math.floor(Math.random() * 5)
  //   console.log(this.randomInt)
  //   // this.randomInt = 5
  //   this.homePicture.largeUrl = `url('/home/home-picture-${this.randomInt}.webp')`
  //   this.homePicture.mobileUrl = `url('/home/home-picture-${this.randomInt}-mobile.webp')`
  //   ExifReader.load(`/home/home-picture-${this.randomInt.toString()}.webp`).then(
  //     (tags) => {
  //       this.homePicture.title = tags.title.description
  //       this.homePicture.author = tags.creator.description.replace(
  //         'type="Seq" ',
  //         ''
  //       )
  //       // console.log(tags)
  //       // console.log(this.homePicture.title)
  //       // console.log(this.homePicture.author)
  //       // console.log(JSON.parse(tags.description.description))
  //       const focusing = JSON.parse(tags.description.description)
  //       this.homePicture.largeFocus = focusing.large
  //       this.homePicture.mobileFocus = focusing.mobile
  //     }
  //   )
  // },
}
</script>

<style scoped>
.TopSection {
  position: relative;
  min-height: 580px;
  height: 94vh;
  max-height: 784px;
  align-items: flex-start;
}

.TopSectionPicture {
  position: relative;
  background: linear-gradient(
      101.98deg,
      #3957a4 0%,
      rgba(57, 87, 164, 0) 69.37%
    ),
    url('/home/home-picture-0.webp') center / cover, #3957a4;

  /* var(--largeUrl) center / cover, #3957a4; */
  width: 100%;
  height: 86%;
  display: flex;
  justify-content: center;
}

.PictureGradient {
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

.TopSectionPictureCredit {
  bottom: 29%;
}

.MenuCardsContent {
  position: absolute;
  z-index: 1;
  left: max(12%, calc((100% - 1200px) / 2));
  bottom: 0;
  height: 28%;
}

.CardIcon {
  height: 40%;
  min-height: 30px;
  max-height: 48px;
  margin-bottom: 1.2vh;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 920px) {
  .TopSectionPicture /* Recentrer l'image d'accueil */ {
    background: linear-gradient(
        101.98deg,
        #3957a4 0%,
        rgba(57, 87, 164, 0) 69.37%
      ),
      url('/home/home-picture-0.webp') 66% / cover, #3957a4;

    /* var(--largeUrl) var(--largeFocus) / cover, #3957a4;
    var(--largeUrl) 100% / cover, #3957a4; */
  }

  .TopSectionContent {
    width: 86%;
    min-width: 0;
  }

  .SearchBar {
    width: 100%;
    max-width: 710px;
  }

  .TopSectionPictureCredit,
  .MenuCardsContent {
    width: 90%;
    left: 5%;
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

  .TopSectionPicture /* Modifier l'image d'accueil sur mobile */ {
    height: 100%;
    background: linear-gradient(
        101.98deg,
        #3957a4 0%,
        rgba(57, 87, 164, 0) 69.37%
      ),
      url('/home/home-picture-0-mobile.webp') 70% / cover, #3957a4;

    /* var(--mobileUrl) var(--mobileFocus) / cover, #3957a4;
    var(--mobileUrl) 100% / cover, #3957a4; */
  }

  .PictureGradient {
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

  .TopSectionPictureCredit {
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
