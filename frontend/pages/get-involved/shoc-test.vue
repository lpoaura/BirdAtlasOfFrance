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
        <h2 class="InformativePageTitle">
          Vous souhaitez participer et intégrer le réseau ?
        </h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Contactez
            <a
              href="http://www.vigienature.fr/fr/comment-participer-2817"
              target="_blank"
              >votre coordinateur local</a
            >
            en lui indiquant le nom de la commune qui correspond à la zone
            géographique souhaitée.<br /><br />En cas de coordination vacante,
            contactez la
            <a href="mailto:shoc@mnhn.fr">coordination nationale</a
            >.<br /><br />L'emplacement de chaque carré résulte d'un tirage au
            sort effectué dans un rayon de 10 km autour de la commune souhaitée.
            Une fiche vous sera transmise sur laquelle vous pourrez visualiser
            le carré à prospecter sur une carte, ainsi qu'un carré de
            remplacement au cas où le premier serait impraticable.<br /><br />Fournissez
            au coordinateur le nom de la ou des communes autour desquelles vous
            souhaitez faire un STOC. Le coordinateur local vous fera parvenir
            par la suite une fiche visualisant sur fond de carte le carré à
            prospecter, ainsi qu'un carré de remplacement au cas où le premier
            serait inaccessible.<br /><br />Le tirage au sort d'un carré, dans
            un rayon de 10 km autour du point fourni par l'observateur, est
            réalisé par le coordinateur national au MNHN.
          </span>
        </div>
        <h2 class="InformativePageTitle">Faire un SHOC dans son carré STOC</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Vous participez déjà au STOC ? Valorisez le carré que vous suivez au
            printemps en participant également au SHOC ! L’hiver pourrait être
            synonyme de surprises et certainement de belles ambiances.<br /><br /><a
              href="https://www.faune-france.org/index.php?m_id=20153"
              target="_blank"
              >Cliquez ici</a
            >
            pour vous aider à démarrer votre SHOC et télécharger les documents
            ressources.
          </span>
        </div>
        <h2 class="InformativePageTitle">Transmettre ses données</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Pour créer votre carré et saisir vos données, vous pouvez, à votre
            convenance, utiliser les plateformes
            <a href="https://www.vigie-plume.fr/" target="_blank">Vigie-Plume</a
            >, Faune-France.
          </span>
        </div>
        <h2 class="InformativePageTitle">En savoir plus</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Toutes les informations, résultats, actualités et bilans sur le
            programme SHOC sont disponibles sur le site de
            <a
              href="http://www.vigienature.fr/fr/suivi-hivernal-des-oiseaux-communs-shoc"
              target="_blank"
              >Vigie-nature</a
            >.
          </span>
        </div>
      </div>
      <div
        v-else-if="selectedMenuItem === '#documents'"
        class="InformativePageContent"
      >
        <div class="ProtocolsDocumentsContent">
          <div class="ProtocolsDocumentsCard"></div>
          <div class="ProtocolsDocumentsCard"></div>
          <div class="ProtocolsDocumentsCard"></div>
        </div>
      </div>
      <div v-else class="InformativePageContent">
        <h2 class="InformativePageTitle">Principe</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            À l’image du STOC en période de reproduction, le SHOC vise à
            déterminer l’évolution des populations d’oiseaux communs hivernants
            sur le territoire national. En hiver, il accueille des espèces et
            des populations pour lesquelles les statuts sont encore mal connus.
            L’écologie hivernale des oiseaux mérite également d’être mieux
            décrite. Beaucoup de nouvelles connaissances sont à apporter sur le
            rôle des différents habitats dans l’acquisition des ressources, ou
            sur les déplacements des populations hivernantes en fonction des
            conditions météorologiques et du réchauffement climatique.<br /><br />Ce
            programme est coordonné conjointement par la LPO et le Muséum
            national d’Histoire naturelle (MNHN).
          </span>
        </div>
        <h2 class="InformativePageTitle">Où ?</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Les inventaires sont réalisés dans des carrés de 2 km de côté, tirés
            aléatoirement dans un cercle de 10 km de rayon autour d’une commune
            indiquée par l’observateur. Le protocole SHOC repose sur la
            réalisation de 10 transects disposés bout à bout (ou en 2 séries de
            5 transects) par l’observateur de façon à traverser les habitats
            présents dans le carré.
          </span>
        </div>
        <h2 class="InformativePageTitle">Quand ?</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            Chaque carré doit être suivi deux fois au cours de l’hiver : premier
            passage entre le 1<sup>er</sup> et le 31 décembre et second passage
            entre le 1<sup>er</sup> et le 31 janvier. Les deux passages doivent
            être espacés d’au moins 15 jours. Chaque hiver, l’observateur
            s’engage à suivre son/ses carré(s) SHOC aux mêmes dates (+/- 3
            jours).
          </span>
        </div>
        <h2 class="InformativePageTitle">Comment ?</h2>
        <div class="InformativePageParagraph">
          <span class="InformativePageText">
            L’observateur marche le long des 10 transects positionnés sur le
            carré. Pour chaque transect, il note l’abondance des espèces
            d’oiseaux qu’il détecte à la vue ou au cri, la distance à laquelle
            elles se trouvent (classe 0-25m/25-100m/100-200m/>200m), l’heure à
            laquelle il débute et termine son transect. Enfin, il caractérise
            l’habitat pour chaque transect en suivant la typologie fournie.
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
    logo: '/get-involved/SHOC-logo.svg',
    title: 'SHOC',
    subtitle: 'Suivi Hivernal des Oiseaux Communs',
    lastUpdate: '7 janvier 2021',
    menuItems: [
      { label: 'Description', routerPath: '' },
      { label: 'Participer', routerPath: '#get-involved' },
      { label: 'Bilans', routerPath: '#documents' },
    ],
    selectedMenuItem: '',
  }),
  methods: {
    updateSelectedMenuItem(routerPath) {
      this.selectedMenuItem = routerPath
    },
  },
  head: {
    title: 'SHOC',
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 80px;
}
</style>
