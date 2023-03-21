<template>
  <div class="SpeciesCardContent map" :class="tabStatus">
    <client-only v-if="selectedSubject && selectedSubject.slug != 'extra-map'">
      <lazy-species-map
        :selected-territory="selectedTerritory"
        :selected-subject="selectedSubject"
        :selected-season="selectedSeason"
        :cdnom="cdnom"
      />
    </client-only>
    <species-maps-extra-map
      v-if="selectedSubject && selectedSubject.slug === 'extra-map'"
      :selected-territory="selectedTerritory"
      :selected-subject="selectedSubject"
      :selected-season="selectedSeason"
      :cdnom="cdnom"
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
  props: {
    tabStatus: {
      type: String,
      required: true,
    },
    selectedTerritory: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    selectedSeason: {
      // Territoire cliqué (FrMet ou DOM-TOM)
      type: Object,
      required: true,
    },
    cdnom: {
      type: String,
      required: true,
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
    selectedSubject() {
      return this.$store.state.species.selectedSubject
    }
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
      this.$axios
        .$get(`/api/v1/taxa/historic/atlas/list?cd_nom=${this.cdnom}`)
        .then((data) => {
          data.forEach(item => this.$store.commit('species/pushSubjectsMapAtlasList', item))
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
