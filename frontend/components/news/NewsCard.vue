<!-- Partager sur LinkedIn : href="https://www.linkedin.com/sharing/share-offsite/?url=https://oiseauxdefrance.org/news" -->
<!-- Partager sur Facebook : href="https://www.facebook.com/sharer/sharer.php?u=https://oiseauxdefrance.org/news" -->
<!-- Partager sur Twitter : href="https://twitter.com/intent/tweet?url=https://oiseauxdefrance.org/news" -->
<template>
  <div class="NewsCard">
    <div
      class="CardPicture"
      :src="news.picture"
      :style="{
        background: `url(/news/${news.picture}) ${news.centering} / cover`,
      }"
    >
      <h5 class="white02 PictureCredit">{{ news.credit }}</h5>
    </div>
    <span class="black03 bottom-margin-16">
      {{ news.author }} &nbsp;•&nbsp;
      {{ $formatDate(news.date, true) }}
    </span>
    <h3 class="black02 fw-600 bottom-margin-16">
      {{ news.title }}
    </h3>
    <nuxt-content :document="news" />
    <div class="CardFooter">
      <div class="TagMenu no-bottom-margin">
        <div v-for="(tag, tagIndex) in news.tags" :key="tagIndex" class="Tag">
          {{ tag }}
        </div>
      </div>
      <nuxt-link
        v-if="
          !['/news', '/en/news'].includes(
            $route.path.endsWith('/') && $route.path.length > 1
              ? $route.path.slice(0, -1)
              : $route.path
          )
        "
        to="/news"
        class="CardSeeMore top-margin-24"
      >
        <h5 class="green01 fw-600 right-margin-8">
          Voir les autres actualités
        </h5>
        <img src="/arrow-right-green.svg" class="CardSeeMoreArrow" />
      </nuxt-link>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    news: {
      type: Object,
      required: true,
    },
  },
}
</script>

<style scoped>
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

.CardFooter {
  display: flex;
  flex-direction: column;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
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
