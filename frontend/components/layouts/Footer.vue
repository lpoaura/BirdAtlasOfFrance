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
            <h5 class="fw-500">{{ link.label }}</h5>
          </nuxt-link>
          <a href="http://eepurl.com/hi6NPj" target="_blank">
            <h5 class="fw-500">Newsletter</h5>
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
      <h5 class="LPOLogoAside">
        Oiseaux de France est<br />un projet porté par
      </h5>
      <img class="LPOLogo" src="/LPO-logo.svg" />
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
        link: 'https://www.youtube.com/channel/UCI13cz60YLX3DHEeOEBxdMg',
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
  height: 72px;
  margin-right: 32px;
}

.LinksWrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.InternalLinksContent {
  display: flex;
}

.InternalLink {
  margin-right: 32px;
}

.Split {
  width: 100%;
  height: 1px;
  min-height: 1px;
  margin: 10px 0;
  background: rgba(38, 38, 38, 0.1);
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
  min-width: 32px;
  max-width: 32px;
  min-height: 32px;
  max-height: 32px;
  margin-right: 32px;
  border-radius: 50%;
  display: flex;
}

.InternalLink:last-child,
.SocialNetworksWrapper:last-child {
  margin-right: 0;
}

.SocialNetworkIcon {
  width: 16px;
  margin: auto;
}

.LPOSection {
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
