<template>
  <nav class="NavDrawer">
    <menu
      v-if="['monography', 'charts'].includes(selectedTab)"
      class="TabMenu vertical no-bottom-margin"
    >
      <div
        v-for="item in subjectsList"
        :key="item.slug"
        class="TabItem vertical"
        :class="item.slug === selectedSubject.slug ? 'selected' : ''"
        @click="updateSelectedSubject(item)"
      >
        {{ item.label }}
      </div>
    </menu>
    <menu v-if="selectedTab === 'maps'">
      <div class="SeeMoreWrapper" @click="atlasIsOpen = !atlasIsOpen">
        <span class="black02 fw-600 bottom-margin-">Atlas</span>
        <img
          class="SeeMoreChevron"
          :src="atlasIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
        />
      </div>
      <div v-show="atlasIsOpen">
        <div
          v-for="item in subjectsMapAtlasList"
          :key="item.label"
          class="TabItem vertical atlas"
          :class="item.label === selectedSubject.label ? 'selected' : ''"
          :title="item.name"
          @click="updateSelectedSubject(item)"
        >
          {{ item.label }}
        </div>
      </div>
      <div
        v-for="item in subjectsMapOthersList"
        :key="item.slug"
        class="TabItem vertical fw-600"
        :class="item.slug === selectedSubject.slug ? 'selected' : ''"
        @click="updateSelectedSubject(item)"
      >
        {{ item.label }}
      </div>
    </menu>
  </nav>
</template>

<script>
export default {
  props: {
    // subjectsList: {
    //   type: Array,
    //   required: true,
    // },
    selectedSubject: {
      type: Object,
      required: true,
    },
    tabs: {
      type: Array,
      required: true,
    },
  },
  data: () => {
    return {
      atlasIsOpen : true,
    }
  },
  computed: {
    subjectsList() {
      const list = [...this.$store.state.species.subjectsList]
      return list.sort(function (a, b) {
        return a.position - b.position
      })
    },
    subjectsMapAtlasList() {
      return this.$store.state.species.subjectsMapAtlasList
    },
    subjectsMapOthersList() {
      return this.$store.state.species.subjectsMapOthersList
    },
    // Permet de mettre à jour selectedTab seulement après le $router.push
    // selectedTabModel: {
    //   get() {
    //     return this.selectedTab
    //   },
    //   set(value) {
    //     this.$router.push(`${value.hash}`)
    //   },
    // },
    selectedTab() {
      return this.$store.state.species.selectedTab
    },
  },
  mounted() {
    console.debug('SELECTED TAB', this.selectedTab)
    console.debug('SELECTED TAB is maps', this.selectedTab === 'maps')
    console.debug('atlasIsOpen', this.atlasIsOpen)
  },
  methods: {
    // updateAtlasStatus() {
    //   console.debug('this.atlasIsOpen', this.atlasIsOpen)
    //   this.$store.commit('species/revertAtlasIsOpen', this.atlasIsOpen)
    // },
    updateSelectedSubject(item) {
      console.log(item)
      this.$store.commit('species/setSelectedSubject', item)
      if (document.getElementById(item.slug) && this.selectedSubject !== item) {
        this.scrollListener = false
        // this.selectedSubject = item
        this.$store.commit('species/setSelectedSubject', item)
        this.$animateScrollTo(
          this.$parent.$refs.scrollingContainer,
          document.getElementById(item.slug).offsetTop,
          12,
          this.scrollDuration
        )
        setTimeout(() => {
          this.scrollListener = true
        }, this.scrollDuration + 10)
      }
      // if (this.selectedTab.value === 'maps') {
      //   this.selectedSubject = item
      // }
    },
  },
}
</script>

<style>
.SeeMoreWrapper {
  margin: 0 0 18px 24px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.SeeMoreChevron {
  width: 11px;
}
</style>
