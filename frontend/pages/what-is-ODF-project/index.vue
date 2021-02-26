<template>
  <v-container fluid>
    <header>
      <div class="HeaderContent">
        <img class="ODFLogo" src="/ODF-logo-detailed.svg" />
        <div class="HeaderText">
          <div class="HeaderTitle">Le projet ODF</div>
          <div class="HeaderSubtitle">Oiseaux de France</div>
        </div>
      </div>
      <div class="HeaderMenu">
        <div class="HeaderLastUpdate">
          Dernière actualisation le 7 janvier 2020
        </div>
        <menu>
          <div
            v-for="(item, index) in menuItems"
            :key="index"
            class="MenuItem"
            :style="[
              item === selectedMenuItem
                ? {
                    'background-color': 'rgba(57, 118, 90, 0.1)',
                    color: '#39765a',
                    'font-weight': 'bold',
                  }
                : {
                    color: '#000000',
                    'font-weight': 'normal',
                  },
            ]"
            @click="updateSelectedMenuItem(item)"
          >
            {{ item }}
          </div>
        </menu>
      </div>
    </header>
    <section class="PageSection">
      <div v-if="selectedMenuItem === 'Description'" class="PageContent">
        <div class="PageTitle">Les grandes lignes du projet</div>
        <div class="PageText">
          Oiseaux de France (ODF) est le plus ambitieux projet de science
          participative en cours sur les oiseaux. Il vise à mettre à jour et
          diffuser l’état des connaissances de l'avifaune française en période
          de nidification et d'hivernage, en métropole et en Outre-Mer. Une
          première !
        </div>
        <img style="width: 80%" src="/what-is-ODF-project/Manakin.svg" />
        <div class="PageTitle">
          Connaître la répartition de toutes les espèces
        </div>
        <div class="PageText">
          Il s'agit de cartographier précisément la répartition de toutes les
          espèces de France en période de nidification et d'hivernage. En
          métropole, les cartes seront restituées selon selon le maillage
          utilisé par les précédents atlas des oiseaux, à savoir des mailles de
          10 x 10 km. En outremer, le grain de restitution pourra varier selon
          les contextes locaux.
        </div>
        <img
          style="width: 70%"
          src="/what-is-ODF-project/Atlas-illustration.svg"
        />
        <div class="PageTitle">Évaluer les tendances démographiques</div>
        <div class="PageText">
          L'évaluation de la tendance des espèces se fera par l’intermédiaire
          des dispositifs de surveillance nationaux déjà mis en place (STOC,
          SHOC, STOM, Observatoire Rapaces et Dénombrement des oiseaux d'eau de
          la mi-janvier).
        </div>
        <img
          style="width: 70%"
          src="/what-is-ODF-project/trends-illustration.svg"
        />
        <div class="PageTitle">Estimer les tailles des populations</div>
        <div class="PageText">
          Il s'agit d'obtenir des effectifs fiables pour un maximum d'espèces.
          En complément des carrés rapaces, de l'enquête LIMAT ou d’autres
          enquêtes ciblant des cortèges d’espèces (hérons coloniaux, oiseaux
          marins nicheurs), une méthode basée sur les EPOC-ODF va être déployée
          pour atteindre cet ambitieux objectif spécialement sur les Oiseaux
          communs.
        </div>
      </div>
      <div v-else-if="selectedMenuItem === 'Participer'" class="PageContent">
        <div class="PageTitle">Comment participer ?</div>
        <div class="PageText">
          <div>
            Contribuer à Oiseaux de France peut se faire de bien des manières en
            fonction de votre disponibilité et de vos connaissances
            ornithologiques. Le plus simple est de saisir systématiquement vos
            observations, idéalement par listes complètes, en attribuant un code
            de reproduction pour les oiseaux nicheurs.<br /><br />
            <b
              >Transmettre le plus d'EPOC possible est un autre moyen facile de
              contribuer.</b
            ><br /><br />
            S'engager dans des suivis plus standardisés exige plus de temps et
            une solide connaissance des oiseaux, mais cet engagement est riche
            de satisfaction et permet d'acquérir une connaissance intime de
            l'avifaune et des milieux que vous prospectez.
          </div>
          <nuxt-link to="/get-involved" class="PrimaryButton"
            >Découvrir les dispositifs</nuxt-link
          >
        </div>
        <img
          style="width: 64%"
          src="/what-is-ODF-project/protocols-outline.svg"
        />
      </div>
      <div v-else class="PageContent">
        <div class="PageTitle">Un site ODF ?</div>
        <div class="PageText">
          <div>
            Le site
            <nuxt-link to="/">www.oiseauxdefrance.org</nuxt-link> est un portail
            de restitution qui permet de consulter les données collectées dans
            le cadre d’ODF de manière synthétique. Les cartes de répartition
            ainsi que les listes d’espèces notées dans chaque mailles sont mises
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
          </div>
        </div>
        <div class="ToolsLogos">
          <img
            class="Logo"
            src="/what-is-ODF-project/FAUNE-FRANCE-logo.svg"
            style="margin-right: 15%"
          />
          <img class="Logo" src="/what-is-ODF-project/NaturaList-logo.svg" />
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    menuItems: ['Description', 'Participer', 'Qui sommes-nous ?'],
    selectedMenuItem: 'Description',
  }),
  methods: {
    updateSelectedMenuItem(item) {
      this.selectedMenuItem = item
    },
  },
  head: {
    title: 'ODF késako ?',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 80px;
}

header {
  background-color: #fcfcfc;
  border-bottom: 1px solid rgba(51, 105, 80, 0.2);
  width: 100%;
  height: 254px;
  padding: 2.4% 18%;
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
  padding: 2.5% 8%;
  margin-left: 4%;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-size: 14px;
  line-height: 21px;
  white-space: nowrap;
}

.PageSection {
  background-color: rgba(57, 118, 90, 0.1);
  min-height: calc(100vh - 334px);
  padding: 0 18%;
}

.PageContent {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.PageTitle {
  width: 100%;
  margin: 4vh 0 2.5vh 0;
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
  margin-bottom: 4vh;
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

.ToolsLogos {
  margin: auto;
  display: flex;
}

.Logo {
  height: 60px;
}
</style>
