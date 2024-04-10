<template>
  <v-container fluid>
    <!-- <img
      class="Test"
      src="/about/about-picture.webp"
    /> -->
    <main class="TopSection">
      <header>
        <h1 class="white02 fw-bold text-center">À propos</h1>
      </header>
      <h6 class="TopSectionPictureCredit white01 fw-300">
        Photo : Canards pilets, Emile Barbelette
      </h6>
    </main>
    <section class="Section">
      <div class="MenuCardsContent">
        <nuxt-link
          v-for="(card, index) in cards"
          :key="index"
          :to="card.route"
          class="MenuCard"
        >
          <img class="CardIcon" :src="card.icon" />
          <h4 class="CardTitle fw-500 text-center bottom-margin-8">
            {{ card.title }}
          </h4>
          <h5 class="black03 text-center">{{ card.subtitle }}</h5>
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
            :src="question.isOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
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
        icon: '/information.svg',
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
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  methods: {
    updateQuestionStatus(index) {
      this.questions[index].isOpen = !this.questions[index].isOpen
    },
  },
}
</script>

<style scoped>
/* img.Test {
  width: 100%;
  height: 580px;
  object-fit: cover;
  object-position: center;
} */

.TopSection {
  position: relative;
  height: 410px;
  background: linear-gradient(
      180deg,
      rgba(85, 75, 57, 0.6) 0%,
      rgba(85, 75, 57, 0) 100%
    ),
    url('/about/about-picture.webp') center / cover, rgba(85, 75, 57, 1);
}

.TopSectionPictureCredit {
  bottom: 140px;
}

.Section {
  padding: 0;
  align-items: center;
}

.MenuCardsContent {
  position: relative; /* Permet d'avoir un z-index supérieur à TopSection qui est relative aussi */
  height: 260px;
  margin-top: -130px;
}

.CardIcon {
  height: 48px;
}

/* .QuestionsSection {
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
} */

/********** RESPONSIVE **********/

@media screen and (width <= 920px) {
  .TopSectionPictureCredit {
    width: 90%;
    left: 5%;
  }

  .MenuCardsContent {
    width: 90%;
  }

  .MenuCard {
    padding: 12px;
  }
}

@media screen and (width <= 680px) {
  .TopSection {
    height: 270px;
  }

  .TopSectionPictureCredit {
    bottom: 75px;
    text-align: center;
  }

  .MenuCardsContent {
    width: 378px;
    height: auto;
    max-width: calc(100vw + 24px);
    margin-top: -65px;
    flex-direction: column;
  }

  .MenuCard {
    padding: 32px 24px;
  }

  h4.CardTitle {
    font-size: 16px;
    line-height: 24px;
  }
}

@media screen and (width <= 400px) {
  .TopSectionPictureCredit {
    bottom: 10px;
    text-align: right;
  }

  .MenuCardsContent {
    margin-top: 0;
  }
}
</style>
