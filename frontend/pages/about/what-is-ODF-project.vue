<template>
  <v-container fluid>
    <header>
      <div class="HeaderContent">
        <img class="ODFLogo" src="/ODF-logo-detailed.svg" />
        <div class="HeaderText">
          <h1 class="HeaderTitle">Le projet ODF</h1>
          <h6 class="HeaderSubtitle">Répartitions, Tendances et Effectifs</h6>
        </div>
      </div>
      <div class="HeaderMenu">
        <span class="HeaderLastUpdate">
          Dernière actualisation le 7 janvier 2020
        </span>
        <menu>
          <span
            v-for="(item, index) in menuItems"
            :key="index"
            :to="item.routerPath"
            class="MenuItem"
            :class="[item.routerPath === selectedMenuItem ? 'selected' : '']"
            @click="updateSelectedMenuItem(item)"
          >
            {{ item.label }}
          </span>
        </menu>
      </div>
    </header>
    <section class="PageSection">
      <div v-if="selectedMenuItem === '#get-involved'" class="PageContent">
        <h2 class="PageTitle">Comment participer ?</h2>
        <div class="PageText">
          <span>
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
          class="Picture"
          style="width: 64%"
          src="/what-is-ODF-project/protocols-outline.svg"
        />
      </div>
      <div v-else-if="selectedMenuItem === '#who-we-are'" class="PageContent">
        <h2 class="PageTitle">Un site ODF ?</h2>
        <div class="PageText">
          <span>
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
        <div class="Picture" style="width: 240px">
          <img class="Logo" src="/what-is-ODF-project/FAUNE-FRANCE-logo.svg" />
          <img class="Logo" src="/what-is-ODF-project/NaturaList-logo.svg" />
        </div>
      </div>
      <div v-else-if="selectedMenuItem === '#partners'" class="PageContent">
        <h2 class="PageTitle">Coming soon...</h2>
      </div>
      <div v-else class="PageContent">
        <h2 class="PageTitle">Les grandes lignes du projet</h2>
        <div class="PageText">
          <span>
            Oiseaux de France (ODF) est le plus ambitieux projet de
            <b>science participative</b> en cours sur les oiseaux. Il vise à
            mettre à jour et diffuser l’état des connaissances de l'avifaune
            française en période de nidification et d'hivernage,
            <b>en France métropolitaine et en Outre-Mer</b>. Une première !
          </span>
        </div>
        <img
          class="Picture"
          style="width: 80%"
          src="/what-is-ODF-project/Manakin.svg"
        />
        <span class="PictureLegend">
          <b>Manakin à tête d'or</b>, Guyane © Pieter Verheij
        </span>
        <h2 class="PageTitle">
          Connaître la répartition de toutes les espèces
        </h2>
        <div class="PageText">
          <span>
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
          class="Picture"
          style="width: 70%"
          src="/what-is-ODF-project/Atlas-illustration.svg"
        />
        <span class="PictureLegend">
          Carte de répartition en période de reproduction du Busard cendré
          (extrait de Issa & Muller 2015)
        </span>
        <h2 class="PageTitle">Évaluer les tendances démographiques</h2>
        <div class="PageText">
          <span>
            L'évaluation de la tendance des espèces se basera sur les
            dispositifs de surveillance nationaux existants (STOC, SHOC, STOM,
            Observatoire Rapaces, comptage Wetlands...).
          </span>
        </div>
        <img
          class="Picture"
          style="width: 70%"
          src="/what-is-ODF-project/trends-chart.svg"
        />
        <span class="PictureLegend" style="margin-bottom: 12px">
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
        <h2 class="PageTitle">Estimer les tailles des populations</h2>
        <div class="PageText">
          <span>
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
export default {
  data: () => ({
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
  mounted() {
    this.selectedMenuItem = this.$route.hash
  },
  methods: {
    updateSelectedMenuItem(item) {
      this.selectedMenuItem = item.routerPath
      this.$router.push(`${item.routerPath}`)
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

header {
  background: #fcfcfc;
  border-bottom: 1px solid rgba(51, 105, 80, 0.2);
  width: 100%;
  height: 254px;
  padding: 2.4% 16%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.HeaderContent {
  width: 100%;
  display: flex;
  align-items: center;
}

.ODFLogo {
  width: 130px;
  margin-right: 3%;
  border: 4px solid rgba(0, 0, 0, 0.05);
  box-sizing: border-box;
  border-radius: 24px;
}

.HeaderText {
  height: 60%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.HeaderTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 40px;
  line-height: 60px;
  color: #262626;
}

.HeaderSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 300;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
}

.HeaderMenu {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.HeaderLastUpdate {
  width: 50%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: rgba(38, 38, 38, 0.4);
}

menu {
  display: flex;
  justify-content: flex-end;
}

.MenuItem {
  border-radius: 8px;
  padding: 2.5% 5%;
  margin-left: 1%;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  text-decoration: none;
  font-size: 14px;
  line-height: 21px;
  color: #000;
  white-space: nowrap;
}

.MenuItem.selected {
  background: rgba(57, 118, 90, 0.1);
  font-weight: bold;
  color: #39765a;
}

.PageSection {
  background: rgba(57, 118, 90, 0.1);
  width: 100%;
  min-height: calc(100vh - 334px);
  padding: 1% 16%;
}

.PageContent {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.PageTitle {
  width: 100%;
  margin: 10px 0 20px 0;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 16px;
  line-height: 24px;
  color: #000;
}

.PageText {
  width: 100%;
  background: #fcfcfc;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  padding: 2.8vh 2.8vh;
  margin-bottom: 30px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.Picture {
  margin-bottom: 12px;
  display: flex;
  justify-content: space-between;
}

.PictureLegend {
  margin-bottom: 30px;
  font-family: 'Poppins', sans-serif;
  font-style: italic;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #000;
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
