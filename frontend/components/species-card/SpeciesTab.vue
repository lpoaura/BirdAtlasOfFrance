<template>
  <div class="SpeciesCardContent" :class="status">
    <div class="Row">
      <div class="Column">
        <h4 id="description" class="black02 fw-bold bottom-margin-8">
          Description
        </h4>
        <span v-if="species.attributes.description" class="black02">
          {{ species.attributes.description }}
        </span>
        <span v-else class="black02">
          Pas de description disponible actuellement pour cette espèce.
        </span>
      </div>
      <pictures-carousel
        v-if="species.medias.Photos"
        :pictures="species.medias.Photos"
      />
    </div>
    <!-- <div class="Row">
      <div class="Column">
        Taxonomie
      </div>
      <div class="Column">
        Statuts
      </div>
    </div> -->
  </div>
</template>

<script>
import PicturesCarousel from '~/components/species-card/PicturesCarousel.vue'

export default {
  components: {
    'pictures-carousel': PicturesCarousel,
  },
  props: {
    status: {
      type: String,
      required: true,
    },
    species: {
      type: Object,
      required: true,
    },
  },
}
</script>

<style scoped>
.Row {
  margin-bottom: 40px;
  display: flex;
}

.Row:last-child {
  margin-bottom: 0;
}

.Row .Column {
  flex: 1;
  margin-right: 24px;
  display: flex;
  flex-direction: column;
}

.Row .Column:last-child {
  margin-right: 0;
}
</style>
