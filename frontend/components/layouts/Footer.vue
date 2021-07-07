<template>
  <footer>
    <img class="ODFLogo" src="/ODF-logo-filled.svg" />
    <div class="SocialNetworksContent">
      <a
        v-for="(item, index) in socialNetworksItems"
        :key="index"
        :href="item.link"
        target="_blank"
        class="SocialNetworksItem"
      >
        <img class="SocialNetworksIcon" :src="item.icon" />
      </a>
    </div>
    <div class="LinksContent">
      <nuxt-link
        v-for="(link, index) in links"
        :key="index"
        :to="link.route"
        class="Link"
      >
        {{ link.label }}
      </nuxt-link>
    </div>
    <section class="LPOSection">
      <img class="LPOLogo" src="/LPO-logo.svg" />
      <div class="LPOText">
        <span> Oiseaux de France est un projet porté par la LPO </span>
        <span>2021, Oiseaux de France, tous droits réservés</span>
      </div>
    </section>
  </footer>
</template>

<script>
export default {
  data: () => ({
    links: [
      { label: 'À propos', route: '/about' },
      { label: 'Contact', route: '/about/contact' },
      { label: 'Mentions légales', route: '/about/legal-notices' },
      // À REVOIR
      { label: 'Newsletter', route: '#' },
    ],
    socialNetworksItems: [
      {
        icon: '/mail-filled.svg',
        link: 'mailto:oiseauxdefrance@lpo.fr',
      },
      {
        icon: '/youtube.svg',
        link: 'https://www.youtube.com/channel/UCFTACrbTuk_XdbWFYf0SYxw',
      },
    ],
  }),
}
</script>

<style scoped>
footer {
  width: 100%;
  height: 186px;
  padding: 0 5%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ODFLogo {
  height: 100px;
}

.SocialNetworksContent {
  height: 100px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.SocialNetworksItem {
  background: rgba(57, 118, 90, 0.1);
  min-width: 40px;
  max-width: 40px;
  min-height: 40px;
  max-height: 40px;
  border-radius: 50%;
  display: flex;
}

.SocialNetworksIcon {
  width: 20px;
  margin: auto;
}

.LinksContent {
  height: 100px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.Link {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 12px;
  line-height: 18px;
  text-decoration: none;
  color: #262626;
}

.LPOSection {
  background: rgba(38, 38, 38, 0.1);
  height: 100px;
  padding: 24px 3%;
  border-radius: 8px;
  display: flex;
  align-items: center;
}

.LPOLogo {
  height: 100%;
  margin-right: 30px;
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
