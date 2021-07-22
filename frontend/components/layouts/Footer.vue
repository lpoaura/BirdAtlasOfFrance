<template>
  <footer>
    <div class="MenuWrapper">
      <img class="ODFLogo" src="/ODF-logo-filled.svg" />
      <div class="LinksWrapper">
        <div class="InternalLinksContent">
          <nuxt-link
            v-for="(link, index) in links"
            :key="index"
            :to="link.route"
            class="InternalLink"
          >
            <span class="fw-500">{{ link.label }}</span>
          </nuxt-link>
          <a href="http://eepurl.com/hi6NPj" target="_blank">
            <span class="fw-500">Newsletter</span>
          </a>
        </div>
        <div class="Split"></div>
        <div class="SocialNetworksContent">
          <a
            v-for="(item, index) in socialNetworksItems"
            :key="index"
            :href="item.link"
            target="_blank"
            class="SocialNetworksWrapper"
          >
            <img class="SocialNetworkIcon" :src="item.icon" />
          </a>
        </div>
      </div>
    </div>
    <section class="LPOSection">
      <div class="LPOCard">
        <h5 class="LPOLogoAside">
          Oiseaux de France est un <br />projet porté par la LPO
        </h5>
        <img class="LPOLogo" src="/LPO-logo.svg" />
      </div>
      <h6 class="right-margin-8">
        2021, Oiseaux de France, tous droits réservés
      </h6>
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
      {
        icon: '/github.svg',
        link: 'https://github.com/lpoaura/BirdAtlasOfFrance',
      },
    ],
  }),
}
</script>

<style scoped>
footer {
  width: 100%;
  padding: 40px 5%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.MenuWrapper {
  display: flex;
  align-items: center;
}

.ODFLogo {
  height: 100px;
  margin-right: 50px;
}

.LinksWrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.InternalLinksContent {
  display: flex;
  margin-bottom: 16px;
}

.InternalLink {
  margin-right: 32px;
}

.Split {
  width: 100%;
  height: 0;
  margin-bottom: 16px;
  border: 1px solid rgba(38, 38, 38, 0.1);
}

.SocialNetworksContent {
  display: flex;
}

.SocialNetworksWrapper {
  background: linear-gradient(
      rgba(107, 131, 120, 0.1),
      rgba(107, 131, 120, 0.1)
    ),
    white;
  min-width: 36px;
  max-width: 36px;
  min-height: 36px;
  max-height: 36px;
  margin-right: 32px;
  border-radius: 50%;
  display: flex;
}

.InternalLink:last-child,
.SocialNetworksWrapper:last-child {
  margin-right: 0;
}

.SocialNetworkIcon {
  width: 18px;
  margin: auto;
}

.LPOSection {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.LPOCard {
  background: rgba(38, 38, 38, 0.1);
  padding: 16px 24px;
  margin-bottom: 5px;
  border-radius: 8px;
  display: flex;
  align-items: center;
}

.LPOLogo {
  height: 48px;
  margin-left: 16px;
}

.LPOLogoAside {
  line-height: 21px;
  text-align: right;
}
</style>
