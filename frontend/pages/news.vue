<!-- AJOUTER LA PAGINATION (5 actualités par page) -->
<template>
  <v-container fluid>
    <main class="TopSection">
      <h2 class="black02 fw-600 text-center">Les dernières actualités</h2>
    </main>
    <section class="NewsSection">
      <div
        v-for="(item, index) in newsItems"
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
        <div class="CardMetadata bottom-margin-16">
          <span class="black03 right-margin-8">{{ item.author }}</span>
          <span class="black03 right-margin-8">•</span>
          <span class="black03">{{ $formatDate(item.createdAt, true) }}</span>
        </div>
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
    </section>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    newsItems: [],
  }),
  mounted() {
    this.$content(`fr/actualites`)
      .where({ active: true })
      .sortBy('createdAt', 'desc')
      .fetch()
      .then((news) => {
        this.newsItems = news
      })
      .catch((error) => {
        console.log(error)
      })
      .finally(() => {
        if (this.$route.hash) {
          document
            .getElementById(this.$route.hash.substring(1))
            .scrollIntoView()
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
  margin-bottom: 0;
}

.CardPicture {
  height: 200px;
}

.PictureCredit {
  position: absolute;
  right: 12px;
  bottom: 9px;
}

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
