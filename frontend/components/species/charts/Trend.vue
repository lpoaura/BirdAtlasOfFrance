<template>
  <!-- Structure du composant -->
  <!-- Condition d'affichage : seuleument si idArea existe et que chartData contient au moins 2 éléments -->
  <div v-if="idArea && chartData?.length > 1" id="trend" class="ChartCard">
     <!-- Bloc Titre + Logo en flex -->
    <div class="TitleRow">
      <h4 class="black02 fw-bold bottom-margin-8">Tendance d'évolution</h4>
      <div v-if="sourceLogo" class="LogoWrapper">
        <a :href="sourceData?.[0]?.page" target="_blank" rel="noopener">
          <img :src="sourceLogo" alt="Logo source" class="SourceLogo" />
        </a>
      </div>
    </div>
    <h5 class="black03 bottom-margin-40">
      Évolution de l’indice d’abondance en fonction des années.
    </h5>
    <div class="ChartWrapper">
      <!-- Informations textuelles (.TrendsWrapper) : affiche des cartes (bulles) contenant des descriptions issues de descData. -->
      <div class="TrendsWrapper">
        <div v-for="d in descData" :key="d" class="TrendCard">
          <h5 class="black02 fw-500">{{ d.title }}</h5>
          <h5 class="black02">{{d.desc}}</h5>
        </div>
      </div>
      <!-- Le graphique (.Chart) : contient un svg qui sera manipulé par D3.js pour tracer la courbe. -->
      <div class="Chart">
        <svg class="LinePlotSvg"></svg>
      </div>
      <div v-for="d in sourceData" :key="d" class="TrendSource">
        <h5 class="black02 fw-500">Source des données : <a :href="d.page">{{d.source}}</a></h5>
      </div>
    </div>
  </div>
</template>

<script>
// Import de D3.js : une bibliothèque pour manipuler des données sous forme de graphiques SVG.
const d3 = require('d3')

export default {
  // Données du composant : apiData stocke les données récupérées depuis l'API
  data: () => ({
    apiData: null,
  }),
  // Propriétés calculées : récupère les valeurs depuis Vuex (store global de l'application)
  // chartData contient les données de la courbe et descData contient les descriptions affichées en cartes/bulles
  computed: {
    idArea() {
      return this.$store.state.species.selectedTerritory.id_area
    },
    cdNom() {
      return this.$store.state.species.cdNom
    },
    phenologyPeriod() {
      return this.$store.state.species.selectedSeason?.value
    },
    chartData() {
      return this.apiData?.data
    },
    descData(){
      return this.apiData?.descriptions
    },
    sourceData(){
      return this.apiData?.source
    },
    sourceLogo() {
      const source = this.sourceData?.[0]?.source
      if (!source) return null
      if (source.includes('SHOC')) return '/get-involved/SHOC-logo.svg'
      if (source.includes('STOC')) return '/get-involved/STOC-logo.svg'
      if (source.includes('Wetlands')) return '/get-involved/Wetlands-logo.svg'
      return null
    }
  },
  // Si idArea ou phenologyPeriod changent, le graphique est recalculé automatiquement.
  watch: {
    idArea: {
      handler() {
        this.generateChart()
      },
    },
    phenologyPeriod: {
      handler() {
        this.generateChart()
      },
    },
  },
  // Cycle de vie : dès que le composant est monté, le graphique est généré.
  mounted() {
    this.$nextTick(function () {
      this.generateChart()
    })
  },
  methods: {
    // Génération du graphique : charge les données, puis appelle renderChart() pour afficher le graphique
    generateChart() {
      this.getChartData().then(() => {
        if (this.chartData?.length > 1) {
          this.renderChart()
        }
        // Met à jour le store avec l'état du graphique
        this.$store.commit('species/pushSubjectsList', {
          label: "Tendance d'évolution",
          slug: 'trend',
          position: 4,
          status: !!this.chartData?.length,
        })
      })
    },
    // Récupération des données : effectue une requête API pour récupérer chartData et descData
    async getChartData() {
      if (this.idArea) {
        const url = `api/v1/taxa/chart/survey`
        const requestParams = {
          cd_nom: this.cdNom,
          id_area: this.idArea,
          phenology_period: this.phenologyPeriod,
          chart_type: 'trend',
        }
        this.apiData = await this.$axios
          .$get(url, {
            params: requestParams,
          })
          .catch((error) => {
            console.debug(`${error}`)
          })
      }
    },
    // Fonction qui génère le graphique avec D3.js
    renderChart() {
      // const divId = 'trend-chart-tooltip'
      // document.getElementById(divId)?.remove()
      // const div = d3
      //   .select('body')
      //   .append('div')
      //   .attr('class', 'chart-tooltip')
      //   .attr('id', divId)
      //   .style('opacity', 0)

      // Supprime l'ancien graphique (.LinePlotSvg) s'il existe.
      d3.select(this.$el).select('.LinePlotSvg').remove()
      // Ajoute un nouvel élément SVG pour contenir le graphique.
      d3.select(this.$el)
        .select('.Chart')
        .append('svg')
        .attr('class', 'LinePlotSvg')
      // Convertit chartData en un tableau d'objets avec : label: Année (X), min: Valeur minimale de l'indice d'abondance (plage basse), max: Valeur maximale (plage haute), val: Valeur principale (courbe).
      const data = this.chartData.map((i) => {
        return {
          label: i.year,
          min: i.data.val_min,
          max: i.data.val_max,
          val: i.data.val,
        }
      })

      // Get bar plot size / Définition des dimensions et marges du graphique
      const margin = { top: 10, right: 30, bottom: 24, left: 66 }
      // const minWidth = trend.length * 30 + margin.left + margin.right
      // const linePlotWidth = Math.max(
      //   parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
      //     margin.left -
      //     margin.right,
      //   minWidth
      // )
      // Calcule de la largeur en fonction de .Chart
      const linePlotWidth =
        parseFloat(d3.select(this.$el).select('.Chart').style('width')) -
        margin.left -
        margin.right
      // Calcule de la longeur en fonction de .Chart
      const linePlotHeight =
        parseFloat(d3.select(this.$el).select('.Chart').style('height')) -
        margin.top -
        margin.bottom

      // Création de l'élément SVG principal
      const linePlotSvg = d3
        .select(this.$el)
        .select('.LinePlotSvg')
        .attr('width', linePlotWidth + margin.left + margin.right)
        .attr('height', linePlotHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left}, ${margin.top})`)

      // Définition de l'axe X avec les années
      const minYear=Math.min.apply(Math, data.map(i => i.label))
      const maxYear=Math.max.apply(Math, data.map(i => i.label))

      const domain = Array((maxYear-minYear)+1).fill().map((_e, i) => minYear+i)
      console.log(domain)
      
      // xAxisYears : Crée une échelle linéaire pour positionner chaque année
      const xAxisYears = d3.scaleLinear()
        .domain([minYear, maxYear])
        .range([0, linePlotWidth]);

      linePlotSvg
        .append('g')
        .attr('class', 'xAxis')
        .attr('transform', `translate(0, ${linePlotHeight})`)
        .call(
          d3.axisBottom(xAxisYears)
            .tickFormat(d => {
              if (data.length <= 12) return d; // Affiche toutes les années si peu de données
              if (d === minYear || d === maxYear || d % 5 === 0) return d; // Affiche les min/max et x5
              return "";
            })
            .ticks(maxYear - minYear) // 1 tick par année
        )
        .call((g) =>
          g.selectAll('text')
            .attr('style', "font-family: 'Poppins', sans-serif; font-size: 12px;")
            .style('text-anchor', 'middle')
        )
        .call((g) => g.selectAll('line[y2]').style('opacity', 0));


      // Définition de l'axe Y basé sur les valeurs de l'indice d'abondance
      const yAxis = d3
        .scaleLinear()
        .range([linePlotHeight - 10, 0])
        .domain([
          d3.min(data, function (d) {
            return Math.min(...[d.min, d.max, d.val])
          }),
          d3.max(data, function (d) {
            return Math.max(...[d.min, d.max, d.val])
          }),
        ])

      // Ajout de l'axe Y au graphique
      linePlotSvg
        .append('g')
        .attr('class', 'yAxis')
        .call(d3.axisLeft(yAxis))
        .call((g) =>
          g
            .selectAll('.tick line')
            .clone()
            .attr('x2', linePlotWidth)
            .attr('stroke-opacity', 0.1)
        )
        .call((g) =>
          g
            .selectAll('text')
            .attr(
              'style',
              "font-family: 'Poppins', sans-serif; font-style: normal; font-weight: normal; font-size: 12px; line-height: 13px; color: #000;"
            )
        )
        .call((g) => g.selectAll('line[x2="-6"]').style('opacity', 0))

      // Ajout du texte pour l'axe Y
      linePlotSvg
        .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('x', -(linePlotHeight / 2))
        .attr('y', -margin.left + 10)
        .attr(
          'style',
          "text-anchor: middle; font-family: 'Poppins', sans-serif; font-style: normal; font-weight: 500; font-size: 12px; line-height: 13px; color: #000;"
        )
        .text("Indice d'abondance")

      // Suppression des lignes d'axes par défaut
      linePlotSvg.selectAll('path').style('opacity', 0)

      // Ajout de la courbe principale du graphique
      linePlotSvg
        .append('path')
        .attr('class', 'line')
        .datum(data)
        .attr('fill', 'none')
        .attr('stroke', '#435EF2')
        .attr('stroke-width', 2)
        .attr('d',d3.line()
            .x(function (d) {return xAxisYears(d.label)})
            .y(function (d) {return yAxis(d.val)})
        )

      // Ajout des points de la courbe
      linePlotSvg
        .append('g')
        .attr('class', 'dots')
        .selectAll('circle')
        .data(data)
        .enter()
        .append('circle')
        .attr('cx', function (d) {return xAxisYears(d.label)})
        .attr('cy', function (d) {return yAxis(d.val)})
        .attr('r', 4)
        .attr('fill', '#435EF2')
        // .on('mouseover', function (event, d, i) {
        //   div.transition().duration(200).style('opacity', 0.9)
        //   console.log(event, d, i)
        //   div
        //     .html(
        //       `<p class="tooltip-title"><strong>${d.label}</strong></p>
        //         ${d.unit}&nbsp;: ${d.val}`
        //     )
        //     .style('left', event.pageX + 30 + 'px')
        //     .style('top', event.pageY - 30 + 'px')
        // })
        // .on('mouseout', function (event, d) {
        //   div.style('opacity', 0)
        //   div.html('').style('left', '-500px').style('top', '-500px')
        // })


      // Ajout de la zone d'incertitude sous la courbe
      linePlotSvg
        .append('path')
        .attr('class', 'area')
        .datum(data)
        .attr('fill', 'rgba(67, 94, 242, 0.1)')
        .attr('stroke-width', 0)
        .attr('d', d3.area()
            .x(function (d) {return xAxisYears(d.label)})
            .y0(function (d) {return yAxis(d.min)})
            .y1(function (d) {return yAxis(d.max)})
        )
    },
  },
}
</script>

<style scoped>
/* Affichage en grille des cartes/bulles (TrendCard). */
.TrendsWrapper {
  margin-bottom: 16px;
  display: grid !important;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  grid-gap: 16px;
}

.TrendCard {
  min-width: 200px;
  background: linear-gradient(
    93.58deg,
    rgba(100, 120, 226, 0.1) 0%,
    rgba(67, 94, 242, 0.1) 100%
  );
  padding: 12px 16px;
  border-radius: 8px;
  white-space: nowrap;
}

.TrendSource {
  margin-top: 16px;
}

.LogoWrapper {
  position: absolute;
  z-index: 10;
  margin-top: 20px;
  margin-right: 25px;
  top: 0;
  right: 0;
  padding: 8px;
}

.SourceLogo {
  height: 40px;
  max-height: 40px;
  width: auto;
}

.ChartCard {
  position: relative;
}
</style>
