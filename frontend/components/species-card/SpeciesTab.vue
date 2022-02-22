<template>
  <div class="SpeciesCardContent" :class="tabStatus">
    <div
      v-if="species.attributes.description || species.medias.Photos"
      id="description"
      class="Row"
      :style="{ height: readMore || !species.medias.Photos ? 'auto' : '367px' }"
    >
      <div class="Column read-more-wrapper">
        <div class="read-more">
          <h4 class="black02 fw-bold bottom-margin-16">Description</h4>
          <span
            v-if="species.attributes.description"
            ref="description"
            class="black02"
          >
            {{ species.attributes.description }}
          </span>
          <span v-else class="black02">
            Pas de description disponible actuellement pour cette espèce.
          </span>
          <div
            v-if="descriptionHeight > 327 && !readMore"
            class="Blurring"
          ></div>
        </div>
        <div v-if="descriptionHeight > 327 && !readMore" class="display-flex">
          <span
            class="green01 fw-600 pointer ReadMore"
            @click="readMore = !readMore"
          >
            Lire plus
          </span>
        </div>
        <div v-if="descriptionHeight > 327 && readMore" class="display-flex">
          <span
            class="green01 fw-600 pointer ReadMore"
            @click="readMore = !readMore"
          >
            Lire moins
          </span>
        </div>
      </div>
      <pictures-carousel
        v-if="species.medias.Photos"
        :pictures="species.medias.Photos"
      />
    </div>
    <div
      v-if="species.redLists || species.protectionStatus"
      id="status"
      class="Column"
    >
      <div class="StatusGrid">
        <div v-if="species.redLists" class="Column">
          <h4 class="black02 fw-bold bottom-margin-16">
            Statuts de conservation
          </h4>
          <div class="StatusWrapper">
            <span class="black02 fw-bold bottom-margin-8">Listes rouges</span>
            <li
              v-if="species.redLists.world"
              class="StatusOption bottom-margin-8"
            >
              <span class="black02 flex-1 right-margin-8">Monde</span>
              <div class="black02 StatusValue">
                <div
                  class="RedListSticker"
                  :style="{
                    background: $redLists()[species.redLists.world].bgColor,
                  }"
                >
                  <h5
                    class="fw-600"
                    :style="{
                      color: $redLists()[species.redLists.world].fontColor,
                    }"
                  >
                    {{ species.redLists.world }}
                  </h5>
                </div>
              </div>
            </li>
            <li
              v-for="(item, index) in species.redLists.national"
              :key="index"
              class="StatusOption bottom-margin-8"
            >
              <span class="black02 flex-1 right-margin-8">
                {{ item.territory }}
              </span>
              <div class="black02 StatusValue">
                <div
                  class="RedListSticker"
                  :style="{ background: $redLists()[item.statut].bgColor }"
                >
                  <h5
                    class="fw-600"
                    :style="{ color: $redLists()[item.statut].fontColor }"
                  >
                    {{ item.statut }}
                  </h5>
                </div>
              </div>
            </li>
          </div>
        </div>
        <div v-if="species.protectionStatus" class="Column">
          <h4 class="black02 fw-bold bottom-margin-16">
            Statuts de protection
          </h4>
          <div v-if="species.protectionStatus.national" class="StatusWrapper">
            <li class="StatusOption">
              <span class="black02 fw-bold flex-1 right-margin-8">
                Protection nationale
              </span>
              <span class="black02 StatusValue">
                {{ species.protectionStatus.national }}
              </span>
            </li>
          </div>
          <div
            v-if="species.protectionStatus.birdDirective"
            class="StatusWrapper"
          >
            <li class="StatusOption">
              <span class="black02 fw-bold flex-1 right-margin-8">
                Directive oiseau
              </span>
              <span class="black02 StatusValue">
                {{ species.protectionStatus.birdDirective }}
              </span>
            </li>
          </div>
        </div>
      </div>
    </div>
    <div
      v-if="filteredTraits || filteredFurtherInfo"
      id="traits"
      class="Column"
    >
      <div v-if="filteredTraits" class="Column">
        <h4 class="black02 fw-bold bottom-margin-16">Caractéristiques</h4>
        <div class="TraitsCardsGrid">
          <div
            v-for="(trait, index) in filteredTraits"
            :key="index"
            class="TraitCard"
          >
            <span class="black02 fw-600 bottom-margin-8">
              {{ trait.label }}
            </span>
            <span class="black02">
              {{ species.attributes[trait.key] }}
            </span>
          </div>
        </div>
      </div>
      <div v-if="filteredFurtherInfo" class="FurtherInfoGrid">
        <div
          v-for="(info, index) in filteredFurtherInfo"
          :key="index"
          class="Column"
        >
          <h4 class="black02 fw-bold bottom-margin-16">
            {{ info.label }}
          </h4>
          <span class="black02">
            {{ species.attributes[info.key] }}
          </span>
        </div>
      </div>
    </div>
    <div id="links" class="Column">
      <h4 class="black02 fw-bold bottom-margin-16">Liens</h4>
      <div class="LinksWrapper">
        <div class="LinksGrid">
          <li class="LinkOption">
            <img src="/eye-green.svg" class="LinkOptionIcon" />
            <span class="fw-500">
              <a
                :href="`https://inpn.mnhn.fr/espece/cd_nom/${species.cdnom}`"
                target="_blank"
              >
                Visualiser la fiche INPN de l'espèce
              </a>
            </span>
          </li>
          <li class="LinkOption">
            <img src="/pencil-green.svg" class="LinkOptionIcon" />
            <span class="fw-500">
              <a href="https://www.faune-france.org/" target="_blank">
                Saisir mes données sur Faune France
              </a>
            </span>
          </li>
          <li
            v-for="(link, index) in filteredLinks"
            :key="index"
            class="LinkOption"
          >
            <img :src="link.icon" class="LinkOptionIcon" />
            <span class="fw-500">
              <a :href="species.medias[link.key].url" target="_blank">
                {{ link.label }}
              </a>
            </span>
          </li>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PicturesCarousel from '~/components/species-card/PicturesCarousel.vue'

export default {
  components: {
    'pictures-carousel': PicturesCarousel,
  },
  props: {
    tabStatus: {
      type: String,
      required: true,
    },
    species: {
      type: Object,
      required: true,
    },
    filteredTraits: {
      type: Array,
      required: false,
      default: null,
    },
    filteredFurtherInfo: {
      type: Array,
      required: false,
      default: null,
    },
  },
  data: () => ({
    descriptionHeight: 0,
    readMore: false,
    linksList: [
      {
        label: 'Écouter le chant sur Xeno-Canto',
        key: 'xeno-canto',
        icon: '/song-green.svg',
      },
      {
        label: "Visualiser l'espèce sur EuroBirdPortal",
        key: 'euro-bird-portal',
        icon: '/eye-green.svg',
      },
    ],
  }),
  computed: {
    filteredLinks() {
      if (this.species.attributes.odf_common_name_fr) {
        // Si les données sont arrivées
        return this.linksList.filter((link) => {
          return this.species.medias[link.key]
        })
      } else {
        return []
      }
    },
  },
  watch: {
    species(newVal) {
      setTimeout(() => {
        // Le timeout permet d'être assuré que le texte est bien integré à l'élément
        if (this.$refs.description) {
          this.descriptionHeight = this.$refs.description.offsetHeight
        }
      }, 100)
    },
  },
  beforeMount() {
    window.addEventListener('resize', this.listener)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.listener)
  },
  methods: {
    listener() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      if (this.$refs.description) {
        this.descriptionHeight = this.$refs.description.offsetHeight
      }
    },
  },
}
</script>

<style scoped>
.Row {
  margin-top: 40px;
  display: flex;
}

.Row:first-child {
  margin-top: 0;
}

.Column {
  display: flex;
  flex-direction: column;
}

.Row > .Column {
  flex: 1;
  margin-right: 24px;
}

.SpeciesCardContent > .Column {
  margin-top: 40px;
}

.Row > .Column:last-child {
  margin-right: 0;
}

.SpeciesCardContent > .Column:first-child {
  margin-top: 0;
}

.read-more-wrapper {
  justify-content: space-between;
}

.read-more {
  position: relative;
  flex: 1;
  overflow-y: hidden;
  margin-bottom: 8px;
  display: flex;
  flex-direction: column;
}

.Blurring {
  background: linear-gradient(
    0deg,
    rgba(252, 252, 252, 1) 0%,
    rgba(252, 252, 252, 0) 100%
  );
  position: absolute;
  z-index: 1;
  left: 0;
  bottom: 0;
  width: 100%;
  height: 50px;
}

.StatusGrid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(max(288px, 45%), 2fr));
  grid-gap: 40px;
}

.StatusWrapper,
.LinksWrapper {
  padding: 24px 32px;
  margin-bottom: 16px;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
}

.StatusWrapper:last-child,
.LinksWrapper:last-child {
  margin-bottom: 0;
}

.StatusOption,
.LinkOption {
  list-style: none;
  display: flex;
  align-items: center;
}

.StatusOption:last-child {
  margin-bottom: 0 !important;
}

.StatusValue {
  flex: 0.7;
  display: flex;
  align-items: center;
}

.RedListSticker {
  min-width: 25px;
  max-width: 25px;
  min-height: 25px;
  max-height: 25px;
  border-radius: 6px;
  display: flex;
}

.RedListSticker > h5 {
  margin: auto;
}

.TraitsCardsGrid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  grid-auto-rows: 1fr;
  grid-gap: 16px;
}

.TraitCard {
  background: rgba(57, 118, 90, 0.05);
  border-radius: 16px;
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.FurtherInfoGrid {
  margin-top: 40px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(max(288px, 45%), 2fr));
  grid-gap: 40px;
}

.LinksGrid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(max(250px, 45%), 2fr));
  row-gap: 24px;
  column-gap: 40px;
}

.LinkOptionIcon {
  width: 16px;
  margin-right: 12px;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 740px) {
  .Row {
    height: auto !important;
    flex-direction: column;
  }

  .Row .Column {
    margin-right: 0;
    margin-bottom: 24px;
  }

  .ReadMore,
  .Blurring {
    display: none;
  }

  .StatusWrapper,
  .LinksWrapper {
    padding: 16px 24px;
  }
}
</style>
