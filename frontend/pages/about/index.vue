<template>
  <v-container fluid>
    <section class="IntroSection">
      <div class="BackgroundPicture">
        <header class="IntroContent">
          <h1 class="IntroTitle">À propos</h1>
        </header>
      </div>
      <div class="PictureAuthor">Photo : Canards pilets, Emile Barbelette</div>
      <div class="CardsContent">
        <nuxt-link
          v-for="(card, index) in cards"
          :key="index"
          :to="card.route"
          class="Card"
        >
          <img class="CardsIcon" :src="card.icon" />
          <h6 class="CardsTitle">{{ card.title }}</h6>
          <span class="CardsSubtitle">{{ card.subtitle }}</span>
        </nuxt-link>
      </div>
    </section>
    <!-- <section class="QuestionsSection">
      <h2 class="QuestionsTitle">Questions fréquentes</h2>
      <div
        v-for="question in questions"
        :key="question.index"
        class="QuestionsBlock"
      >
        <div
          class="QuestionsContent"
          @click="updateQuestionStatus(question.index)"
        >
          <span class="QuestionsText">{{ question.label }}</span>
          <img
            class="QuestionsChevron"
            :src="
              question.isOpen
                ? '/chevron-up.svg'
                : '/chevron-down.svg'
            "
          />
        </div>
        <span v-show="question.isOpen" class="ResponsesText">{{
          question.response
        }}</span>
      </div>
    </section> -->
  </v-container>
</template>

<script>
export default {
  data: () => ({
    cards: [
      {
        icon: '/ODF.svg',
        title: 'Le projet ODF',
        subtitle:
          'Découvrez le projet Oiseaux de France, ses objectifs, ses acteurs et ses partenaires.',
        route: '/about/what-is-ODF-project',
      },
      {
        icon: '/mail.svg',
        title: 'Nous contacter',
        subtitle:
          'Une question ? Contactez la coordination nationale ou votre référent local.',
        route: '/about/contact',
      },
      // {
      //   icon: '/protocol.svg',
      //   title: 'Comment participer ?',
      //   subtitle:
      //     'Consultez les méthodes d’inventaire et les dispositifs de suivi.',
      //   route: '/get-involved',
      // },
      {
        icon: '/glossary.svg',
        title: 'Lexique',
        subtitle:
          'Retrouvez ici toutes les définitions des mots utilisés sur le projet ODF.',
        route: '/about/glossary',
      },
    ],
    questions: [
      {
        index: 0,
        label: "Comment participer à l'Atlas ?",
        response: 'Réponse',
        isOpen: false,
      },
      {
        index: 1,
        label: 'Question ?',
        response: 'Réponse',
        isOpen: false,
      },
      {
        index: 2,
        label: 'Question ?',
        response: 'Réponse',
        isOpen: false,
      },
    ],
    selectedQuestion: null,
  }),
  methods: {
    updateQuestionStatus(index) {
      this.questions[index].isOpen = !this.questions[index].isOpen
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
.IntroSection {
  position: relative;
  width: 100%;
  height: 536px;
}

.BackgroundPicture {
  position: relative;
  background: linear-gradient(
      180deg,
      rgba(85, 75, 57, 0.6) 0%,
      rgba(85, 75, 57, 0) 100%
    ),
    url('/about/about-picture.jpg') center / cover, rgba(85, 75, 57, 1);
  width: 100%;
  height: 410px;
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
}

.IntroTitle {
  margin: auto;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 40px;
  line-height: 60px;
  text-align: center;
  color: #fcfcfc;
}

.PictureAuthor {
  position: absolute;
  z-index: 1;
  left: 12.5vw;
  bottom: 260px;
  width: 73.9vw;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 300;
  font-size: 10px;
  line-height: 15px;
  text-align: right;
  color: #fff;
}

.CardsContent {
  position: absolute;
  z-index: 1;
  left: 12.5vw;
  bottom: 0;
  background: #fcfcfc;
  width: 73.9vw;
  height: 252px;
  border-radius: 24px;
  padding: 1.3vw;
  display: flex;
  justify-content: space-between;
}

.Card {
  background: #efefef;
  width: 22.9vw;
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
  height: 48px;
  margin-bottom: 6%;
}

.CardsTitle {
  margin-bottom: 4%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
  text-align: center;
  white-space: nowrap;
}

.CardsSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  text-align: center;
  color: rgba(38, 38, 38, 0.6);
}

.QuestionsSection {
  background: rgba(57, 118, 90, 0.1);
  width: 100%;
  padding: 0 22% 20px 22%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.QuestionsTitle {
  margin: 32px 0;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
  color: #262626;
}

.QuestionsBlock {
  width: 100%;
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.QuestionsContent {
  width: 100%;
  margin-bottom: 20px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
}

.QuestionsText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: #262626;
}

.QuestionsChevron {
  width: 11px;
}

.ResponsesText {
  width: 100%;
  margin-bottom: 20px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}
</style>
