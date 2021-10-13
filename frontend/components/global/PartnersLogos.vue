<template>
  <div class="PartnersLogosGrid">
    <div
      v-for="(partner, index) in partnersToShow.list"
      :key="index"
      class="PartnerLogoItem flex"
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
        list: ['Ministere-Transition-Ecologique.jpg', 'RTE.jpg'],
      },
      {
        type: 'scientific',
        list: ['MNHN.jpg', 'OFB.jpg'],
      },
      {
        type: 'technical',
        list: [
          'ALEPE.jpg',
          'ANA.jpg',
          'Bretagne-Vivante.jpg',
          'C.O.Gard.jpg',
          'Charente-Nature.jpg',
          'Cistude-Nature.jpg',
          'Eure-et-Loir-Nature.jpg',
          'GEPOG.jpg',
          'GEPOMAY.jpg',
          'GNLA.jpg',
          'GODS.jpg',
          'GOG.jpg',
          'GON.jpg',
          'GONm.jpg',
          'GOR.jpg',
          'Indre-Nature.jpg',
          'Loiret-Nature-Environnement.jpg',
          'LPO-France.jpg',
          'LPO-AuRA.jpg',
          'LPO-Bourgogne-Franche-Comte.jpg',
          'LPO-Bretagne.jpg',
          'LPO-Grand-Est.jpg',
          'LPO-Nord.jpg',
          'LPO-Normandie.jpg',
          'LPO-Occitanie.jpg',
          'LPO-PACA.jpg',
          'LPO-Pays-de-la-Loire.jpg',
          'LPO-Touraine.jpg',
          'Mayenne-Nature-Environnement.jpg',
          'Nature-18.jpg',
          'Nature-Environnement-17.jpg',
          'ODONAT.jpg',
          'Picardie-Nature.jpg',
          'SEOF.jpg',
          'SEOR.gif',
          'SSNTG82.jpg',
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
  grid-gap: 60px;
}

.PartnerLogo {
  max-width: 100%;
  max-height: 100px;
  margin: auto;
}
</style>
