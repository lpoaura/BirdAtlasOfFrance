<template>
  <v-container fluid>
    <header>
      <breadcrumb />
      <div class="Heading">
        <div class="LogoWrapper">
          <img class="Logo" :src="logo" />
        </div>
        <div class="Title">
          <h1 class="fw-bold">{{ page }}</h1>
          <h5 v-if="description" class="fw-300">{{ description }}</h5>
        </div>
      </div>
      <div class="Metadata">
        <h5 class="black04">Dernière actualisation le {{ lastUpdate }}</h5>
        <menu class="TabMenu no-bottom-margin">
          <div
            v-for="(item, index) in tabs"
            :key="index"
            class="TabItem"
            :class="item.hash === selectedTab.hash ? 'selected' : ''"
            @click="updateSelectedTab(item)"
          >
            {{ item.label }}
          </div>
        </menu>
      </div>
      <dropdown-list
        v-model="selectedTabModel"
        :z-index="1"
        :items-list="tabs"
      />
    </header>
    <section class="InformativePageSection">
      <nuxt-content :document="tabToShow" />
    </section>
  </v-container>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
  },
  props: {
    nuxtContent: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    content: [],
    page: '',
    description: '',
    logo: '',
    lastUpdate: '',
    tabs: [],
    selectedTab: { hash: '', label: '' },
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  computed: {
    // Permet de mettre à jour selectedTab seulement après le $router.push
    selectedTabModel: {
      get() {
        return this.selectedTab
      },
      set(value) {
        this.$router.push(`${value.hash}`)
      },
    },
    tabToShow() {
      const tab = this.content.filter((tab) => {
        return tab.hash === this.selectedTab.hash
      })
      return tab[0]
    },
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.selectedTab = this.tabs.filter((item) => {
        return item.hash === newVal.hash
      })[0]
    },
  },
  mounted() {
    this.$content(this.nuxtContent)
      .sortBy('order')
      .fetch()
      .then((content) => {
        this.content = content
        this.page = content[0].page
        this.description = content[0].description
        this.logo = content[0].logo
        const datesList = content.map((item) => item.updatedAt)
        this.lastUpdate = this.$getLatestDate(datesList)
        this.tabs = content.map((item) => {
          return { hash: item.hash, label: item.title }
        })
        this.selectedTab = this.tabs.filter((item) => {
          return item.hash === this.$route.hash
        })[0]
      })
      .catch((error) => {
        console.debug(`${error}`)
      })
  },
  methods: {
    updateSelectedTab(item) {
      this.$router.push(`${item.hash}`)
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}

header {
  background: #fcfcfc;
  width: 100%;
  padding: 16px 16%;
  display: flex;
  flex-direction: column;
}

.Heading {
  width: 100%;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.LogoWrapper {
  width: 134px;
  min-width: 134px;
  height: 134px;
  margin-right: 36px;
  border: 4px solid rgba(0, 0, 0, 0.05);
  box-sizing: border-box;
  border-radius: 24px;
  display: flex;
}

.Logo {
  width: 80px;
  margin: auto;
}

.Title {
  display: flex;
  flex-direction: column;
}

.Title h1 {
  line-height: 46px;
}

.Title h5 {
  margin-top: 7px;
}

.Metadata {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.DropdownListWrapper {
  display: none;
}

/********** RESPONSIVE **********/

@media screen and (width <= 920px) {
  header {
    padding: 16px 5%;
  }
}

@media screen and (width <= 680px) {
  .LogoWrapper {
    width: 100px;
    min-width: 100px;
    height: 100px;
    margin-right: 16px;
  }

  .Logo {
    width: 65px;
  }

  .Title h1 {
    line-height: inherit;
  }

  .Title h5 {
    margin-top: 0;
  }
}
</style>
