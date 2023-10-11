<template>
  <div class="PicturesCarousel">
    <div class="ActivePicture">
      <img :src="activePicture.url" />
      <div class="CarouselNavWrapper">
        <div
          class="CarouselNav"
          :class="atHeadOfList ? 'disabled' : ''"
          @click="previousPicture"
        >
          <img class="CarouselNavChevron" src="/chevron-left.svg" />
        </div>
        <div
          class="CarouselNav"
          :class="atEndOfList ? 'disabled' : ''"
          @click="nextPicture"
        >
          <img class="CarouselNavChevron" src="/chevron-right.svg" />
        </div>
      </div>
    </div>
    <div class="ActivePictureDescription">
      <h5 class="black02 fw-600" v-html="activePicture.title"></h5>
      <h5 class="black02">{{ activePicture.author }}</h5>
    </div>
    <div class="ThumbnailsWrapper">
      <div
        class="ThumbnailsCarousel"
        :style="{ transform: 'translateX' + '(' + currentOffset + 'px' + ')' }"
      >
        <div
          v-for="(picture, index) in pictures"
          :key="index"
          class="Thumbnail"
          :class="activePictureIndex === index ? 'active' : ''"
          :style="{ background: `url('${picture.url}') center / cover` }"
          @click="activatePicture(index)"
        ></div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    pictures: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
    activePictureIndex: 0,
    thumbnailsVisibleNumber: 3,
    currentOffset: 0,
    maxOffset: 0,
  }),
  computed: {
    activePicture() {
      return this.pictures[this.activePictureIndex]
    },
    atEndOfList() {
      return this.activePictureIndex === this.pictures.length - 1
    },
    atHeadOfList() {
      return this.activePictureIndex === 0
    },
  },
  mounted() {
    document
      .getElementsByClassName('PicturesCarousel')[0]
      .style.setProperty('--thumbnailsnumber', this.thumbnailsVisibleNumber)
    this.maxOffset = this.calculateMaxOffset()
  },
  methods: {
    previousPicture() {
      const active = this.activePictureIndex - 1
      if (active >= 0) {
        this.activatePicture(active)
      }
      if (active >= this.thumbnailsVisibleNumber - 1) {
        this.moveThumbnailsCarousel(-1)
      }
    },
    nextPicture() {
      const active = this.activePictureIndex + 1
      if (active < this.pictures.length) {
        this.activatePicture(active)
      }
      if (active >= this.thumbnailsVisibleNumber) {
        this.moveThumbnailsCarousel(1)
      }
    },
    activatePicture(index) {
      this.activePictureIndex = index
    },
    moveThumbnailsCarousel(direction) {
      this.maxOffset = this.calculateMaxOffset()
      const paginationFactor = this.calculateThumbnailWidth()
      if (direction === 1) {
        if (this.currentOffset - paginationFactor < this.maxOffset) {
          this.currentOffset = this.maxOffset
        } else {
          this.currentOffset -= paginationFactor
        }
      } else if (direction === -1) {
        if (this.currentOffset + paginationFactor > 0) {
          this.currentOffset = 0
        } else {
          this.currentOffset += paginationFactor
        }
      }
    },
    calculateMaxOffset() {
      const totalThumbnailsWidth =
        document.getElementsByClassName('ThumbnailsCarousel')[0].offsetWidth
      const thumbnailsWrapperWidth =
        document.getElementsByClassName('ThumbnailsWrapper')[0].offsetWidth
      if (totalThumbnailsWidth > thumbnailsWrapperWidth) {
        return -(totalThumbnailsWidth - thumbnailsWrapperWidth)
      } else {
        return 0
      }
    },
    calculateThumbnailWidth() {
      const thumbnailWidth =
        document.getElementsByClassName('Thumbnail')[0].offsetWidth
      const thumbnailMarginRight = parseFloat(
        window.getComputedStyle(document.getElementsByClassName('Thumbnail')[0])
          .marginRight
      )
      return thumbnailWidth + thumbnailMarginRight
    },
  },
}
</script>

<style scoped>
.PicturesCarousel {
  --carouselwidth: min(384px, 90vw);
  --thumbnailsnumber: 0;

  width: var(--carouselwidth);
  user-select: none; /* Prevent from double click selection */
  display: flex;
  flex-direction: column;
}

.ActivePicture {
  position: relative;
  background: rgba(0, 0, 0, 0.05);
  width: 100%;
  height: 256px;
  display: flex;
}

.ActivePicture img {
  max-width: 100%;
  max-height: 100%;
  margin: auto;
}

.CarouselNavWrapper {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 32px;
  margin: auto;
  padding: 0 16px;
  display: flex;
  justify-content: space-between;
}

.CarouselNav {
  background: linear-gradient(
      rgba(252, 252, 252, 0.8),
      rgba(252, 252, 252, 0.8)
    ),
    white;
  width: 32px;
  height: 32px;
  cursor: pointer;
  border-radius: 4px;
  display: flex;
}

.CarouselNav.disabled {
  opacity: 0;
  cursor: auto;
}

.CarouselNavChevron {
  height: 8px;
  margin: auto;
}

.ActivePictureDescription {
  width: 100%;
  height: 34px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ThumbnailsWrapper {
  width: 100%;
  overflow-x: hidden;
}

.ThumbnailsCarousel {
  display: inline-flex;
  transition: transform 150ms ease-out;
  transform: translateX(0);
}

.Thumbnail {
  width: calc(
    (var(--carouselwidth) - (var(--thumbnailsnumber) - 1) * 8px) /
      var(--thumbnailsnumber)
  );
  height: 70px;
  margin-right: 8px;
  border-radius: 4px;
  cursor: pointer;
}

.Thumbnail:last-child {
  margin-right: 0;
}

.Thumbnail.active {
  border: 2px solid #eece25;
  box-sizing: border-box;
}

/********** RESPONSIVE **********/

@media screen and (width <= 740px) {
  .PicturesCarousel {
    align-self: center;
  }
}
</style>
