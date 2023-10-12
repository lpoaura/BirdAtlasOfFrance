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
  async asyncData({ $content, params }) {
    const news = await $content(`fr/actualites/${params.id}`).fetch()
    return { news }
  },
  data: () => ({
    newsContent: '',
  }),
  head() {
    const newsContent = this.newsContent
    const route = this.$route
    return {
      title: this.news.title,
      meta: [
        {
          hid: 'description',
          name: 'description',
          content: newsContent,
        },
        {
          hid: 'og:type',
          property: 'og:type',
          content: 'website',
        },
        {
          hid: 'og:url',
          property: 'og:url',
          content: `https://www.oiseauxdefrance.org${route.fullPath}`,
        },
        {
          hid: 'og:title',
          property: 'og:title',
          content: `${this.news.title} | Atlas des Oiseaux de France`,
        },
        {
          hid: 'og:description',
          property: 'og:description',
          content: newsContent,
        },
        {
          hid: 'og:image',
          property: 'og:image',
          content: `/news/${this.news.picture}`,
        },
        {
          hid: 'twitter:card',
          property: 'twitter:card',
          content: 'summary_large_image',
        },
        {
          hid: 'twitter:url',
          property: 'twitter:url',
          content: `https://www.oiseauxdefrance.org${route.fullPath}`,
        },
        {
          hid: 'twitter:title',
          property: 'twitter:title',
          content: `${this.news.title} | Atlas des Oiseaux de France`,
        },
        {
          hid: 'twitter:description',
          property: 'twitter:description',
          content: newsContent,
        },
        {
          hid: 'twitter:image',
          property: 'twitter:image',
          content: `/news/${this.news.picture}`,
        },
      ],
    }
  },
  mounted() {
    this.newsContent =
      document.getElementsByClassName('nuxt-content')[0].textContent
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

@media screen and (width <= 680px) {
  .NewsSection {
    padding-bottom: 24px;
  }
}
</style>
