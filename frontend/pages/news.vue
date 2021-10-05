<template>
  <v-container fluid>
    <main class="TopSection">
      <header>
        <h2 class="black02 fw-600 text-center">Les dernières actualités</h2>
      </header>
    </main>
    <section class="NewsSection">
      <div
        v-for="(item, index) in resultsNewsItems"
        :id="item.slug"
        :key="index"
        class="NewsCard"
      >
        <div
          class="CardPicture"
          :src="item.picture"
          :style="{
            background: `url(/news/${item.picture}) ${item.centering} / cover`,
          }"
        >
          <h5 class="white02 PictureCredit">{{ item.credit }}</h5>
        </div>
        <span class="black03 bottom-margin-16">
          {{ item.author }} &nbsp;•&nbsp;
          {{ $formatDate(item.createdAt, true) }}
        </span>
        <h3 class="black02 fw-600 bottom-margin-16">
          {{ item.title }}
        </h3>
        <nuxt-content :document="item" />
        <div class="TagMenu no-bottom-margin">
          <div v-for="(tag, tagIndex) in item.tags" :key="tagIndex" class="Tag">
            {{ tag }}
          </div>
        </div>
      </div>
      <v-pagination
        v-model="currentPage"
        :length="paginationNumber"
        :total-visible="7"
        circle
      ></v-pagination>
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    newsItems: [],
    paginationNumber: 1,
    currentPage: 1,
    newsNumberPerPage: 4,
  }),
  computed: {
    resultsNewsItems() {
      if (this.paginationNumber <= 1) {
        return this.newsItems
      } else {
        const resultsNewsIndexes = Array(this.newsNumberPerPage)
          .fill()
          .map((value, i) => i + 1)
          .map((value) => this.currentPage * this.newsNumberPerPage - value)
        return this.newsItems.filter((news, index) => {
          return resultsNewsIndexes.includes(index)
        })
      }
    },
  },
  mounted() {
    this.$content(`fr/actualites`)
      .where({ active: true })
      .sortBy('createdAt', 'desc')
      .fetch()
      .then((news) => {
        this.newsItems = news
        this.paginationNumber =
          Math.floor(this.newsItems.length / this.newsNumberPerPage) + 1
      })
      .catch((error) => {
        console.log(error)
      })
      .finally(() => {
        if (this.$route.hash) {
          const selectedNews = this.newsItems.filter((news) => {
            return news.slug === this.$route.hash.substring(1)
          })
          const selectedNewsIndex = this.newsItems.indexOf(selectedNews[0])
          this.currentPage =
            Math.floor(selectedNewsIndex / this.newsNumberPerPage) + 1
          // Temps de latence nécessaire pour que les actualités de la page s'affichent
          setTimeout(() => {
            document
              .getElementById(this.$route.hash.substring(1))
              .scrollIntoView()
          }, 10)
        }
      })
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
.TopSection {
  background: rgba(57, 118, 90, 0.1);
  height: 296px;
  padding: 0 10%;
}

.NewsSection {
  margin-top: -84px;
  padding-bottom: 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.NewsCard {
  width: 800px;
  max-width: 90vw;
  margin-bottom: 24px;
}

.NewsCard:last-child {
  margin-bottom: 50px;
}

.CardPicture {
  height: 200px;
}

.PictureCredit {
  position: absolute;
  right: 12px;
  bottom: 9px;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
  h2.fw-600 {
    font-weight: bold;
  }

  .NewsSection {
    padding-bottom: 24px;
  }

  h3 {
    font-size: 24px;
    line-height: 36px;
  }
}

@media screen and (max-width: 550px) {
  .CardPicture {
    background-position: center center !important;
  }
}
</style>
