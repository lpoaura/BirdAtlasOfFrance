<template>
  <div class="PartnersLogosGrid">
    <div
      v-for="(partner, index) in normalizedPartners"
      :key="index"
      class="PartnerLogoItem display-flex"
    >
      <a
        v-if="partner.url"
        :href="partner.url"
        target="_blank"
        rel="noopener noreferrer"
        class="PartnerLogoLink"
      >
        <img
          class="PartnerLogo"
          :src="`/what-is-ODF-project/partners-logo/${partner.file}`"
          :alt="partner.file"
        />
      </a>
      <img
        v-else
        class="PartnerLogo"
        :src="`/what-is-ODF-project/partners-logo/${partner.file}`"
      />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    partnersType: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    // Lien vers les sites des partenaires
    partnersList: [
      {
        type: 'financial',
        list: ['Ministere-Transition-Ecologique.webp', 'RTE.webp', 'EDF.jpg'],
      },
      {
        type: 'scientific',
        list: ['MNHN.webp', 'OFB.webp'],
      },
      {
        type: 'technical',
        list: [
          'ALEPE.webp',
          'Amazona.jpg',
          'ANA.webp',
          'A_Pichjarinaatroit-1050.jpg',
          'BCNC.jpg',
          'Bretagne-VivanteLogo-duo.webp',
          'Caudalis.png',
          'C.O.Gard.webp',
          'Charente-Nature.webp',
          'Cistude-Nature.webp',
          'Eure-et-Loir-Nature.webp',
          'FNE_Logo_Centre-Val-de-Loire.png',
          'GEPOG.webp',
          'GEPOMAY.webp',
          'GNLA.webp',
          'GODS.webp',
          'GOG.webp',
          'GON.webp',
          'GONm.webp',
          'GOR.webp',
          'Indre-Nature.webp',
          'Loire_et_cher_nature.jpg',
          'Loiret-Nature-Environnement.webp',
          'LPO_LOGOTYPE_HD.jpg',
          // 'LPO_logo_court.jpg',
          // 'LPO-AuRA.webp',
          // 'LPO-Bourgogne-Franche-Comte.webp',
          // 'LPO-Bretagne.webp',
          // 'LPO-Grand-Est.webp',
          // 'LPO-Nord.webp',
          // 'LPO-Normandie.webp',
          // 'LPO-Occitanie.webp',
          // 'LPO-PACA.webp',
          // 'LPO-Pays-de-la-Loire.webp',
          // 'LPO-Touraine.webp',
          'manu_sop.jpg',
          'Mayenne-Nature-Environnement.webp',
          'Nature-18.webp',
          'Nature-Environnement-17.webp',
          'Nature-Nievre.jpg',
          'ODONAT.webp',
          'Office-national-des-Forets-ONF.png',
          'PN_Pyrenees.png',
          'Picardie-Nature.webp',
          'SEOF.webp',
          'SEOR.gif',
          'sne.png',
          'SSNTG82.webp',
          'Vienne_Nature.png',
        ],
      },
      {
        type: 'bdd',
        list: [
          { file: 'clicnat.png', url: 'https://clicnat.fr' },
          { file: 'ebird.png', url: 'https://www.ebird.org' },
          { file: 'Faune_France.png', url: 'https://www.faune-france.org' },
          { file: 'FNE_Logo_Centre-Val-de-Loire_complet.png', url: 'https://natureocentre.org' },
          { file: 'SIRF.png', url: 'https://gon.fr/sirf' },
        ],
      },
    ],
  }),
  computed: {
    partnersToShow() {
      const partners = this.partnersList.filter((partners) => {
        return partners.type === this.partnersType
      })
      return partners[0]
    },
    normalizedPartners() {
      if (!this.partnersToShow) return []
      return this.partnersToShow.list.map((partner) => {
        if (typeof partner === 'string') {
          return { file: partner, url: null }
        }
        return partner
      })
    },
  },
}
</script>

<style scoped>
.PartnersLogosGrid {
  width: 100%;
  background: #fff;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 30px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  row-gap: 36px;
  column-gap: 60px;
}

.PartnerLogoLink {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
}

.PartnerLogoLink:hover .PartnerLogo {
  opacity: 0.8;
}

.PartnerLogo {
  max-width: 100%;
  max-height: 100px;
  margin: auto;
}
</style>
