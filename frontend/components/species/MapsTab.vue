<template>
  <div class="SpeciesCardContent map">
    <!-- Un composant qui garantit que son contenu est rendu uniquement côté client.
     Un composant enfant qui est chargé de manière paresseuse (lazy-loaded) et affiché
     si selectedSubject est défini et que son slug n'est pas 'extra-map'. -->
     <client-only v-if="selectedSubject && selectedSubject.slug != 'extra-map'">
      <lazy-species-map
        :selected-territory="selectedTerritory"
        :selected-subject="selectedSubject"
        :selected-season="selectedSeason"
        :cdnom="cdNom" />
    </client-only>
    <!--Un autre composant enfant qui est affiché si selectedSubject est défini et que son slug est 'extra-map'.-->
    <species-maps-extra-map v-if="selectedSubject && selectedSubject.slug === 'extra-map'"
      :selected-territory="selectedTerritory"
      :selected-subject="selectedSubject"
      :selected-season="selectedSeason"
      :cdnom="cdNom" >
    </species-maps-extra-map>
    <div class="MapLegend"></div>
  </div>
</template>
 
<script>
export default {
    // Déclare un composant enfant lazy-species-map qui est importé dynamiquement côté client
    components: {
        'lazy-species-map': () => {
            if (process.client) {
                return import('~/components/species/maps/SpeciesMap.vue')
            }
        },
    },
    // Retourne un objet contenant les données locales du composant
    data: () => ({
        descriptionHeight: 0,
        mapAtlasBaseSubjects: [
            // // Catégorie "Prospection de la fiche espèce" :
            // {
            // label: '2024 - {currentYear}',
            // name: 'Oiseaux De France',
            // slug: 'odf',
            // seasons: ['all_period', 'breeding', 'wintering'],
            // },
        ],
        mapOthersBaseSubjects: [
            // {
            //     label: 'Comparaison AOFM/ODF',
            //     name: 'Comparaison AOFM/ODF',
            //     slug: 'compare-aofm-prospection',
            //     seasons: ['breeding', 'wintering'],
            // },
            {
                label: 'Comparaison AOFM/ODF',
                name: 'Comparaison AOFM/ODF',
                slug: 'compare-aofm-odf',
                seasons: ['breeding', 'wintering'],
            },
            // {
            // label: 'Densité',
            // name: 'Densité',
            // slug: 'density',
            // seasons: ['breeding', 'wintering']
            // },
            {
                label: 'Résultats des suivis',
                name: 'Résultats des suivis',
                slug: 'extra-map',
                seasons: ['breeding', 'wintering', 'all_period'],
            },
        ],
    }),
    // Propriétés calculées qui réagissent aux changements dans le state Vuex :
    // idArea, cdNom, selectedSubject, selectedSeason, selectedTerritory : Récupèrent des valeurs depuis le state Vuex.
    computed: {
        idArea() {
            return this.$store.state.species.selectedTerritory.id_area
        },
        cdNom() {
            return this.$store.state.species.cdNom
        },
        selectedSubject() {
            return this.$store.state.species.selectedSubject
        },
        selectedSeason() {
            return this.$store.state.species.selectedSeason
        },
        selectedTerritory() {
            return this.$store.state.species.selectedTerritory
        },
    },
    // Observe les changements sur selectedTerritory et appelle loadHistoricAtlasList() si newVal.id_area est défini.
    watch: {
        selectedTerritory: {
            handler(newVal, oldVal) {
                if (newVal.id_area) {
                    this.loadHistoricAtlasList()
                }
            },
            deep: true,
        },
    },
    // Hook de cycle de vie appelé après le montage du composant. Il initialise la liste des sujets et charge la liste des atlas historiques.
    mounted() {
        this.initSubjectsList()
        this.loadHistoricAtlasList()
    },
    methods: {
        // Initialise les listes de sujets dans le state Vuex
        initSubjectsList() {
            this.$store.commit('species/setSubjectsMapAtlasList', this.mapAtlasBaseSubjects)
            this.$store.commit('species/setSubjectsMapOthersList', this.mapOthersBaseSubjects)
            // Si mapAtlasBaseSubjects est vide, utilisez le premier élément de mapOthersBaseSubjects
            const defaultSubject = this.mapAtlasBaseSubjects.length > 0 ? this.mapAtlasBaseSubjects[0] : this.mapOthersBaseSubjects[0]
            this.$store.commit('species/setSelectedSubject', defaultSubject)
        },
        // Charge la liste des atlas historiques depuis une API et met à jour le state Vuex avec les données reçues
        loadHistoricAtlasList() {
          const url = `/api/v1/taxa/list/historic/atlas`
          const params = {
            cd_nom: this.cdNom,
            id_area: this.idArea,
          }
          this.$axios
            .$get(url, {
              params,
            })
            .then((data) => {
              this.$store.commit('species/updateSubjectsMapAtlasList', data || [])
            })
            .catch((error) => {
              console.debug(`${error}`)
            })
        },
    },
}
</script>
 
<style scoped>
.MapLegend {
  border-left: 1px solid rgba(57, 118, 90, 0.1);
  width: 200px;
  }
</style>