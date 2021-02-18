<template>
  <v-container fluid>
    <div class="ReverseImage"></div>
    <div class="OriginalImage"></div>
    <div class="ImageFilter"></div>
    <section class="SearchSection">
      <div class="SearchContent">
        <div class="SearchText">
          <div class="SearchTitle">
            Explorer l'Atlas<br />des Oiseaux de France
          </div>
          <div class="SearchSubtitle">
            (Re)découvrez les oiseaux présents sur le territoire français, et
            les mailles près de chez vous
          </div>
        </div>
        <div class="SearchBar">
          <search-bar />
        </div>
      </div>
    </section>
    <section class="CardsSection">
      <div class="CardsContent">
        <router-link to="#" class="Card">
          <img class="CardsIcon" src="/book.svg" />
          <div class="CardsTitle">Consulter les fiches espèces</div>
        </router-link>
        <router-link to="/prospecting" class="Card">
          <img class="CardsIcon" src="/prospecting.svg" />
          <div class="CardsTitle">Voir la carte de prospection</div>
        </router-link>
        <router-link to="/get-involved" class="Card">
          <img class="CardsIcon" src="/protocol.svg" />
          <div class="CardsTitle">Découvrir les protocoles</div>
        </router-link>
        <router-link to="/what-is-ODF-project" class="Card">
          <img class="CardsIcon" src="/ODF.svg" />
          <div class="CardsTitle">
            Qu'est-ce que le projet Oiseaux de France ?
          </div>
        </router-link>
      </div>
    </section>
    <section class="KeyDataSection">
      <div class="KeyDataTitle">L'Atlas en quelques chiffres...</div>
      <div class="KeyDataContent">
        <div class="KeyDataCard">
          <div class="KeyDataBlock">
            <img class="KeyDataBlockIcon" src="/species-number.svg" />
            <div class="KeyDataBlockContent">
              <div class="KeyDataBlockData">???</div>
              <div class="KeyDataBlockText" style="text-align: center">
                espèces recensées<br />sur la période 2019 - 2023
              </div>
            </div>
          </div>
          <div class="KeyDataBlock">
            <div class="KeyDataBlockDetails">
              <img
                class="KeyDataBlockDetailsIcon"
                src="/breeding-species-number.svg"
              />
              <div class="KeyDataBlockDetailsContent">
                <div class="KeyDataBlockDetailsData">???</div>
                <div class="KeyDataBlockText">espèces nicheuses</div>
              </div>
            </div>
            <div class="KeyDataBlockDetails">
              <img
                class="KeyDataBlockDetailsIcon"
                src="/winter-species-number.svg"
              />
              <div class="KeyDataBlockDetailsContent">
                <div class="KeyDataBlockDetailsData">???</div>
                <div class="KeyDataBlockText">espèces hivernantes</div>
              </div>
            </div>
          </div>
        </div>
        <div class="KeyDataCard">
          <div class="KeyDataBlock">
            <div class="KeyDataBlockIcon" style="color: red">
              Graphe à venir...
            </div>
            <div class="KeyDataBlockContent">
              <div class="KeyDataBlockData">???</div>
              <div class="KeyDataBlockText" style="text-align: center">
                heures de prospection<br />sur la période 2019 - 2023
              </div>
            </div>
          </div>
          <div class="KeyDataBlock">
            <div class="KeyDataBlockDetails">
              <div
                class="KeyDataBlockDetailsDot"
                style="background-color: #2a9d8f"
              ></div>
              <div class="KeyDataBlockDetailsContent">
                <div class="KeyDataBlockText" style="font-weight: 500">
                  Période de reproduction
                </div>
                <div class="KeyDataBlockText">??% | ???? heures</div>
              </div>
            </div>
            <div class="KeyDataBlockDetails">
              <div
                class="KeyDataBlockDetailsDot"
                style="background-color: #264653"
              ></div>
              <div class="KeyDataBlockDetailsContent">
                <div class="KeyDataBlockText" style="font-weight: 500">
                  Période d'hivernage
                </div>
                <div class="KeyDataBlockText">??% | ???? heures</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
import SearchBar from '~/components/Home/SearchBar.vue'

export default {
  // async asyncData({ $content }) {
  //   const news1 = await $content('news/news-1').fetch()
  //   return { news1 }
  // },
  components: {
    'search-bar': SearchBar,
  },
  head: {
    title: 'Accueil',
  },
}
</script>

<style scoped>
.container--fluid {
  padding: 0;
}

.ReverseImage {
  position: absolute;
  background-image: url('/home-picture-1.jpg');
  width: 540px;
  height: 735px;
}

.OriginalImage {
  position: absolute;
  background-image: url('/home-picture-2.jpg');
  width: 901px;
  height: 735px;
  left: 540px;
}

.ImageFilter {
  position: absolute;
  z-index: 1;
  background: linear-gradient(
      180deg,
      rgba(8, 43, 8, 0.95) 0%,
      rgba(8, 43, 8, 0.75) 10.25%,
      rgba(8, 43, 8, 0.2) 20.95%,
      rgba(8, 43, 8, 0.2) 31.47%,
      rgba(8, 43, 8, 0.2) 100%
    ),
    linear-gradient(
      89.84deg,
      rgba(8, 43, 8, 0.7) 0.14%,
      rgba(8, 43, 8, 0.7) 37.28%,
      rgba(8, 43, 8, 0) 74.41%,
      rgba(8, 43, 8, 0.21) 99.86%
    );
  width: 100%;
  height: 735px;
}

.SearchSection {
  position: absolute;
  z-index: 6;
  width: 100%;
  height: 735px;
  display: flex;
}

.SearchContent {
  position: relative;
  width: 64%;
  height: 302px;
  margin: auto;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.SearchText {
  height: 182px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.SearchTitle {
  font-family: 'Playfair Display', sans-serif;
  font-style: normal;
  font-weight: 900;
  font-size: 56px;
  line-height: 75px;
  color: #fff;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.25);
}

.SearchSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: #fff;
}

.SearchBar {
  width: 80%;
  height: 72px;
  position: relative;
}

.CardsSection {
  position: relative;
  width: 100%;
  height: 856px;
  display: flex;
  justify-content: center;
  align-items: flex-end;
}

.CardsContent {
  position: absolute;
  z-index: 3;
  background: #fcfcfc;
  width: 74%;
  height: 242px;
  border-radius: 24px;
  padding: 0 2%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.Card {
  background: #efefef;
  width: 22.5%;
  height: 194px;
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
  height: 48px;
  margin-bottom: 8%;
}

.CardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  text-align: center;
}

.KeyDataSection {
  width: 100%;

  /* À MODIFIER */
  height: 470px;

  /* À modifier en : padding: 3.5% 5%; */
  padding: 0 5% 3.5% 5%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.KeyDataTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
}

.KeyDataContent {
  display: flex;
  justify-content: space-between;
}

.KeyDataCard {
  background: rgba(57, 118, 90, 0.1);
  width: 49%;
  height: 354px;
  border-radius: 12px;
  padding: 1.8% 2.5%;
  display: flex;
  justify-content: space-between;
}

.KeyDataBlock {
  width: 49%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
}

.KeyDataBlockIcon {
  height: 188px;
}

.KeyDataBlockContent {
  height: 92px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.KeyDataBlockData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
}

.KeyDataBlockText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
}

.KeyDataBlockDetails {
  background: rgba(57, 118, 90, 0.1);
  width: 100%;
  height: 48%;
  border-radius: 8px;
  padding-left: 10%;
  padding-right: 2%;
  display: flex;
  align-items: center;
}

.KeyDataBlockDetailsIcon {
  height: 52px;
  margin-right: 8%;
}

.KeyDataBlockDetailsDot {
  min-width: 12px;
  max-width: 12px;
  min-height: 12px;
  max-height: 12px;
  border-radius: 50%;
  margin-right: 8%;
}

.KeyDataBlockDetailsContent {
  display: flex;
  flex-direction: column;
}

.KeyDataBlockDetailsData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 24px;
  line-height: 36px;
}
</style>
