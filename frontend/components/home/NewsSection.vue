<!-- Remplacer le nombre d'actualités par items.length -->
<template>
  <section class="HomeSection">
    <div class="HomeSectionHeader">
      <h2 class="fw-bold">Actualités</h2>
      <div class="CarouselNavWrapper">
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
    <h5 class="fw-600 bottom-margin-40">
      <nuxt-link to="#">Voir toutes les actualités</nuxt-link>
    </h5>
    <div class="CarouselWrapper">
      <div
        class="Carousel"
        :style="{ transform: 'translateX' + '(' + currentOffset + 'px' + ')' }"
      >
        <div class="CarouselCard">1</div>
        <div class="CarouselCard">2</div>
        <div class="CarouselCard">3</div>
        <div class="CarouselCard">4</div>
        <div class="CarouselCard">5</div>
        <div class="CarouselCard">6</div>
        <div class="CarouselCard">7</div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  data: () => ({
    currentOffset: 0,
    maxOffset: 0,
    resizeId: 0,
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
    window.addEventListener('resize', this.$debounce(this.detectResize))
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.$debounce(this.detectResize))
  },
  mounted() {
    this.maxOffset = this.calculateMaxOffset()
  },
  methods: {
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
      const totalCardsWidth = this.calculateTotalCardsWidth()
      const carouselWrapperWidth = document.getElementsByClassName(
        'CarouselWrapper'
      )[0].offsetWidth
      if (totalCardsWidth > carouselWrapperWidth) {
        return -(totalCardsWidth - carouselWrapperWidth)
      } else {
        return 0
      }
    },
    calculateTotalCardsWidth() {
      const cardWidth = document.getElementsByClassName('CarouselCard')[0]
        .offsetWidth
      const cardMargin = parseFloat(
        window.getComputedStyle(
          document.getElementsByClassName('CarouselCard')[0]
        ).marginRight
      )
      // Remplacer le 7 par le nombre d'actualités actives 'items.length'
      return 7 * (cardWidth + cardMargin) - cardMargin
    },
    calculateCardWidth() {
      const cardWidth = document.getElementsByClassName('CarouselCard')[0]
        .offsetWidth
      const cardMargin = parseFloat(
        window.getComputedStyle(
          document.getElementsByClassName('CarouselCard')[0]
        ).marginRight
      )
      return cardWidth + cardMargin
    },
  },
}
</script>

<style scoped>
.HomeSection {
  background: rgba(57, 118, 90, 0.1);
}

.HomeSectionHeader {
  display: flex;
  justify-content: space-between;
  align-items: center;
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
  overflow-x: hidden;
}

.Carousel {
  display: inline-flex;
  transition: transform 150ms ease-out;
  transform: translateX(0);
}

.CarouselCard {
  width: 302px;
  height: 382px;
  margin-right: 24px;
  background: coral;
}

.CarouselCard:last-child {
  margin-right: 0;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 680px) {
  h5.bottom-margin-40 {
    margin-bottom: 16px !important;
  }

  .CarouselNav {
    height: 14px;
    margin-left: 30px;
  }

  .CarouselCard {
    width: 162px;
    height: 172px;
    margin-right: 20px;
  }
}
</style>
