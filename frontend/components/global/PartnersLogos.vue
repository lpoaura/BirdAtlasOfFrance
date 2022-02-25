<template>
  <div class="PartnersLogosGrid">
    <div
      v-for="(partner, index) in partnersToShow.list"
      :key="index"
      class="PartnerLogoItem display-flex"
    >
      <img
        class="PartnerLogo"
        :src="`/what-is-ODF-project/partners-logo/${partner}`"
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
        list: ['Ministere-Transition-Ecologique.webp', 'RTE.webp'],
      },
      {
        type: 'scientific',
        list: ['MNHN.webp', 'OFB.webp'],
      },
      {
        type: 'technical',
        list: [
          'ALEPE.webp',
          'ANA.webp',
          'Bretagne-Vivante.webp',
          'C.O.Gard.webp',
          'Charente-Nature.webp',
          'Cistude-Nature.webp',
          'Eure-et-Loir-Nature.webp',
          'GEPOG.webp',
          'GEPOMAY.webp',
          'GNLA.webp',
          'GODS.webp',
          'GOG.webp',
          'GON.webp',
          'GONm.webp',
          'GOR.webp',
          'Indre-Nature.webp',
          'Loiret-Nature-Environnement.webp',
          'LPO-France.webp',
          'LPO-AuRA.webp',
          'LPO-Bourgogne-Franche-Comte.webp',
          'LPO-Bretagne.webp',
          'LPO-Grand-Est.webp',
          'LPO-Nord.webp',
          'LPO-Normandie.webp',
          'LPO-Occitanie.webp',
          'LPO-PACA.webp',
          'LPO-Pays-de-la-Loire.webp',
          'LPO-Touraine.webp',
          'Mayenne-Nature-Environnement.webp',
          'Nature-18.webp',
          'Nature-Environnement-17.webp',
          'ODONAT.webp',
          'Picardie-Nature.webp',
          'SEOF.webp',
          'SEOR.gif',
          'SSNTG82.webp',
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

.PartnerLogo {
  max-width: 100%;
  max-height: 100px;
  margin: auto;
}
</style>
