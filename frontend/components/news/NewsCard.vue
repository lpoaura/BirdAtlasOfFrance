<template>
  <div class="NewsCard">
    <div
      class="CardPicture"
      :src="news.picture"
      :style="{
        background: `url(/news/${news.picture}) ${news.centering} / cover`
      }"
    >
      <h5 v-if="news.credit" class="white02 PictureCredit">
        Photo : {{ news.credit }}
      </h5>
    </div>
    <div class="CardMetadata">
      <span class="black03">
        {{ news.author }} &nbsp;•&nbsp;
        {{ $formatDate(news.date, true) }}
      </span>
      <div v-click-outside="closeSharing" class="CardSharingWrapper">
        <div class="CardSharing" @click="openOrCloseSharing">
          <img src="/share.svg" class="CardSharingIcon" />
        </div>
        <div v-show="sharingIsOpen" class="CardSharingBox">
          <a
            v-for="(item, index) in socialNetworks"
            :key="index"
            class="CardSharingSocialNetwork"
            :href="`${item.url}https://oiseauxdefrance.org/news/${news.slug}`"
            target="_blank"
          >
            <img class="SocialNetworkIcon" :src="item.logo" />
            <h4>{{ item.label }}</h4>
          </a>
        </div>
      </div>
    </div>
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
import Vue from 'vue' // needed to use Vue.component() function
import { VBtn } from 'vuetify/lib' // component which I need to work in markdown
Vue.component('VBtn', VBtn) // adding component globally

export default {
  props: {
    news: {
      type: Object,
      required: true
    }
  },
  data: () => ({
    sharingIsOpen: false,
    socialNetworks: [
      {
        label: 'Twitter',
        logo: '/news/twitter.svg',
        url: 'https://twitter.com/intent/tweet?url='
      },
      {
        label: 'Facebook',
        logo: '/news/facebook.svg',
        url: 'https://www.facebook.com/share.php?u='
      },
      {
        label: 'LinkedIn',
        logo: '/news/linkedin.svg',
        url: 'https://www.linkedin.com/sharing/share-offsite/?url='
      },
      {
        label: 'WhatsApp',
        logo: '/news/whatsapp.svg',
        url: 'https://api.whatsapp.com/send?text='
      }
    ]
  }),
  methods: {
    openOrCloseSharing() {
      this.sharingIsOpen = !this.sharingIsOpen
    },
    closeSharing() {
      this.sharingIsOpen = false
    }
  }
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

.CardMetadata {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.CardSharingWrapper {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.CardSharing {
  background: rgba(38, 38, 38, 0.1);
  width: 32px;
  min-width: 32px;
  height: 32px;
  min-height: 32px;
  margin-left: 16px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
}

.CardSharingIcon {
  width: 16px;
  margin: auto;
}

.CardSharingBox {
  position: absolute;
  z-index: 5;
  top: 40px;
  background: #fcfcfc;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.15);
  border-radius: 8px;
  padding: 12px;
  display: flex;
  flex-direction: column;
}

.CardSharingSocialNetwork {
  padding: 12px;
  display: flex;
  align-items: center;
}

.SocialNetworkIcon {
  width: 16px;
  margin-right: 12px;
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
