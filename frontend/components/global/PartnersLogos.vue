<template>
  <div class="PartnersLogosGrid">
    <div
      v-for="(partner, index) in partnersToShow.list"
      :key="index"
      class="PartnerLogoItem"
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
        list: ['Ministere-Transition-Ecologique.jpg', 'RTE.png'],
      },
      {
        type: 'scientific',
        list: ['MNHN.png', 'OFB.jpg'],
      },
      {
        type: 'technical',
        list: [
          'ALEPE.jpg',
          'ANA.png',
          'Bretagne-Vivante.jpg',
          'C.O.Gard.png',
          'Charente-Nature.jpg',
          'Cistude-Nature.jpg',
          'Eure-et-Loir-Nature.jpg',
          'GEPOG.png',
          'GEPOMAY.png',
          'GNLA.png',
          'GODS.jpg',
          'GOG.png',
          'GON.png',
          'GONm.png',
          'GOR.png',
          'Indre-Nature.png',
          'Loiret-Nature-Environnement.jpg',
          'LPO-France.jpg',
          'LPO-AuRA.png',
          'LPO-Bourgogne-Franche-Comte.png',
          'LPO-Bretagne.jpg',
          'LPO-Grand-Est.jpg',
          'LPO-Nord.png',
          'LPO-Normandie.png',
          'LPO-Occitanie.png',
          'LPO-PACA.png',
          'LPO-Pays-de-la-Loire.png',
          'LPO-Touraine.png',
          'Mayenne-Nature-Environnement.jpg',
          'Nature-18.jpg',
          'Nature-Environnement-17.jpg',
          'ODONAT.png',
          'Picardie-Nature.png',
          'SEOF.png',
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

.PartnerLogoItem {
  display: flex;
}

.PartnerLogo {
  max-width: 100%;
  max-height: 100px;
  margin: auto;
}
</style>
