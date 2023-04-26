export const state = () => ({
  atlasIsOpen: true,
  idArea: null,
  cdNom: null,
  selectedTab: {
    value: 'monography',
    hash: '#monography',
    label: 'Fiche espèce',
  },
  subjectsList: [],
  subjectsMapAtlasList: {},
  subjectsMapOthersList: {},
  selectedSubject: {},
  selectedTerritory: {},
  selectedSeason: {},
  attributes: {},
  medias: {},
  territoryDistribution: [],
  territoriesList: [
    {
      area_code: 'FRMET',
      area_name: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
      isActive: true,
    },
    {
      area_code: '01',
      area_name: 'Guadeloupe',
      icon: '/prospecting/Guadeloupe.svg',
      isActive: true,
    },
    {
      area_code: '03',
      area_name: 'Guyane',
      icon: '/prospecting/Guyane.svg',
      isActive: true,
    },
    {
      area_code: '02',
      area_name: 'Martinique',
      icon: '/prospecting/Martinique.svg',
      isActive: true,
    },
    {
      area_code: '06',
      area_name: 'Mayotte',
      icon: '/prospecting/Mayotte.svg',
      isActive: false,
    },
    {
      area_code: '988',
      area_name: 'Nouvelle Calédonie',
      icon: '/prospecting/Nouvelle-Caledonie.svg',
      isActive: true,
    },
    {
      area_code: '987',
      area_name: 'Polynésie Française',
      icon: '/prospecting/Polynesie.svg',
      isActive: false,
    },
    {
      area_code: '04',
      area_name: 'La Réunion',
      icon: '/prospecting/Reunion.svg',
      isActive: false,
    },
    {
      area_code: '977',
      area_name: 'Saint Barthélémy',
      icon: '/prospecting/Saint-Barthelemy.svg',
      isActive: false,
    },
    {
      area_code: '978',
      area_name: 'Saint Martin',
      icon: '/prospecting/Saint-Martin.svg',
      isActive: false,
    },
    {
      area_code: '975',
      area_name: 'Saint Pierre et Miquelon',
      icon: '/prospecting/Saint-Pierre-et-Miquelon.svg',
      isActive: true,
    },
    {
      area_code: '984',
      area_name: 'TAAF',
      icon: '/prospecting/TAAF.svg',
      isActive: false,
    },
    {
      area_code: '986',
      area_name: 'Wallis et Futuna',
      icon: '/prospecting/Wallis-et-Futuna.svg',
      isActive: false,
    },
  ],
})

export const getters = {
  getAtlasIsOpen(state) {
    return state.atlasIsOpen
  },
}

export const mutations = {
  setIdArea(state, idArea) {
    state.idArea = idArea
  },
  setCdNom(state, cdNom) {
    state.cdNom = cdNom
  },
  setSelectedTab(state, selectedTab) {
    state.selectedTab = selectedTab
  },
  revertAtlasIsOpen(state, atlas) {
    console.debug('mutation state', state)
    console.debug('mutation atlas', atlas)
    state.atlasIsOpen = !atlas
  },
  setSubjectsList(state, subjects) {
    state.subjectsList = subjects
  },
  pushSubjectsList(state, subject) {
    state.subjectsList.push(subject)
    state.subjectsList = state.subjectsList.filter(
      (subject, index, self) =>
        index === self.findIndex((t) => t.slug === subject.slug)
    )
  },
  removeSubjectsList(state, subject) {
    state.subjectsList = state.subjectsList.filter(
      (item) => item.slug !== subject.slug
    )
  },
  setSelectedSubject(state, subject) {
    state.selectedSubject = subject
  },
  async setSelectedTerritory(state, territory) {
    state.selectedTerritory = territory
    console.log(
      'STORE setSelectedTerritory',
      state.selectedTerritory,
      territory
    )
    // const data = {...territory}
    await this.$axios
      .$get(
        `/api/v1/lareas/ATLAS_TERRITORY/${territory.area_code}?geom=false&bbox=false`
      )
      .then((resp) => {
        state.selectedTerritory.id_area = resp.id_area
      })
  },
  setSelectedSeason(state, season) {
    state.selectedSeason = season
  },
  setSubjectsMapAtlasList(state, maps) {
    state.subjectsMapAtlasList = maps
  },
  pushSubjectsMapAtlasList(state, map) {
    state.subjectsMapAtlasList.push(map)
  },
  setSubjectsMapOthersList(state, maps) {
    state.subjectsMapOthersList = maps
  },
  pushSubjectsMapOthersList(state, map) {
    state.subjectsMapOthersList.push(map)
  },
  setAttributes(state, attributes) {
    state.attributes = attributes
  },
  setMedias(state, medias) {
    state.medias = medias
  },
  setTerritoryDistribution(state, distribution) {
    state.territoryDistribution = distribution
  },
}

// export const actions = {
// 	revertAtlasIsOpen(context, atlas) {
//     console.debug('actions context',context)
//     console.debug('actions atlas',atlas)
// 		const atlasState = !atlas
// 		context.commit(atlasState)
// 	},
// }
