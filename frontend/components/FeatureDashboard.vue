<template>
  <v-navigation-drawer v-model="drawer" fixed app right>
    <v-container style="padding-top: 80px">
      <v-row align="center">
        <v-col cols="12">
          <v-btn icon @click.stop="drawer = !drawer">
            <v-icon>mdi-close-box</v-icon>
          </v-btn>
          <div class="text-center">
            <h3>Tableau de bord de la maille consultée</h3>
          </div>
          <br />
          <div v-if="clickedFeature !== null">
            <h4 class="text-center">
              Complétude de prospection<br />
              {{
                toPercent(
                  selectedSeason === 'breeding'
                    ? clickedFeature.properties.breeding.percent_knowledge
                    : selectedSeason === 'wintering'
                    ? clickedFeature.properties.wintering.percent_knowledge
                    : clickedFeature.properties.all_period.percent_knowledge
                )
              }}
              %
            </h4>
            <br />
            <b>id : {{ clickedFeature.id }}</b
            ><br />
            <span>{{ clickedFeature.properties }}</span>
          </div>
        </v-col>
      </v-row>
    </v-container>
  </v-navigation-drawer>
</template>

<script>
export default {
  props: {
    drawer: {
      type: Boolean,
      required: true,
      default: true,
    },
    clickedFeature: {
      type: Object,
      required: false,
      default: null,
    },
    selectedSeason: {
      type: String,
      required: true,
      default: 'breeding',
    },
  },
  methods: {
    toPercent(decimal) {
      return Math.round(decimal * 100)
    },
  },
}
</script>
