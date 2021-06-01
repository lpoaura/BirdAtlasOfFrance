<!-- Générer automatiquement la page entière (composant/v-show) en fonction des fichiers md récupérés -->
<template>
  <v-container fluid>
    <informative-header
      :logo="logo"
      :title="title"
      :subtitle="subtitle"
      :last-update="lastUpdate"
      :menu-items="menuItems"
      @selectedMenuItem="updateSelectedMenuItem"
    />
    <section class="InformativePageSection">
      <nuxt-content v-show="!selectedMenuItem" :document="pageDescription" />
      <nuxt-content
        v-show="selectedMenuItem === '#get-involved'"
        :document="pageGetInvolved"
      />
      <nuxt-content
        v-show="selectedMenuItem === '#who-we-are'"
        :document="pageWhoWeAre"
      />

      <div
        v-show="selectedMenuItem === '#partners'"
        class="InformativePageContent"
      >
        <h2 class="InformativePageTitle">Nos financeurs</h2>
        <div class="PartnersLogosGrid">
          <div
            v-for="(partner, index) in financialPartnersLogosList"
            :key="index"
            class="PartnersLogosGridItem"
          >
            <img
              class="PartnerLogo"
              :src="`/what-is-ODF-project/partners-logo/${partner}`"
            />
          </div>
        </div>
        <h2 class="InformativePageTitle">Nos partenaires scientifiques</h2>
        <div class="PartnersLogosGrid">
          <div
            v-for="(partner, index) in scientificPartnersLogosList"
            :key="index"
            class="PartnersLogosGridItem"
          >
            <img
              class="PartnerLogo"
              :src="`/what-is-ODF-project/partners-logo/${partner}`"
            />
          </div>
        </div>
        <h2 class="InformativePageTitle">Nos partenaires techniques</h2>
        <div class="PartnersLogosGrid">
          <div
            v-for="(partner, index) in technicalPartnersLogosList"
            :key="index"
            class="PartnersLogosGridItem"
          >
            <img
              class="PartnerLogo"
              :src="`/what-is-ODF-project/partners-logo/${partner}`"
            />
          </div>
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    pageDescription: {},
    pageGetInvolved: {},
    pageWhoWeAre: {},
    financialPartnersLogosList: [
      'Ministere-Transition-Ecologique.jpg',
      'RTE.png',
    ],
    scientificPartnersLogosList: ['MNHN.png', 'OFB.jpg'],
    // Lien vers les sites des partenaires
    technicalPartnersLogosList: [
      'ALEPE.jpg',
      'ANA.png',
      'Bretagne-Vivante.jpg',
      'C.O.Gard.png',
      'Charente-Nature.jpg',
      'Cistude-Nature.jpg',
      'Eure-et-Loir-Nature.jpg',
      'GEPOG.png',
      'GEPOMAY.png',
      'GNLA.png',
      'GODS.jpg',
      'GOG.png',
      'GON.png',
      'GONm.png',
      'GOR.png',
      'Indre-Nature.png',
      'Loiret-Nature-Environnement.jpg',
      'LPO-France.jpg',
      'LPO-AuRA.png',
      'LPO-Bourgogne-Franche-Comte.png',
      'LPO-Bretagne.jpg',
      'LPO-Grand-Est.jpg',
      'LPO-Nord.png',
      'LPO-Normandie.png',
      'LPO-Occitanie.png',
      'LPO-PACA.png',
      'LPO-Pays-de-la-Loire.png',
      'LPO-Touraine.png',
      'Mayenne-Nature-Environnement.jpg',
      'Nature-18.jpg',
      'Nature-Environnement-17.jpg',
      'ODONAT.png',
      'Picardie-Nature.png',
      'SEOF.png',
      'SEOR.gif',
      'SSNTG82.jpg',
    ],
    logo: '',
    title: '',
    subtitle: '',
    lastUpdate: '',
    menuItems: [
      { label: 'Description', route: '' },
      { label: 'Participer', route: '#get-involved' },
      { label: 'Qui sommes-nous ?', route: '#who-we-are' },
      { label: 'Partenaires', route: '#partners' },
    ],
    selectedMenuItem: '',
  }),
  mounted() {
    // this.$content(`fr/what-is-ODF-project`)
    //   .sortBy('order')
    //   .fetch()
    //   .then((test) => {
    //     console.log(test)
    //   })
    //   .catch((error) => {
    //     console.log(error)
    //   })
    this.$content(`fr/what-is-ODF-project/description`)
      .fetch()
      .then((description) => {
        this.pageDescription = description
        this.logo = description.logo
        this.title = description.title
        this.subtitle = description.subtitle
        this.lastUpdate = this.$formatDate(description.updatedAt)
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`fr/what-is-ODF-project/participer`)
      .fetch()
      .then((getInvolved) => {
        this.pageGetInvolved = getInvolved
      })
      .catch((error) => {
        console.log(error)
      })
    this.$content(`fr/what-is-ODF-project/qui-sommes-nous`)
      .fetch()
      .then((whoWeAre) => {
        this.pageWhoWeAre = whoWeAre
      })
      .catch((error) => {
        console.log(error)
      })
  },
  methods: {
    updateSelectedMenuItem(route) {
      this.selectedMenuItem = route
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

.Logo {
  height: 60px;
}

.PartnersLogosGrid {
  width: 100%;
  background: #fff;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 30px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  grid-gap: 60px;
}

.PartnersLogosGridItem {
  display: flex;
}

.PartnerLogo {
  max-width: 100%;
  max-height: 100px;
  margin: auto;
}
</style>
