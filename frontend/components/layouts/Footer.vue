<!-- À mettre à jour -->
<template>
  <footer>
    <img class="ODFLogo" src="/ODF-logo-detailed.svg" />
    <div class="LinksContent">
      <nuxt-link
        v-for="(link, index) in links"
        :key="index"
        :to="link.routerPath"
        class="Link"
      >
        {{ link.label }}
      </nuxt-link>
    </div>
    <div class="SocialNetworksContent">
      <div
        v-for="(item, index) in socialNetworksItems"
        :key="index"
        class="SocialNetworksItem"
      >
        <img class="SocialNetworksIcon" :src="item.icon" />
        <span class="SocialNetworksTitle">{{ item.title }}</span>
        <span class="SocialNetworksSubtitle" v-html="item.subtitle"></span>
      </div>
    </div>
    <section class="LPOSection">
      <div class="LPOContent">
        <img class="LPOLogo" src="/LPO-logo.svg" />
        <div class="LPOText">
          <span>
            Oiseaux de France est un projet porté par la Ligue de Protection des
            Oiseaux
          </span>
          <span>2021, Oiseaux de France, tous droits réservés</span>
        </div>
      </div>
    </section>
  </footer>
</template>

<script>
export default {
  data: () => ({
    links: [
      { label: 'À propos', routerPath: '/about' },
      { label: 'Contact', routerPath: '/about/contact' },
      { label: 'Mentions légales', routerPath: '#' },
    ],
    socialNetworksItems: [
      {
        icon: '/mail-filled.svg',
        title: 'Mail',
        subtitle:
          '<a href="mailto:oiseauxdefrance@lpo.fr">oiseauxdefrance@lpo.fr</a>',
      },
      { icon: '/youtube.svg', title: 'Youtube', subtitle: 'LPO' },
    ],
  }),
}
</script>

<style scoped>
footer {
  width: 100%;
  padding: 0 5%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.ODFLogo {
  width: 150px;
  margin-bottom: 14px;
}

.LinksContent {
  width: 360px;
  margin-bottom: 40px;
  display: flex;
  justify-content: space-between;
}

.Link {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 14px;
  line-height: 21px;
  text-decoration: none;
  color: #262626;
}

.SocialNetworksContent {
  width: 320px;
  margin-bottom: 40px;
  display: flex;
  justify-content: space-between;
}

.SocialNetworksItem {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.SocialNetworksIcon {
  width: 24px;
  margin-bottom: 10px;
}

.SocialNetworksTitle {
  margin-bottom: 10px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 16px;
  line-height: 24px;
  color: #000;
}

.SocialNetworksSubtitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #000;
}

.LPOSection {
  background: rgba(38, 38, 38, 0.1);
  width: 100%;
  height: 90px;
  margin-bottom: 24px;
  border-radius: 8px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.LPOContent {
  width: 630px;
  height: 44px;
  display: flex;
  justify-content: space-between;
}

.LPOLogo {
  height: 100%;
}

.LPOText {
  height: 100%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 12px;
  line-height: 18px;
  color: #262626;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
</style>
