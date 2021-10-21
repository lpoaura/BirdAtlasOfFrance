<template>
  <v-container fluid>
    <main class="TopSection"></main>
    <section class="NewsSection">
      <news-card :news="page" />
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
    const page = await $content(`fr/actualites/${params.id}`).fetch()
    return { page }
  },
  data: () => ({
    // news: {},
    newsContent: '',
  }),
  mounted() {
    this.newsContent = document.getElementsByClassName(
      'nuxt-content'
    )[0].textContent
    // console.log(this.newsContent)
    //   const id = this.$route.params.id
    //   this.$content(`fr/actualites/${id}`)
    //     .fetch()
    //     .then((news) => {
    //       this.news = news
    //     })
    //     .catch((error) => {
    //       console.log(error)
    //     })
    //     .finally(() => {
    //       this.newsContent = document.getElementsByClassName(
    //         'nuxt-content'
    //       )[0].textContent
    //     })
  },
  head() {
    // console.log(this.page)
    const newsContent = this.newsContent
    const route = this.$route
    return {
      title: this.page.title,
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
          content: this.page.title,
        },
        {
          hid: 'og:description',
          property: 'og:description',
          content: newsContent,
        },
        {
          hid: 'og:image',
          property: 'og:image',
          content: this.page.picture,
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
          content: this.page.title,
        },
        {
          hid: 'twitter:description',
          property: 'twitter:description',
          content: newsContent,
        },
        {
          hid: 'twitter:image',
          property: 'twitter:image',
          content: this.page.picture,
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
