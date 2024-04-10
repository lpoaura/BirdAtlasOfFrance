<template>
  <v-container fluid>
    <main class="TopSection breadcrumb">
      <breadcrumb />
      <header>
        <h2 class="black02 fw-600 text-center">
          Comment pouvons-nous vous aider ?
        </h2>
      </header>
    </main>
    <section class="Section">
      <div
        class="ContactCard"
        :class="isSelected ? 'selected' : ''"
        @click="updateIsSelected"
      >
        <span class="fw-500 text-center">
          J'ai une question sur les méthodes de prospection
        </span>
      </div>
      <nuxt-link
        v-for="(card, index) in cards"
        :key="index"
        :to="card.route"
        class="ContactCard"
      >
        <span class="fw-500 text-center">{{ card.title }}</span>
      </nuxt-link>
    </section>
    <section v-show="isSelected" class="HelpingProposalsSection">
      <div class="HelpingProposalsContent">
        <h4 class="black02 fw-500 bottom-margin-16">
          Vous trouverez peut-être votre bonheur dans les pages suivantes :
        </h4>
        <h4 class="green01 fw-500 underline bottom-margin-16">
          <nuxt-link to="/get-involved"> Participer </nuxt-link>
        </h4>
        <h4 class="green01 fw-500 underline bottom-margin-16">
          <nuxt-link to="/about/what-is-ODF-project#get-involved">
            Découvrir les bases de la prospection
          </nuxt-link>
        </h4>
        <nuxt-link
          to="/about/contact/question-about-protocols"
          class="PrimaryButton top-margin-24"
        >
          Contactez-nous
        </nuxt-link>
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
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  methods: {
    updateIsSelected() {
      this.isSelected = true
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}

.TopSection {
  padding: 16px 5% 0;
}

.Section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  grid-gap: 24px;
}

.HelpingProposalsSection {
  padding: 0 5%;
  display: flex;
}

.HelpingProposalsContent {
  margin: auto;
  display: flex;
  flex-direction: column;
}

@media screen and (width <= 680px) {
  .Section {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    grid-gap: 16px;
  }

  .ContactCard {
    height: 130px;
    padding: 0 12px;
  }
}
</style>
