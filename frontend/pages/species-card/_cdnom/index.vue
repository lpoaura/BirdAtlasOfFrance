<template>
  <v-container fluid>
    <header>
      <div class="Heading">
        <div
          class="SpeciesPicture"
          :style="{
            background: species.medias.Photo_principale
              ? `url('${species.medias.Photo_principale.url}') center / cover`
              : 'darkgrey',
          }"
        ></div>
        <div class="Title">
          <h3 class="fw-600">
            {{ species.attributes.odf_common_name_fr }}
          </h3>
          <h5>
            <i>{{ species.attributes.odf_sci_name }}</i> &nbsp;|&nbsp;
            {{ species.attributes.odf_common_name_en }}
            <font class="not-on-mobile">
              &nbsp;|&nbsp; Synonymes : {{ species.attributes.common_synonyms }}
            </font>
          </h5>
        </div>
      </div>
      <div class="Metadata">
        <menu class="TabMenu no-bottom-margin">
          <div
            v-for="(item, index) in tabs"
            :key="'tab' + index"
            class="TabItem"
            :class="item.hash === selectedTab.hash ? 'selected' : ''"
            @click="updateSelectedTab(item)"
          >
            {{ item.label }}
          </div>
        </menu>
        <dropdown-list
          v-model="selectedTabModel"
          :z-index="3"
          :items-list="tabs"
        />
      </div>
    </header>
    <section class="SpeciesCardSection">
      <nav class="NavDrawer">
        <menu class="TabMenu vertical no-bottom-margin">
          <div
            v-for="(item, index) in subjectsList"
            :key="'subject' + index"
            class="TabItem vertical"
            :class="item.slug === selectedSubject.slug ? 'selected' : ''"
            @click="updateSelectedSubject(item)"
          >
            {{ item.label }}
          </div>
        </menu>
      </nav>
      <div ref="scrollingContainer" class="SpeciesCardTab">
        <div class="SpeciesCardTabRelative">
          <div
            v-show="['charts', 'maps'].includes(selectedTab.value)"
            class="Selectors"
          >
            <dropdown-list
              v-model="selectedSeason"
              :z-index="2"
              :items-list="seasonsList"
              icon="/calendar-green.svg"
            />
            <dropdown-list
              v-model="selectedTerritory"
              :z-index="1"
              :items-list="territoriesList"
              icon="/location-green.svg"
            />
          </div>
          <species-tab
            :tab-status="selectedTab.value === 'species' ? '' : 'hidden'"
            :species="species"
            :filtered-traits="filteredTraits"
            :filtered-further-info="filteredFurtherInfo"
          />
          <charts-tab-all-period
            :tab-status="
              selectedTab.value === 'charts' &&
              selectedSeason.value === 'all_period'
                ? ''
                : 'hidden'
            "
            :data-phenology-all-period="dataPhenologyAllPeriod"
            :data-phenology-migration="dataPhenologyMigration"
            :data-altitude="dataAltitude"
            :data-populations-test="dataPopulationsTest"
          />
          <charts-tab-breeding
            :tab-status="
              selectedTab.value === 'charts' &&
              selectedSeason.value === 'breeding'
                ? ''
                : 'hidden'
            "
            :data-phenology-breeding="dataPhenologyBreeding"
            :data-trend="dataTrend"
            :data-populations-breeding="dataPopulationsBreeding"
            :data-altitude="dataAltitude"
          />
          <charts-tab-wintering
            :tab-status="
              selectedTab.value === 'charts' &&
              selectedSeason.value === 'wintering'
                ? ''
                : 'hidden'
            "
            :data-trend="dataTrend"
            :data-populations-wintering="dataPopulationsWintering"
            :data-altitude="dataAltitude"
          />
          <div
            class="SpeciesCardContent"
            :class="selectedTab.value === 'maps' ? '' : 'hidden'"
          >
            Cartes
          </div>
        </div>
      </div>
    </section>
  </v-container>
</template>

<script>
import SpeciesTab from '~/components/species-card/SpeciesTab.vue'
import ChartsTabAllPeriod from '~/components/species-card/ChartsTabAllPeriod.vue'
import ChartsTabBreeding from '~/components/species-card/ChartsTabBreeding.vue'
import ChartsTabWintering from '~/components/species-card/ChartsTabWintering.vue'

export default {
  components: {
    'species-tab': SpeciesTab,
    'charts-tab-all-period': ChartsTabAllPeriod,
    'charts-tab-breeding': ChartsTabBreeding,
    'charts-tab-wintering': ChartsTabWintering,
  },
  data: () => ({
    species: {
      attributes: {},
      medias: {},
      redLists: null,
      protectionStatus: null,
    },
    tabs: [
      {
        value: 'species',
        hash: '',
        label: 'Fiche espèce',
        subjects: [
          { label: 'Description', slug: 'description' },
          // { label: 'Taxonomie', slug: 'taxonomy' },
          { label: 'Statuts', slug: 'status' },
          { label: 'Caractéristiques', slug: 'traits' },
          // { label: 'Téléchargements', slug: 'downloads' },
          { label: 'Liens', slug: 'links' },
        ],
      },
      {
        value: 'charts',
        hash: '#charts',
        label: 'Diagrammes',
        subjects: {
          all_period: [
            { label: 'Phénologie', slug: 'phenology-all-period' },
            { label: 'Phénologie de migration', slug: 'phenology-migration' },
            { label: 'Répartition altitudinale', slug: 'altitude-all-period' },
          ],
          breeding: [
            { label: 'Phénologie', slug: 'phenology-breeding' },
            { label: "Tendance d'évolution", slug: 'trend-breeding' },
            {
              label: 'Taille de populations',
              slug: 'populations-size-breeding',
            },
            { label: 'Répartition altitudinale', slug: 'altitude-breeding' },
          ],
          wintering: [
            { label: "Tendance d'évolution", slug: 'trend-wintering' },
            {
              label: 'Taille de populations',
              slug: 'populations-size-wintering',
            },
            { label: 'Répartition altitudinale', slug: 'altitude-wintering' },
          ],
        },
      },
      {
        value: 'maps',
        hash: '#maps',
        label: 'Cartes',
        subjects: [{ label: 'À définir...', slug: 'none' }],
      },
    ],
    selectedTab: { hash: '', label: '', subjects: [] },
    selectedSubject: { label: '', slug: '' },
    seasonsList: [
      {
        label: 'Toutes saisons',
        value: 'all_period',
      },
      {
        label: 'Période de reproduction',
        value: 'breeding',
      },
      {
        label: "Période d'hivernage",
        value: 'wintering',
      },
    ],
    selectedSeason: {
      label: 'Toutes saisons',
      value: 'all_period',
    },
    territoriesList: [
      {
        label: 'France métropolitaine',
        icon: '/prospecting/France-metropolitaine.svg',
      },
      {
        label: 'Guadeloupe',
        icon: '/prospecting/Guadeloupe.svg',
      },
      {
        label: 'Guyane',
        icon: '/prospecting/Guyane.svg',
      },
      {
        label: 'Martinique',
        icon: '/prospecting/Martinique.svg',
      },
      {
        label: 'Mayotte',
        icon: '/prospecting/Mayotte.svg',
      },
      {
        label: 'Nouvelle Calédonie',
        icon: '/prospecting/Nouvelle-Caledonie.svg',
      },
      {
        label: 'Polynésie Française',
        icon: '/prospecting/Polynesie.svg',
      },
      {
        label: 'La Réunion',
        icon: '/prospecting/Reunion.svg',
      },
      {
        label: 'Saint Barthélémy',
        icon: '/prospecting/Saint-Barthelemy.svg',
      },
      {
        label: 'Saint Martin',
        icon: '/prospecting/Saint-Martin.svg',
      },
      {
        label: 'Saint Pierre et Miquelon',
        icon: '/prospecting/Saint-Pierre-et-Miquelon.svg',
      },
      {
        label: 'TAAF',
        icon: '/prospecting/TAAF.svg',
      },
      {
        label: 'Wallis et Futuna',
        icon: '/prospecting/Wallis-et-Futuna.svg',
      },
    ],
    selectedTerritory: {
      label: 'France métropolitaine',
      icon: '/prospecting/France-metropolitaine.svg',
    },
    domCurrentScrollingItems: {},
    scrollListener: true,
    scrollDuration: 600,
    traitsList: [
      { label: 'Groupe', key: 'trait_specie_group' },
      { label: 'Longueur', key: 'trait_length' },
      { label: 'Envergure', key: 'trait_scope' },
      { label: 'Poids', key: 'trait_weight' },
      { label: "Durée d'incubation", key: 'trait_incubation_time' },
      { label: 'Nombre de pontes', key: 'trait_clutches_number' },
      { label: "Nombre d'œufs", key: 'trait_eggs_number' },
      {
        label: "Durée de séjour au nid jusqu'à l'envol",
        key: 'trait_nest_length_stay',
      },
      { label: 'Âge maximal Euring', key: 'trait_max_age_euring' },
      { label: 'Âge maximal FR', key: 'trait_max_age_fr' },
      { label: 'Habitat', key: 'trait_habitat' },
      { label: 'Nourriture', key: 'trait_food' },
      { label: 'Site de nidification', key: 'trait_nesting_site' },
      { label: 'Comportement migrateur', key: 'trait_migratory_behaviour' },
    ],
    furtherInfoList: [
      { label: 'Répartition et déplacements', key: 'distribution' },
      { label: 'Habitats', key: 'habitat' },
      { label: 'Alimentation', key: 'feeding' },
      { label: 'Reproduction', key: 'breeding' },
    ],
    dataPhenologyAllPeriod: {
      phenology: {
        label: 'Nombre de données',
        data: [
          { label: 'D1', count_data: 0 },
          { label: 'D2', count_data: 0 },
          { label: 'D3', count_data: 0 },
          { label: 'D4', count_data: 0 },
          { label: 'D5', count_data: 0 },
          { label: 'D6', count_data: 0 },
          { label: 'D7', count_data: 0 },
          { label: 'D8', count_data: 10 },
          { label: 'D9', count_data: 20 },
          { label: 'D10', count_data: 30 },
          { label: 'D11', count_data: 40 },
          { label: 'D12', count_data: 50 },
          { label: 'D13', count_data: 60 },
          { label: 'D14', count_data: 70 },
          { label: 'D15', count_data: 90 },
          { label: 'D16', count_data: 120 },
          { label: 'D17', count_data: 250 },
          { label: 'D18', count_data: 370 },
          { label: 'D19', count_data: 550 },
          { label: 'D20', count_data: 360 },
          { label: 'D21', count_data: 290 },
          { label: 'D22', count_data: 270 },
          { label: 'D23', count_data: 200 },
          { label: 'D24', count_data: 150 },
          { label: 'D25', count_data: 90 },
          { label: 'D26', count_data: 55 },
          { label: 'D27', count_data: 40 },
          { label: 'D28', count_data: 15 },
          { label: 'D29', count_data: 0 },
          { label: 'D30', count_data: 0 },
          { label: 'D31', count_data: 0 },
          { label: 'D32', count_data: 0 },
          { label: 'D33', count_data: 0 },
          { label: 'D34', count_data: 0 },
          { label: 'D35', count_data: 0 },
          { label: 'D36', count_data: 0 },
        ],
        color: '#435EF2',
      },
      frequency: {
        label: 'Fréquence dans les listes complètes',
        data: [
          { label: 'D1', percentage: 0 },
          { label: 'D2', percentage: 0 },
          { label: 'D3', percentage: 2 },
          { label: 'D4', percentage: 4.5 },
          { label: 'D5', percentage: 5 },
          { label: 'D6', percentage: 6 },
          { label: 'D7', percentage: 8 },
          { label: 'D8', percentage: 11 },
          { label: 'D9', percentage: 12 },
          { label: 'D10', percentage: 14 },
          { label: 'D11', percentage: 14.5 },
          { label: 'D12', percentage: 16 },
          { label: 'D13', percentage: 19 },
          { label: 'D14', percentage: 24 },
          { label: 'D15', percentage: 24.5 },
          { label: 'D16', percentage: 26 },
          { label: 'D17', percentage: 28 },
          { label: 'D18', percentage: 29 },
          { label: 'D19', percentage: 26 },
          { label: 'D20', percentage: 24.5 },
          { label: 'D21', percentage: 22 },
          { label: 'D22', percentage: 21 },
          { label: 'D23', percentage: 19 },
          { label: 'D24', percentage: 17 },
          { label: 'D25', percentage: 16 },
          { label: 'D26', percentage: 14.5 },
          { label: 'D27', percentage: 9.5 },
          { label: 'D28', percentage: 7 },
          { label: 'D29', percentage: 5 },
          { label: 'D30', percentage: 4.5 },
          { label: 'D31', percentage: 4.5 },
          { label: 'D32', percentage: 3.5 },
          { label: 'D33', percentage: 2 },
          { label: 'D34', percentage: 0 },
          { label: 'D35', percentage: 0 },
          { label: 'D36', percentage: 0 },
        ],
        color: '#8CCB6E',
      },
    },
    dataPhenologyMigration: {
      phenology: {
        label: 'Nombre de données en migration active',
        data: [
          { label: 'D1', count_data: 0 },
          { label: 'D2', count_data: 0 },
          { label: 'D3', count_data: 0 },
          { label: 'D4', count_data: 0 },
          { label: 'D5', count_data: 0 },
          { label: 'D6', count_data: 0 },
          { label: 'D7', count_data: 5 },
          { label: 'D8', count_data: 10 },
          { label: 'D9', count_data: 15 },
          { label: 'D10', count_data: 80 },
          { label: 'D11', count_data: 110 },
          { label: 'D12', count_data: 380 },
          { label: 'D13', count_data: 560 },
          { label: 'D14', count_data: 385 },
          { label: 'D15', count_data: 270 },
          { label: 'D16', count_data: 150 },
          { label: 'D17', count_data: 55 },
          { label: 'D18', count_data: 20 },
          { label: 'D19', count_data: 0 },
          { label: 'D20', count_data: 0 },
          { label: 'D21', count_data: 0 },
          { label: 'D22', count_data: 0 },
          { label: 'D23', count_data: 0 },
          { label: 'D24', count_data: 5 },
          { label: 'D25', count_data: 80 },
          { label: 'D26', count_data: 285 },
          { label: 'D27', count_data: 410 },
          { label: 'D28', count_data: 505 },
          { label: 'D29', count_data: 560 },
          { label: 'D30', count_data: 360 },
          { label: 'D31', count_data: 250 },
          { label: 'D32', count_data: 205 },
          { label: 'D33', count_data: 40 },
          { label: 'D34', count_data: 0 },
          { label: 'D35', count_data: 0 },
          { label: 'D36', count_data: 0 },
        ],
        color: '#435EF2',
      },
      prenuptial: {
        label: 'Migration prénuptiale',
        data: ['D9', 'D12', 'D15'],
        colors: { quantile: 'rgba(57, 118, 90, 0.1)', median: '#39765A' },
      },
      postnuptial: {
        label: 'Migration postnuptiale',
        data: ['D26', 'D29', 'D32'],
        colors: { quantile: 'rgba(235, 106, 10, 0.1)', median: '#EB6A0A' },
      },
    },
    dataPhenologyBreeding: {
      label: 'Nombre de données',
      atlasCodes: ['Mâle chanteur', 'Jeunes'],
      data: [
        { label: 'D1', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D2', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D3', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D4', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D5', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D6', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D7', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D8', firstAtlasCode: 10, secondAtlasCode: 0 },
        { label: 'D9', firstAtlasCode: 20, secondAtlasCode: 0 },
        { label: 'D10', firstAtlasCode: 30, secondAtlasCode: 0 },
        { label: 'D11', firstAtlasCode: 40, secondAtlasCode: 0 },
        { label: 'D12', firstAtlasCode: 50, secondAtlasCode: 0 },
        { label: 'D13', firstAtlasCode: 60, secondAtlasCode: 0 },
        { label: 'D14', firstAtlasCode: 70, secondAtlasCode: 0 },
        { label: 'D15', firstAtlasCode: 90, secondAtlasCode: 0 },
        { label: 'D16', firstAtlasCode: 120, secondAtlasCode: 10 },
        { label: 'D17', firstAtlasCode: 250, secondAtlasCode: 20 },
        { label: 'D18', firstAtlasCode: 370, secondAtlasCode: 40 },
        { label: 'D19', firstAtlasCode: 550, secondAtlasCode: 50 },
        { label: 'D20', firstAtlasCode: 360, secondAtlasCode: 70 },
        { label: 'D21', firstAtlasCode: 290, secondAtlasCode: 90 },
        { label: 'D22', firstAtlasCode: 270, secondAtlasCode: 95 },
        { label: 'D23', firstAtlasCode: 200, secondAtlasCode: 140 },
        { label: 'D24', firstAtlasCode: 150, secondAtlasCode: 170 },
        { label: 'D25', firstAtlasCode: 90, secondAtlasCode: 150 },
        { label: 'D26', firstAtlasCode: 55, secondAtlasCode: 130 },
        { label: 'D27', firstAtlasCode: 40, secondAtlasCode: 100 },
        { label: 'D28', firstAtlasCode: 15, secondAtlasCode: 90 },
        { label: 'D29', firstAtlasCode: 0, secondAtlasCode: 80 },
        { label: 'D30', firstAtlasCode: 0, secondAtlasCode: 70 },
        { label: 'D31', firstAtlasCode: 0, secondAtlasCode: 50 },
        { label: 'D32', firstAtlasCode: 0, secondAtlasCode: 20 },
        { label: 'D33', firstAtlasCode: 0, secondAtlasCode: 10 },
        { label: 'D34', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D35', firstAtlasCode: 0, secondAtlasCode: 0 },
        { label: 'D36', firstAtlasCode: 0, secondAtlasCode: 0 },
      ],
      colors: ['#435EF2', '#E56B6F'],
    },
    dataAltitude: {
      altitude: {
        label: 'Répartition des observations',
        data: [
          { label: 0, percentage: 0 },
          { label: 100, percentage: 0 },
          { label: 200, percentage: 0 },
          { label: 300, percentage: 0 },
          { label: 400, percentage: 0 },
          { label: 500, percentage: 0 },
          { label: 600, percentage: 0 },
          { label: 700, percentage: 0 },
          { label: 800, percentage: 0 },
          { label: 900, percentage: 0 },
          { label: 1000, percentage: 0 },
          { label: 1100, percentage: 0 },
          { label: 1200, percentage: 4 },
          { label: 1300, percentage: 14 },
          { label: 1400, percentage: 26 },
          { label: 1500, percentage: 35 },
          { label: 1600, percentage: 42 },
          { label: 1700, percentage: 49 },
          { label: 1800, percentage: 55 },
          { label: 1900, percentage: 58 },
          { label: 2000, percentage: 61 },
          { label: 2100, percentage: 63 },
          { label: 2200, percentage: 62.5 },
          { label: 2300, percentage: 60.5 },
          { label: 2400, percentage: 57 },
          { label: 2500, percentage: 51 },
          { label: 2600, percentage: 50 },
          { label: 2700, percentage: 39 },
          { label: 2800, percentage: 32 },
          { label: 2900, percentage: 22 },
          { label: 3000, percentage: 12 },
          { label: 3100, percentage: 3 },
          { label: 3200, percentage: 0 },
          { label: 3300, percentage: 0 },
          { label: 3400, percentage: 0 },
          { label: 3500, percentage: 0 },
        ],
        color: '#435EF2',
      },
      globalAltitude: {
        label: "Répartition de l'altitude du territoire",
        data: [
          { label: 0, percentage: 60 },
          { label: 100, percentage: 30 },
          { label: 500, percentage: 45 },
          { label: 600, percentage: 15 },
          { label: 1700, percentage: 5 },
          { label: 3500, percentage: 0 },
        ],
        color: 'rgba(67, 94, 242, 0.1)',
      },
    },
    dataTrend: {
      trend: {
        label: "Indice d'abondance",
        data: [
          { label: 2006, index: 1.02 },
          { label: 2007, index: 1.09 },
          { label: 2008, index: 1.15 },
          { label: 2009, index: 1.11 },
          { label: 2010, index: 1.01 },
          { label: 2011, index: 0.89 },
          { label: 2012, index: 0.84 },
          { label: 2013, index: 0.81 },
          { label: 2014, index: 0.86 },
          { label: 2015, index: 0.91 },
          { label: 2016, index: 0.97 },
          { label: 2017, index: 1.01 },
          { label: 2018, index: 1.03 },
          { label: 2019, index: 1.08 },
          { label: 2020, index: 1.05 },
          { label: 2021, index: 1.0 },
        ],
        color: '#435EF2',
      },
      uncertainties: {
        data: [
          { label: 2006, min: 0.9, max: 1.1 },
          { label: 2007, min: 0.92, max: 1.21 },
          { label: 2008, min: 0.99, max: 1.29 },
          { label: 2009, min: 0.95, max: 1.25 },
          { label: 2010, min: 0.85, max: 1.15 },
          { label: 2011, min: 0.8, max: 1.02 },
          { label: 2012, min: 0.77, max: 0.99 },
          { label: 2013, min: 0.72, max: 0.95 },
          { label: 2014, min: 0.75, max: 1.0 },
          { label: 2015, min: 0.76, max: 1.06 },
          { label: 2016, min: 0.8, max: 1.1 },
          { label: 2017, min: 0.86, max: 1.15 },
          { label: 2018, min: 0.88, max: 1.18 },
          { label: 2019, min: 0.91, max: 1.21 },
          { label: 2020, min: 0.89, max: 1.18 },
          { label: 2021, min: 0.85, max: 1.15 },
        ],
        color: 'rgba(67, 94, 242, 0.1)',
      },
    },
    dataPopulationsBreeding: {
      label: "Nombre d'individus",
      keys: ['Intervalle de confiance (90%)', 'Effectif médian'],
      data: [
        { label: '2001 - 2005', min: 95, median: 205, max: 315 },
        { label: '2005 - 2007', min: 210, median: 320, max: 430 },
        { label: '2007 - 2011', min: 300, median: 410, max: 520 },
        { label: '2011 - 2015', min: 280, median: 390, max: 500 },
        { label: '2015 - 2019', min: 170, median: 280, max: 390 },
        { label: '2019 - 2023', min: 230, median: 340, max: 450 },
      ],
      colors: ['rgba(67, 94, 242, 0.1)', '#435EF2'],
    },
    dataPopulationsWintering: {
      label: "Nombre d'individus",
      keys: ["Fourchette d'effectifs (minimum et maximum)"],
      data: [
        { label: '2001 - 2005', min: 95, max: 315 },
        { label: '2005 - 2007', min: 210, max: 430 },
        { label: '2007 - 2011', min: 300, max: 520 },
        { label: '2011 - 2015', min: 280, max: 500 },
        { label: '2015 - 2019', min: 170, max: 390 },
        { label: '2019 - 2023', min: 230, max: 450 },
      ],
      colors: ['rgba(57, 118, 90, 0.2)'],
    },
    dataPopulationsTest: {
      label: "Nombre d'individus",
      data: [
        { label: 1976, count_data: 15 },
        { label: 1977, count_data: 30 },
        { label: 1978, count_data: 60 },
        { label: 1979, count_data: 100 },
        { label: 1980, count_data: 120 },
        { label: 1981, count_data: 185 },
        { label: 1982, count_data: 205 },
        { label: 1983, count_data: 210 },
        { label: 1984, count_data: 240 },
        { label: 1985, count_data: 250 },
        { label: 1986, count_data: 270 },
        { label: 1987, count_data: 250 },
        { label: 1988, count_data: 240 },
        { label: 1989, count_data: 230 },
        { label: 1990, count_data: 240 },
        { label: 1991, count_data: 250 },
        { label: 1992, count_data: 290 },
        { label: 1993, count_data: 300 },
        { label: 1994, count_data: 303 },
        { label: 1995, count_data: 310 },
        { label: 1996, count_data: 315 },
        { label: 1997, count_data: 318 },
        { label: 1998, count_data: 326 },
        { label: 1999, count_data: 340 },
        { label: 2000, count_data: 355 },
        { label: 2001, count_data: 390 },
        { label: 2002, count_data: 425 },
        { label: 2003, count_data: 460 },
        { label: 2004, count_data: 430 },
        { label: 2005, count_data: 390 },
        { label: 2006, count_data: 350 },
        { label: 2007, count_data: 315 },
        { label: 2008, count_data: 290 },
        { label: 2009, count_data: 210 },
        { label: 2010, count_data: 155 },
        { label: 2011, count_data: 97 },
        { label: 2012, count_data: 120 },
        { label: 2013, count_data: 135 },
        { label: 2014, count_data: 155 },
        { label: 2015, count_data: 200 },
        { label: 2016, count_data: 180 },
        { label: 2017, count_data: 150 },
        { label: 2018, count_data: 115 },
        { label: 2019, count_data: 100 },
        { label: 2020, count_data: 70 },
        { label: 2021, count_data: 45 },
      ],
      color: '#435EF2',
    },
  }),
  head() {
    return {
      title: this.species.attributes.odf_common_name_fr,
    }
  },
  computed: {
    cdnom() {
      return this.$route.params.cdnom
    },
    // Permet de mettre à jour selectedTab seulement après le $router.push
    selectedTabModel: {
      get() {
        return this.selectedTab
      },
      set(value) {
        this.$router.push(`${value.hash}`)
      },
    },
    filteredTabs() {
      if (this.species.attributes.odf_common_name_fr) {
        const tabs = [...this.tabs]
        // SpeciesTab
        const speciesTabSubjects = ['links']
        if (this.species.attributes.description || this.species.medias.Photos) {
          speciesTabSubjects.push('description')
        }
        if (this.species.redLists || this.species.protectionStatus) {
          speciesTabSubjects.push('status')
        }
        if (this.filteredTraits || this.filteredFurtherInfo) {
          speciesTabSubjects.push('traits')
        }
        tabs[0].subjects = tabs[0].subjects.filter((subject) => {
          return speciesTabSubjects.includes(subject.slug)
        })
        return tabs
      } else {
        return this.tabs
      }
    },
    subjectsList() {
      return (
        this.selectedTab.subjects[this.selectedSeason.value] ??
        this.selectedTab.subjects
      )
    },
    filteredTraits() {
      if (this.species.attributes.odf_common_name_fr) {
        // Si les données sont arrivées
        const filteredTraits = this.traitsList.filter((trait) => {
          return this.species.attributes[trait.key]
        })
        return filteredTraits.length > 0 ? filteredTraits : null
      } else {
        return null
      }
    },
    filteredFurtherInfo() {
      if (this.species.attributes.odf_common_name_fr) {
        // Si les données sont arrivées
        const filteredFurtherInfo = this.furtherInfoList.filter((info) => {
          return this.species.attributes[info.key]
        })
        return filteredFurtherInfo.length > 0 ? filteredFurtherInfo : null
      } else {
        return null
      }
    },
  },
  watch: {
    $route(newVal) {
      /* On utilise un watch pour prendre en compte les retours à l'onglet précédent */
      this.defineSelectedTab()
    },
    selectedSeason(newVal) {
      this.defineSelectedSubject()
      this.defineDomCurrentScrollingItems()
    },
    filteredTabs(newVal) {
      // console.log('filteredTabs')
      // console.log(newVal)
      this.defineSelectedSubject()
    },
  },
  beforeMount() {
    if (this.$detectMobile()) {
      // First we get the viewport height and we multiple it by 1% to get a value for a vh unit
      const vh = window.innerHeight * 0.01
      // Then we set the value in the --vh custom property to the root of the document
      document.documentElement.style.setProperty('--vh', `${vh}px`)
      window.addEventListener('resize', this.listenerResize)
    }
  },
  mounted() {
    document.documentElement.style.overflow = 'hidden'
    document.body.style.position = 'fixed' // Needed for iOS
    this.$refs.scrollingContainer.addEventListener(
      'scroll',
      this.listenerScroll
    )
    this.defineSelectedTab()
    this.$axios
      .$get(
        `https://geonature.alx.host/taxhub/api/bibnoms/taxoninfo/${this.cdnom}`
      )
      .then((data) => {
        if (data) {
          const species = {
            cdnom: this.cdnom,
            attributes: {},
            medias: { Photos: [] },
          }
          data.attributs.forEach((attribut) => {
            species.attributes[attribut.nom_attribut] = attribut.valeur_attribut
          })
          data.medias.forEach((media) => {
            if (media.nom_type_media === 'Photo') {
              species.medias.Photos.push({
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media,
              })
            } else if (media.nom_type_media === 'Photo_principale') {
              species.medias.Photos.splice(0, 0, {
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media,
              })
              species.medias[media.nom_type_media] = {
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media,
              }
            } else {
              species.medias[media.nom_type_media] = {
                title: media.titre,
                url: media.url,
                author: media.auteur,
                description: media.desc_media,
              }
            }
          })
          if (!species.medias.Photos.length) {
            delete species.medias.Photos
          }
          this.$axios
            .$get(
              `https://demo.geonature.fr/taxhub/api/bdc_statuts/list/${this.cdnom}`
            )
            .then((data) => {
              if (data) {
                // UPDATE NEEDED : récupérer les noms des territoires pour les LR (et pas seulement leur cd_sig)
                const redListWorld = data.filter((item) => {
                  return item.cd_type_statut === 'LRM'
                })
                const redListsNational = data.filter((item) => {
                  return item.cd_type_statut === 'LRN'
                })
                if (redListWorld.length || redListsNational.length) {
                  species.redLists = { national: [] }
                  if (redListWorld.length) {
                    species.redLists.world = redListWorld[0].code_statut
                  }
                  if (redListsNational.length) {
                    redListsNational.forEach((item) => {
                      species.redLists.national.push({
                        territory: item.cd_sig,
                        statut: item.code_statut,
                      })
                    })
                  }
                }
                // END UPDATE NEEDED
                // UPDATE NEEDED : récupérer les statuts de protection
                species.protectionStatus = {}
                species.protectionStatus.national = 'Chassable'
                species.protectionStatus.birdDirective = 'Protégée'
                // END UPDATE NEEDED
                this.species = species
                // console.log(species)
              }
            })
            .catch((error) => {
              console.log(error)
            })
        }
      })
      .catch((error) => {
        console.log(error)
      })
      .finally(() => {
        setTimeout(() => {
          // Le timeout permet d'être assuré que les contenus sont bien integrés à la page
          this.defineDomCurrentScrollingItems() // Certaines sections ne sont affichées qu'une fois les données récupérées
        }, 500)
      })
  },
  beforeDestroy() {
    document.documentElement.style.removeProperty('overflow')
    document.body.style.removeProperty('position')
    window.removeEventListener('resize', this.listenerResize)
    this.$refs.scrollingContainer.removeEventListener(
      'scroll',
      this.listenerScroll
    )
  },
  methods: {
    defineSelectedTab() {
      this.selectedTab = this.filteredTabs.filter((item) => {
        return item.hash === this.$route.hash
      })[0]
      this.defineSelectedSubject()
      this.defineDomCurrentScrollingItems()
    },
    defineSelectedSubject() {
      this.selectedSubject = this.subjectsList[0]
    },
    defineDomCurrentScrollingItems() {
      this.domCurrentScrollingItems = this.subjectsList.map((item) => {
        return document.getElementById(item.slug)
      })
    },
    updateSelectedTab(item) {
      this.$router.push(`${item.hash}`)
    },
    updateSelectedSubject(item) {
      if (document.getElementById(item.slug) && this.selectedSubject !== item) {
        this.scrollListener = false
        this.selectedSubject = item
        this.$animateScrollTo(
          this.$refs.scrollingContainer,
          document.getElementById(item.slug).offsetTop,
          this.scrollDuration
        )
        setTimeout(() => {
          this.scrollListener = true
        }, this.scrollDuration + 10)
      }
    },
    listenerScroll() {
      this.$debounce(this.handleScroll())
    },
    handleScroll() {
      if (this.scrollListener) {
        // console.log(this.domCurrentScrollingItems)
        const currentScroll = this.$refs.scrollingContainer.scrollTop
        const domCurrentScrolledItem = this.domCurrentScrollingItems.filter(
          (item) => {
            return (
              item.offsetTop - 40 <= currentScroll &&
              item.offsetTop + item.offsetHeight > currentScroll
            )
          }
        )
        if (domCurrentScrolledItem.length > 0) {
          const currentScrolledSubject = this.subjectsList.filter((subject) => {
            return subject.slug === domCurrentScrolledItem[0].id
          })[0]
          if (currentScrolledSubject) {
            this.selectedSubject = currentScrolledSubject
          }
        }
      }
    },
    listenerResize() {
      this.$debounce(this.detectResize())
    },
    detectResize() {
      const vh = window.innerHeight * 0.01
      document.documentElement.style.setProperty('--vh', `${vh}px`)
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  height: 100vh;
  height: calc(var(--vh, 1vh) * 100);
  max-height: 100vh;
  max-height: calc(var(--vh, 1vh) * 100);
  padding-top: 68px;
  display: flex;
  flex-direction: column;
}

header {
  background: #fcfcfc;
  padding: 16px 40px;
  border-bottom: 1px solid rgba(57, 118, 90, 0.1);
  display: flex;
  align-items: center;
  column-gap: 24px;
  row-gap: 16px;
  flex-wrap: wrap;
}

.Heading {
  display: flex;
  align-items: center;
}

.SpeciesPicture {
  min-width: 50px;
  max-width: 50px;
  min-height: 50px;
  max-height: 50px;
  border-radius: 50%;
  margin-right: 36px;
}

.Title {
  display: flex;
  flex-direction: column;
}

.Metadata {
  flex: 1 1 390px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.Metadata .DropdownListWrapper {
  display: none;
}

.SpeciesCardSection {
  flex: 1;
  position: relative;
  display: flex;
}

nav.NavDrawer {
  background: #f8f8f8;
  width: 300px;
  padding: 24px 40px;
  display: flex;
  flex-direction: column;
}

.SpeciesCardTab {
  position: absolute;
  top: 0;
  left: 300px;
  right: 0;
  bottom: 0;
  padding: 24px 40px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.SpeciesCardTabRelative {
  position: relative;
}

.Selectors {
  display: flex;
  justify-content: flex-end;
}

.Selectors .DropdownListWrapper {
  width: fit-content;
  max-width: 300px;
  margin-right: 8px;
}

.Selectors .DropdownListWrapper:last-child {
  margin-right: 0;
}

.SpeciesCardContent {
  width: 100%;
  display: flex;
  flex-direction: column;
}

.SpeciesCardContent.hidden {
  position: absolute !important;
  top: -9999px !important;
  left: -9999px !important;
}

.SpeciesCardTabRelative >>> .ChartCard {
  width: 100%;
  max-width: 1050px;
  padding: 24px 32px;
  margin-bottom: 40px;
  border: 1px solid rgba(51, 105, 80, 0.2);
  box-sizing: border-box;
  border-radius: 16px;
  align-self: center;
  scroll-margin: 12px;
  display: flex;
  flex-direction: column;
}

.SpeciesCardTabRelative >>> .ChartCard:last-child {
  margin-bottom: 0;
}

.SpeciesCardTabRelative >>> .Chart {
  height: 300px;
  overflow-y: hidden;
  overflow-x: auto;
  touch-action: auto;
  -webkit-overflow-scrolling: touch; /* iOS */
}

.SpeciesCardTabRelative >>> .ChartLegend {
  margin-top: 40px;
  display: flex;
  justify-content: center;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel {
  margin-right: 20px;
  display: flex;
  align-items: center;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel:last-child {
  margin-right: 0;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel i {
  width: 16px;
  min-width: 16px;
  height: 16px;
  min-height: 16px;
  float: left;
  margin-right: 12px;
}

.SpeciesCardTabRelative >>> .ChartLegendLabel i.round {
  border-radius: 50%;
}

/********** RESPONSIVE **********/

@media screen and (max-width: 1050px) {
  nav.NavDrawer {
    display: none;
  }

  .SpeciesCardTab {
    left: 0;
  }
}

@media screen and (max-width: 800px) {
  header {
    padding: 16px 5%;
  }

  .SpeciesCardTab {
    padding: 24px 5%;
  }
}

@media screen and (max-width: 680px) {
  .SpeciesCardContent >>> h4.fw-bold {
    font-size: 16px;
    line-height: 24px;
  }

  .ChartCard {
    padding: 24px;
  }
}

@media screen and (max-width: 500px) {
  .Selectors {
    flex-direction: column;
  }

  .Selectors .DropdownListWrapper {
    width: 100%;
    max-width: none;
    margin-right: 0;
  }

  .Selectors .DropdownListWrapper:first-child {
    margin-bottom: 8px;
  }
}

@media screen and (max-width: 430px) {
  .not-on-mobile {
    display: none;
  }

  div.container.container--fluid header .TabMenu {
    display: none;
  }

  div.container.container--fluid header .DropdownListWrapper {
    display: block;
    margin-bottom: 0;
  }
}
</style>
