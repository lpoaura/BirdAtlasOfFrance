export const state = () => ({
  atlasIsOpen: true,
  idArea: null,
  cdNom: null,
  phenologyPeriod: 'all_period',
  selectedTab: 'monography',
  subjectsList: [],
  subjectsMapAtlasList: {},
  subjectsMapOthersList: {},
  selectedSubject: {},
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
  setPhenologyPeriod(state, phenologyPeriod){
    state.phenologyPeriod = phenologyPeriod
  },
  setSelectedTab(state, selectedTab){
    state.selectedTab = selectedTab
  },
  revertAtlasIsOpen(state, atlas) {
    console.debug('mutation state',state)
    console.debug('mutation atlas',atlas)
		state.atlasIsOpen = !atlas
	},
  setSubjectsList(state, subjects) {
    state.subjectsList = subjects
  },
  pushSubjectsList(state, subject) {
    state.subjectsList.push(subject)
  },
  setSelectedSubject(state, subject) {
    state.selectedSubject = subject
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
  }
}


// export const actions = {
// 	revertAtlasIsOpen(context, atlas) {
//     console.debug('actions context',context)
//     console.debug('actions atlas',atlas)
// 		const atlasState = !atlas
// 		context.commit(atlasState)
// 	},
// }

