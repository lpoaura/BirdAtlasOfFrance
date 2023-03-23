export const state = () => ({
  atlasIsOpen: true,
  idArea: null,
  cdNom: null,
  selectedTab: 'monography',
  subjectsList: [],
  subjectsMapAtlasList: {},
  subjectsMapOthersList: {},
  selectedSubject: {},
  selectedTerritory: {},
  selectedSeason:{},
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
  setSelectedTerritory(state, territory) {
    state.selectedTerritory = territory
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
}

// export const actions = {
// 	revertAtlasIsOpen(context, atlas) {
//     console.debug('actions context',context)
//     console.debug('actions atlas',atlas)
// 		const atlasState = !atlas
// 		context.commit(atlasState)
// 	},
// }
