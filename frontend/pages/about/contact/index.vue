<template>
  <v-container fluid>
    <header>
      <breadcrumb style="margin-bottom: 20px" />
      <h1 class="PageTitle">Comment pouvons-nous vous aider ?</h1>
    </header>
    <section class="CardsSection">
      <div
        class="Card"
        :class="isSelected ? 'selected' : ''"
        @click="updateIsSelected"
      >
        <h6 class="CardsTitle">
          J'ai une question sur les méthodes de prospection
        </h6>
      </div>
      <nuxt-link
        v-for="(card, index) in cards"
        :key="index"
        :to="card.route"
        class="Card"
      >
        <h6 class="CardsTitle">{{ card.title }}</h6>
      </nuxt-link>
    </section>
    <section v-show="isSelected" class="ProtocolsHelpSection">
      <div class="ProtocolsHelpContent">
        <p>Vous trouverez peut-être votre bonheur dans les pages suivantes :</p>
        <li class="ProtocolsHelpLink">
          <nuxt-link to="/get-involved" style="text-decoration: underline"
            >Participer</nuxt-link
          >
        </li>
        <li class="ProtocolsHelpLink">
          <nuxt-link
            to="/about/what-is-ODF-project#get-involved"
            style="text-decoration: underline"
            >Découvrir les bases de la prospection</nuxt-link
          >
        </li>
        <nuxt-link
          to="/about/contact/question-about-protocols"
          class="PrimaryButton"
          style="margin-top: 24px"
          >Contactez-nous</nuxt-link
        >
      </div>
    </section>
  </v-container>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
  },
  data: () => ({
    cards: [
      {
        title: 'Je souhaite avoir des renseignements sur le projet ODF',
        route: '/about/contact/information-about-ODF-project',
      },
      {
        title: 'Je souhaite contacter un référent local',
        route: '/about/contact/get-in-touch-with-coordinator',
      },
      {
        title: "J'aimerais vous faire part de retours sur le site",
        route: '/about/contact/feedback-about-website',
      },
      { title: 'Autre demande', route: '/about/contact/other' },
    ],
    isSelected: false,
  }),
  methods: {
    updateIsSelected() {
      this.isSelected = true
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
div.container.container--fluid {
  padding-top: 68px;
}

header {
  width: 100%;
  padding: 24px 4vw 40px 4vw;
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

.CardsSection {
  padding-left: 4vw;
  padding-bottom: 24px;
  display: flex;
  flex-wrap: wrap;
}

.Card {
  background: #efefef;
  width: 17vw;
  height: 155px;
  border-radius: 16px;
  margin-right: 1.45vw;
  margin-bottom: 1.45vw;
  padding: 0 2%;
  text-decoration: none;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.Card:hover {
  background: rgba(238, 206, 37, 0.2);
}

.Card.selected {
  background: rgba(238, 206, 37, 0.2);
  border: 3px solid #eece25;
}

.CardsTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  text-align: center;
  color: #262626;
}

.ProtocolsHelpSection {
  display: flex;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 16px;
  line-height: 24px;
  color: #000;
}

.ProtocolsHelpContent {
  margin: auto;
  display: flex;
  flex-direction: column;
}

.ProtocolsHelpLink {
  list-style: none;
  margin-bottom: 16px;
}
</style>
