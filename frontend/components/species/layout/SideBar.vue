<template>
  <nav class="NavDrawer">
    <menu
      v-if="
        (selectedTab.value !== 'maps' && subjectsList.length === 0) ||
        (selectedTab.value === 'maps' && subjectsMapAtlasList.length === 0)
      "
    >
      <div
        v-for="item in [...Array(3).keys()]"
        :key="item"
        :class="item === 0 ? 'selected' : ''"
        class="TabItem vertical"
      >
        <v-skeleton-loader type="text"></v-skeleton-loader>
      </div>
    </menu>
    <menu
      v-if="['monography', 'charts'].includes(selectedTab.value)"
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
    <menu v-if="selectedTab.value === 'maps'">
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
  data: () => {
    return {
      atlasIsOpen: true,
      scrollDuration: 600,
    }
  },
  computed: {
    subjectsList() {
      const list = [...this.$store.state.species.subjectsList]
      return list.sort(function (a, b) {
        return a.position - b.position
      })
    },
    selectedSubject() {
      return this.$store.state.species.selectedSubject
    },
    subjectsMapAtlasList() {
      return this.$store.state.species.subjectsMapAtlasList
    },
    subjectsMapOthersList() {
      return this.$store.state.species.subjectsMapOthersList
    },
    selectedTab() {
      return this.$store.state.species.selectedTab
    },
  },
  watch: {
    subjectsList: {
      handler(newVal) {
        if (newVal.length > 0 && this.selectedTab.value !== 'maps') {
          this.$store.commit('species/setSelectedSubject', newVal[0])
        }
      },
      deep: true,
    },
    subjectsMapAtlasList: {
      handler(newVal) {
        if (newVal.length > 0 && this.selectedTab.value === 'maps') {
          this.$store.commit('species/setSelectedSubject', newVal[0])
        }
      },
      deep: true,
    },
  },
  mounted() {},
  methods: {
    updateSelectedSubject(item) {
      // if (document.getElementById(item.slug) && this.selectedSubject !== item) {
      if (
        item &&
        this.selectedTab.value !== 'maps' &&
        this.selectedSubject.slug !== item.slug
      ) {
        this.scrollListener = false
        // this.selectedSubject = item
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
      this.$store.commit('species/setSelectedSubject', item)
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
