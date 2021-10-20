<template>
  <v-container fluid>
    <main class="TopSection"></main>
    <section class="NewsSection">
      <news-card :news="news" />
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
    news: {},
  }),
  mounted() {
    const id = this.$route.params.id
    this.$content(`fr/actualites/${id}`)
      .fetch()
      .then((news) => {
        this.news = news
      })
      .catch((error) => {
        console.log(error)
      })
  },
  head() {
    return {
      title: this.news.title,
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
  margin-top: -148px;
  padding-bottom: 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
  .NewsSection {
    padding-bottom: 24px;
  }
}
</style>
