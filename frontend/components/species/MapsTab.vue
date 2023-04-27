<template>
  <div class="SpeciesCardContent map">
    <client-only v-if="selectedSubject && selectedSubject.slug != 'extra-map'">
      <lazy-species-map
        :selected-territory="selectedTerritory"
        :selected-subject="selectedSubject"
        :selected-season="selectedSeason"
        :cdnom="cdNom"
      />
    </client-only>
    <species-maps-extra-map
      v-if="selectedSubject && selectedSubject.slug === 'extra-map'"
      :selected-territory="selectedTerritory"
      :selected-subject="selectedSubject"
      :selected-season="selectedSeason"
      :cdnom="cdNom"
    >
    </species-maps-extra-map>
    <div class="MapLegend"></div>
  </div>
</template>

<script>
export default {
  components: {
    'lazy-species-map': () => {
      if (process.client) {
        return import('~/components/species/maps/SpeciesMap.vue')
      }
    },
  },
  data: () => ({
    descriptionHeight: 0,
    mapAtlasBaseSubjects: [
      {
        label: '2019 - 2024',
        name: 'Oiseaux De France',
        slug: 'odf',
        seasons: ['all_period', 'breeding', 'wintering'],
      },
    ],
    mapOthersBaseSubjects: [
      {
        label: 'Comparaison AOFM/ODF',
        name: 'Comparaison AOFM/ODF',
        slug: 'compare-aofm-odf',
        seasons: ['breeding', 'wintering'],
      },
      // {
      //   label: 'Densité',
      //   name: 'Densité',
      //   slug: 'density',
      //   seasons: ['breeding', 'wintering']
      // },
      {
        label: 'Carte additionnelle',
        name: 'Carte additionnelle',
        slug: 'extra-map',
        seasons: ['breeding', 'wintering', 'all_period'],
      },
    ],
  }),
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
  watch: {
    selectedTerritory: {
      handler(newVal, oldVal) {
        console.log('TEST IDAREA', oldVal.id_area, newVal.id_area)
        if (newVal.id_area) {
          this.loadHistoricAtlasList()
        }
      },
      deep: true,
    },
  },
  mounted() {
    this.initSubjectsList()
    this.loadHistoricAtlasList()
  },
  methods: {
    initSubjectsList() {
      this.$store.commit(
        'species/setSubjectsMapAtlasList',
        this.mapAtlasBaseSubjects
      )
      this.$store.commit(
        'species/setSubjectsMapOthersList',
        this.mapOthersBaseSubjects
      )
      this.$store.commit(
        'species/setSelectedSubject',
        this.mapAtlasBaseSubjects[0]
      )
    },
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
          // if (data) {
          //   data.forEach((item) =>
          //     this.$store.commit('species/pushSubjectsMapAtlasList', item)
          //   )
          // }
        })
        .catch((error) => {
          console.error(error)
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
