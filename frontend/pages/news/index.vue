<template>
  <v-container fluid>
    <main class="TopSection">
      <header>
        <h2 class="black02 fw-600 text-center">Les dernières actualités</h2>
      </header>
    </main>
    <section class="NewsSection">
      <news-card
        v-for="(item, index) in resultsNewsItems"
        :key="index"
        :news="item"
      />
      <v-pagination
        v-model="currentPage"
        :length="pagesNumber"
        :total-visible="7"
        circle
        class="top-margin-24"
      ></v-pagination>
    </section>
  </v-container>
</template>

<script>
import NewsCard from '~/components/news/NewsCard.vue'

export default {
  components: {
    'news-card': NewsCard,
  },
  data: () => ({
    newsItems: [],
    pagesNumber: 1,
    currentPage: 1,
    newsNumberPerPage: 5,
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  computed: {
    resultsNewsItems() {
      if (this.pagesNumber <= 1) {
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
  watch: {
    currentPage(newVal) {
      window.scrollTo(0, 0)
    },
  },
  mounted() {
    this.$content('fr/actualites')
      .where({ active: true, date: { $lte: new Date() } })
      .sortBy('date', 'desc')
      .fetch()
      .then((news) => {
        this.newsItems = news
        this.pagesNumber =
          this.newsItems.length % this.newsNumberPerPage === 0
            ? this.newsItems.length / this.newsNumberPerPage
            : Math.floor(this.newsItems.length / this.newsNumberPerPage) + 1
      })
      .catch((error) => {
        console.debug(`${error}`)
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
            this.$refs[this.$route.hash.substring(1)].scrollIntoView({
              behavior: 'smooth',
            })
          }, 10)
        }
      })
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

/********** RESPONSIVE **********/

@media screen and (width <= 680px) {
  h2.fw-600 {
    font-weight: bold;
  }

  .NewsSection {
    padding-bottom: 24px;
  }
}
</style>
