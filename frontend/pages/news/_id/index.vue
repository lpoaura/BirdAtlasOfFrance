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
    newsContent: '',
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
      .finally(() => {
        this.newsContent = document.getElementsByClassName(
          'nuxt-content'
        )[0].textContent
      })
  },
  head() {
    return {
      titleTemplate: null,
      title: this.news.title,
      meta: [
        {
          hid: 'description',
          name: 'description',
          content: this.newsContent,
        },
        {
          hid: 'og-type',
          property: 'og:type',
          content: 'website',
        },
        {
          hid: 'og-url',
          property: 'og:url',
          content: `https://www.oiseauxdefrance.org${this.$route.fullPath}`,
        },
        {
          hid: 'og-title',
          property: 'og:title',
          content: this.news.title,
        },
        {
          hid: 'og-description',
          property: 'og:description',
          content: this.newsContent,
        },
        {
          hid: 'og-image',
          property: 'og:image',
          content: this.news.picture,
        },
        {
          hid: 'twitter-card',
          property: 'twitter:card',
          content: 'summary_large_image',
        },
        {
          hid: 'twitter-url',
          property: 'twitter:url',
          content: `https://www.oiseauxdefrance.org${this.$route.fullPath}`,
        },
        {
          hid: 'twitter-title',
          property: 'twitter:title',
          content: this.news.title,
        },
        {
          hid: 'twitter-description',
          property: 'twitter:description',
          content: this.newsContent,
        },
        {
          hid: 'twitter-image',
          property: 'twitter:image',
          content: this.news.picture,
        },
      ],
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
