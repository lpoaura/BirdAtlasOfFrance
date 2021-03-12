<!-- Partenaires -->
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
      <div
        v-if="selectedMenuItem === '#get-involved'"
        class="InformativePageContent"
      >
        <h2 class="InformativePageTitle">Comment participer ?</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Contribuer à Oiseaux de France peut se faire de bien des manières,
            en fonction de votre disponibilité et de vos connaissances
            ornithologiques. Le plus simple est de saisir systématiquement vos
            observations, idéalement par liste complète, en attribuant un code
            de reproduction pour les oiseaux nicheurs.<br /><br />
            <b
              >Transmettre le plus d'EPOC possible est un autre moyen de
              contribuer.</b
            ><br /><br />
            S'engager dans des suivis plus standardisés exige plus de temps et
            une solide connaissance des oiseaux. Mais cet engagement est riche
            de satisfaction et permet d'acquérir une connaissance intime de
            l'avifaune et des milieux que vous prospectez.
          </span>
          <nuxt-link to="/get-involved" class="PrimaryButton"
            >Découvrir les dispositifs</nuxt-link
          >
        </div>
        <img
          class="InformativePagePicture"
          style="width: 64%"
          src="/what-is-ODF-project/protocols-outline.svg"
        />
      </div>
      <div
        v-else-if="selectedMenuItem === '#who-we-are'"
        class="InformativePageContent"
      >
        <h2 class="InformativePageTitle">Un site ODF ?</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Le site
            <nuxt-link to="/">www.oiseauxdefrance.org</nuxt-link> est un portail
            de restitution qui permet de consulter les données collectées dans
            le cadre d’ODF de manière synthétique. Les cartes de répartition
            ainsi que les listes d’espèces notées dans chaque maille sont mises
            à jour en temps réel. Par l’intermédiaire d’un module dédié aux
            prospections, les observateurs peuvent visualiser les secteurs qui
            nécessitent des prospections pour compléter les listes d’espèces ou
            bien ajouter des EPOCs. Par ailleurs, cette plateforme propose des
            fiches descriptives pour chaque espèce, récapitulant l'ensemble des
            connaissances acquises.<br /><br />
            <b
              >La collecte des données se fera toujours sur les outils actuels,
              Faune-France ou NaturaList.</b
            >
          </span>
        </div>
        <div class="InformativePagePicture" style="width: 240px">
          <img class="Logo" src="/what-is-ODF-project/FAUNE-FRANCE-logo.svg" />
          <img class="Logo" src="/what-is-ODF-project/NaturaList-logo.svg" />
        </div>
      </div>
      <div
        v-else-if="selectedMenuItem === '#partners'"
        class="InformativePageContent"
      >
        <h2 class="InformativePageTitle">Coming soon...</h2>
      </div>
      <div v-else class="InformativePageContent">
        <h2 class="InformativePageTitle">Les grandes lignes du projet</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Oiseaux de France (ODF) est le plus ambitieux projet de
            <b>science participative</b> en cours sur les oiseaux. Il vise à
            mettre à jour et diffuser l’état des connaissances de l'avifaune
            française en période de nidification et d'hivernage,
            <b>en France métropolitaine et en Outre-Mer</b>. Une première !
          </span>
        </div>
        <img
          class="InformativePagePicture"
          style="width: 80%"
          src="/what-is-ODF-project/Manakin.svg"
        />
        <span class="InformativePagePictureLegend">
          <b>Manakin à tête d'or</b>, Guyane © Pieter Verheij
        </span>
        <h2 class="InformativePageTitle">
          Connaître la répartition de toutes les espèces
        </h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Il s'agit de cartographier précisément la <b>répartition</b> de
            toutes les espèces de France en période de nidification et
            d'hivernage. En France métropolitaine, les cartes seront restituées
            selon le maillage utilisé par les précédents Atlas, à savoir des
            mailles de 10 x 10 km. Dans les départements et territoires
            ultra-marins, le grain de restitution variera selon les contextes
            locaux.
          </span>
        </div>
        <img
          class="InformativePagePicture"
          style="width: 70%"
          src="/what-is-ODF-project/Atlas-illustration.svg"
        />
        <span class="InformativePagePictureLegend">
          Carte de répartition en période de reproduction du Busard cendré
          (extrait de Issa & Muller 2015)
        </span>
        <h2 class="InformativePageTitle">
          Évaluer les tendances démographiques
        </h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            L'évaluation de la tendance des espèces se basera sur les
            dispositifs de surveillance nationaux existants (STOC, SHOC, STOM,
            Observatoire Rapaces, comptage Wetlands...).
          </span>
        </div>
        <img
          class="InformativePagePicture"
          style="width: 70%"
          src="/what-is-ODF-project/trends-chart.svg"
        />
        <span class="InformativePagePictureLegend" style="margin-bottom: 12px">
          Tendances d’évolution des Oiseaux Communs en fonction des différents
          cortèges
        </span>
        <div class="ChartLegend">
          <span
            v-for="(item, index) in chartLegendItems"
            :key="index"
            class="ChartLegendLabel"
          >
            <i :style="{ background: item.color }"></i>
            {{ item.label }}
          </span>
        </div>
        <h2 class="InformativePageTitle">
          Estimer les tailles des populations
        </h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Il s'agit d'obtenir des effectifs fiables pour un maximum d'espèces.
            En complément des carrés rapaces, de l'enquête LIMAT ou d’autres
            enquêtes ciblant des cortèges d’espèces (hérons coloniaux, oiseaux
            marins nicheurs), une méthode basée sur les EPOC-ODF va être
            déployée pour atteindre cet ambitieux objectif.
          </span>
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
import InformativeHeader from '~/components/InformativeHeader.vue'

export default {
  components: {
    'informative-header': InformativeHeader,
  },
  data: () => ({
    logo: '/ODF-logo-detailed.svg',
    title: 'Le projet ODF',
    subtitle: 'Répartitions, Tendances et Effectifs',
    lastUpdate: '7 janvier 2021',
    menuItems: [
      { label: 'Description', routerPath: '' },
      { label: 'Participer', routerPath: '#get-involved' },
      { label: 'Qui sommes-nous ?', routerPath: '#who-we-are' },
      { label: 'Partenaires', routerPath: '#partners' },
    ],
    selectedMenuItem: '',
    chartLegendItems: [
      { label: 'Généralistes', color: '#CE1717' },
      { label: 'Milieux forestiers', color: '#0BCCCC' },
      { label: 'Toutes espèces', color: '#70149F' },
      { label: 'Milieux bâtis', color: '#6E9D9D' },
      { label: 'Milieux agricoles', color: '#167216' },
    ],
  }),
  methods: {
    updateSelectedMenuItem(routerPath) {
      this.selectedMenuItem = routerPath
    },
  },
  head: {
    title: 'ODF quésaco ?',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 80px;
}

.ChartLegend {
  width: 100%;
  margin-bottom: 30px;
  display: flex;
  justify-content: center;
}

.ChartLegend i {
  width: 14px;
  height: 14px;
  border-radius: 2px;
  float: left;
  margin-right: 8px;
}

.ChartLegendLabel {
  margin-right: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 10px;
  line-height: 15px;
  color: #000;
  white-space: nowrap;
}

.PrimaryButton {
  background: #39765a;
  border-radius: 8px;
  padding: 1.6vh 1.8vw;
  margin-top: 3vh;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  text-decoration: none;
  font-size: 12px;
  line-height: 18px;
  color: #fcfcfc;
}

.Logo {
  height: 60px;
}
</style>
