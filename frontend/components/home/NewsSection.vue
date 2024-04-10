<template>
  <section class="Section">
    <div class="SectionHeader">
      <h2 class="fw-bold">Actualités</h2>
      <div v-if="!isTouchDevice" class="CarouselNavWrapper">
        <img
          class="CarouselNav"
          :class="atHeadOfList ? 'disabled' : ''"
          src="/chevron-left-green.svg"
          @click="moveCarousel(-1)"
        />
        <img
          class="CarouselNav"
          :class="atEndOfList ? 'disabled' : ''"
          src="/chevron-right-green.svg"
          @click="moveCarousel(1)"
        />
      </div>
    </div>
    <h5 class="fw-600 Subtitle">
      <nuxt-link to="/news">Voir toutes les actualités</nuxt-link>
    </h5>
    <div class="CarouselWrapper">
      <div
        class="Carousel"
        :style="{ transform: 'translateX' + '(' + currentOffset + 'px' + ')' }"
      >
        <div v-for="(news, index) in newsItems" :key="index" class="NewsCard">
          <div class="CardHeader bottom-margin-16">
            <div
              class="CardPicture"
              :src="news.picture"
              :style="{
                background: `url(/news/${news.picture}) center / cover`,
              }"
            ></div>
            <span class="black03 bottom-margin-8">
              {{ news.author }} &nbsp;•&nbsp;
              {{ $formatDate(news.date, true) }}
            </span>
            <h4 class="CardTitle fw-bold bottom-margin-16">
              {{ news.title }}
            </h4>
            <nuxt-content :document="news" />
            <div class="CardBlurring"></div>
          </div>
          <div class="CardFooter">
            <div class="TagMenu">
              <div
                v-for="(tag, tagIndex) in news.tags"
                :key="tagIndex"
                class="Tag"
              >
                {{ tag }}
              </div>
            </div>
            <nuxt-link :to="`/news/${news.slug}`" class="CardSeeMore">
              <h5 class="green01 fw-600 right-margin-8">Lire la suite</h5>
              <img src="arrow-right-green.svg" class="CardSeeMoreArrow" />
            </nuxt-link>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  data: () => ({
    newsItems: [],
    currentOffset: 0,
    maxOffset: 0,
    resizeId: 0,
    isTouchDevice: false,
  }),
  computed: {
    atEndOfList() {
      return this.currentOffset === this.maxOffset
    },
    atHeadOfList() {
      return this.currentOffset === 0
    },
  },
  beforeMount() {
    this.isTouchDevice =
      'ontouchstart' in window ||
      navigator.maxTouchPoints > 0 ||
      navigator.msMaxTouchPoints > 0
    window.addEventListener('resize', this.listener)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.listener)
  },
  mounted() {
    this.$content(`fr/actualites`)
      .where({ active: true, date: { $lte: new Date() } })
      // .where({ active: true,})
      .sortBy('date', 'desc')
      .fetch()
      .then((news) => {
        this.newsItems = news
      })
      .catch((error) => {
        console.debug(`${error}`)
      })
      .finally(() => {
        this.maxOffset = this.calculateMaxOffset()
      })
  },
  methods: {
    listener() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      clearTimeout(this.resizeId)
      this.resizeId = setTimeout(this.resizingDone, 200)
    },
    resizingDone() {
      this.maxOffset = this.calculateMaxOffset()
      if (this.currentOffset < this.maxOffset) {
        this.currentOffset = this.maxOffset
      }
    },
    moveCarousel(direction) {
      this.maxOffset = this.calculateMaxOffset()
      const paginationFactor = this.calculateCardWidth()
      if (direction === 1 && !this.atEndOfList) {
        if (this.currentOffset - paginationFactor < this.maxOffset) {
          this.currentOffset = this.maxOffset
        } else {
          this.currentOffset -= paginationFactor
        }
      } else if (direction === -1 && !this.atHeadOfList) {
        if (this.currentOffset + paginationFactor > 0) {
          this.currentOffset = 0
        } else {
          this.currentOffset += paginationFactor
        }
      }
    },
    calculateMaxOffset() {
      const totalCardsWidth =
        document.getElementsByClassName('Carousel')[0].offsetWidth
      const carouselWrapperWidth =
        document.getElementsByClassName('CarouselWrapper')[0].offsetWidth
      if (totalCardsWidth > carouselWrapperWidth) {
        return -(totalCardsWidth - carouselWrapperWidth)
      } else {
        return 0
      }
    },
    calculateCardWidth() {
      const cardWidth =
        document.getElementsByClassName('NewsCard')[0].offsetWidth
      const cardMarginRight = parseFloat(
        window.getComputedStyle(document.getElementsByClassName('NewsCard')[0])
          .marginRight
      )
      return cardWidth + cardMarginRight
    },
  },
}
</script>

<style scoped>
.Section {
  padding: 40px 0 32px;
  background: rgba(57, 118, 90, 0.1);
}

.SectionHeader {
  margin: 0 5%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

h5.Subtitle {
  margin-left: 5%;
  margin-bottom: 32px;
}

.CarouselNavWrapper {
  display: flex;
  justify-content: flex-end;
}

.CarouselNav {
  height: 20px;
  margin-left: 40px;
  cursor: pointer;
}

.CarouselNav.disabled {
  opacity: 0;
  cursor: auto;
}

.CarouselWrapper {
  width: 100%;
  overflow-x: scroll;
  touch-action: pan-x;
  -webkit-overflow-scrolling: touch; /* iOS */

  /* Hide scrollbar */
  -ms-overflow-style: none; /* IE and Edge */
  scrollbar-width: none; /* Firefox */
}

/* Hide scrollbar for Chrome, Safari and Opera */
.CarouselWrapper::-webkit-scrollbar {
  display: none;
}

.Carousel {
  padding: 0 5%;
  display: inline-flex;
  transition: transform 150ms ease-out;
  transform: translateX(0);
}

.NewsCard {
  width: 410px;
  height: 466px;
  margin: 8px 24px 8px 0;
  justify-content: space-between;
}

.NewsCard:last-child {
  margin-right: 0;
}

.CardHeader {
  position: relative;
}

.CardHeader,
.CardFooter {
  display: flex;
  flex-direction: column;
}

.CardHeader,
.nuxt-content-container {
  flex: 1;
  overflow-y: hidden;
}

.CardPicture {
  height: 190px;
}

.CardTitle {
  max-height: 48px;
  overflow-y: hidden;
}

.CardBlurring {
  background: linear-gradient(
    0deg,
    rgba(252, 252, 252, 1) 0%,
    rgba(252, 252, 252, 0) 100%
  );
  position: absolute;
  z-index: 1;
  left: 0;
  bottom: 0;
  width: 100%;
  height: 26px;
}

/********** RESPONSIVE **********/

@media screen and (width <= 680px) {
  .Section {
    padding: 46px 0 16px;
  }

  .CarouselNav {
    height: 14px;
    margin-left: 30px;
  }

  h5.Subtitle {
    margin-bottom: 8px !important;
  }

  .NewsCard {
    width: 342px;
    max-width: 90vw;
    height: 412px;
    margin-right: 20px;
  }

  .CardPicture {
    height: 160px;
  }

  .CardTitle {
    max-height: 42px;
  }

  .NewsCard h4.bottom-margin-16 {
    margin-bottom: 8px !important;
  }
}
</style>
