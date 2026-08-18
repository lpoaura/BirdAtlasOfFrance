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
        // Saisons où les deux atlas 2009-2012 et 2019-2023 sont disponibles
        compareAvailableSeasons: [],
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
        // Comparaison AOFM/ODF : FRMET + atlas 2009-2012 et 2019-2023 disponibles pour au moins une période
        mapOthersSubjects() {
            const isMetropole = this.selectedTerritory?.area_code === 'FRMET'
            const hasCompare =
                isMetropole && this.compareAvailableSeasons.length > 0
            return this.mapOthersBaseSubjects
                .filter(
                    (subject) => subject.slug !== 'compare-aofm-odf' || hasCompare
                )
                .map((subject) => {
                    if (subject.slug === 'compare-aofm-odf') {
                        return {
                            ...subject,
                            seasons: [...this.compareAvailableSeasons],
                        }
                    }
                    return subject
                })
        },
    },
    // Observe les changements sur selectedTerritory et appelle loadHistoricAtlasList() si newVal.id_area est défini.
    watch: {
        selectedTerritory: {
            handler(newVal, oldVal) {
                if (newVal.id_area) {
                    this.loadHistoricAtlasList()
                } else {
                    this.compareAvailableSeasons = []
                    this.updateMapOthersSubjects()
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
            this.updateMapOthersSubjects()
            // Si mapAtlasBaseSubjects est vide, utilisez le premier élément de mapOthersSubjects
            const defaultSubject =
                this.mapAtlasBaseSubjects.length > 0
                    ? this.mapAtlasBaseSubjects[0]
                    : this.mapOthersSubjects[0]
            this.$store.commit('species/setSelectedSubject', defaultSubject)
        },
        // Saisons communes aux atlas 2009-2012 et 2019-2023
        getCompareAvailableSeasons(atlasList) {
            const comparePeriods = ['2009-2012', '2019-2023']
            const seasonsByPeriod = Object.fromEntries(
                comparePeriods.map((period) => [period, new Set()])
            )
            ;(atlasList || []).forEach((atlas) => {
                if (
                    comparePeriods.includes(atlas.label) &&
                    Array.isArray(atlas.seasons)
                ) {
                    atlas.seasons.forEach((season) =>
                        seasonsByPeriod[atlas.label].add(season)
                    )
                }
            })
            const [periodOld, periodNew] = comparePeriods
            if (
                seasonsByPeriod[periodOld].size === 0 ||
                seasonsByPeriod[periodNew].size === 0
            ) {
                return []
            }
            return [...seasonsByPeriod[periodOld]].filter((season) =>
                seasonsByPeriod[periodNew].has(season)
            )
        },
        // Met à jour la liste des sujets "autres" selon le territoire et la dispo des atlas
        updateMapOthersSubjects() {
            const subjects = this.mapOthersSubjects
            this.$store.commit('species/setSubjectsMapOthersList', subjects)
            const compareSubject = subjects.find(
                (s) => s.slug === 'compare-aofm-odf'
            )
            if (this.selectedSubject?.slug === 'compare-aofm-odf') {
                if (compareSubject) {
                    this.$store.commit('species/setSelectedSubject', compareSubject)
                } else {
                    const atlasList = this.$store.state.species.subjectsMapAtlasList
                    const fallback =
                        Array.isArray(atlasList) && atlasList.length > 0
                            ? atlasList[0]
                            : subjects[0]
                    if (fallback) {
                        this.$store.commit('species/setSelectedSubject', fallback)
                    }
                }
            }
        },
        // Charge la liste des atlas historiques depuis une API et met à jour le state Vuex avec les données reçues
        loadHistoricAtlasList() {
          if (!this.cdNom || !this.idArea) return
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
              const atlasList = data || []
              this.$store.commit('species/updateSubjectsMapAtlasList', atlasList)
              this.compareAvailableSeasons =
                this.getCompareAvailableSeasons(atlasList)
              this.updateMapOthersSubjects()
            })
            .catch((error) => {
              console.debug(`${error}`)
              this.compareAvailableSeasons = []
              this.updateMapOthersSubjects()
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