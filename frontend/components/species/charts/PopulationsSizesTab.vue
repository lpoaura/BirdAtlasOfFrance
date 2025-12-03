<template>
    <div v-if="idArea && groupedData && Object.keys(groupedData).length" class="ChartCard" id="population-size">
        <div v-for="(rows, unit) in groupedData" :key="unit" class="Tableau" >
            <h4 class="black02 fw-bold bottom-margin-8"> 
                Effectif nicheur national
            </h4>
            <h5 class="black03 bottom-margin-15">
              Taille de population, selon les données les plus récentes disponibles.<br />
              <template v-if="singleLocalisation(rows)"> Localisation : {{ rows[0].localisation }}</template>
            </h5>
            <table class="table">
                <thead>
                    <tr class="en-tete">
                        <th>Année(s)</th>
                        <th>{{ unit }}</th>
                        <th>Source</th>
                        <th v-if="!isEmptyOrIdenticalLocalisation(rows)">Localisation</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="row in rows" :key="row.id_tab" class="corps">
                        <td>{{ row.annees }}</td>
                        <td>{{ row.valeur }}</td>
                        <td>{{ row.source }}</td>
                        <td v-if="!isEmptyOrIdenticalLocalisation(rows)">{{ row.localisation }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>
  
<script>
export default {
  data: () => ({
    apiData: null,
  }),

  computed: {
    idArea() {
      return this.$store.state.species.selectedTerritory.id_area;
    },

    cdNom() {
      return this.$store.state.species.cdNom;
    },

    phenologyPeriod() {
      return this.$store.state.species.selectedSeason?.value;
    },

    groupedData() {
      if (!this.apiData?.data) return {};

      const result = {};
      this.apiData.data.forEach((entry) => {
        const unit = entry.unite || "Autre";
        if (!result[unit]) result[unit] = [];
        result[unit].push(entry);
      });

      return result;
    },
  },

  methods: {
    // Méthode pour vérifier si la localisation est vide ou non
    // Vérifie si la localisation est vide ou identique partout
    isEmptyOrIdenticalLocalisation(rows) {
      if (!rows || rows.length === 0) return true;
      
      // Vérifie si toutes les valeurs de 'localisation' sont vides
      const allEmpty = rows.every((row) => !row.localisation || row.localisation.trim() === '');
      if (allEmpty) return true;

      // Vérifie si toutes les localisations sont identiques
      const firstLocalisation = rows[0].localisation;
      const allIdentical = rows.every((row) => row.localisation === firstLocalisation);
      return allIdentical;
    },

    singleLocalisation(rows) {
      if (!rows.length) return false;

      const first = rows[0].localisation;
      return rows.every(
        (r) => r.localisation === first && r.localisation
      );
    },

    async fetchData() {
      const response = await fetch(
        `/api/v1/taxa/tab/survey?cd_nom=${this.cdNom}&id_area=${this.idArea}&phenology_period=${this.phenologyPeriod}`
      );
      this.apiData = await response.json();
    },
  },

  mounted() {
    this.fetchData().then(() => {
    // Ajoute le sujet dans la navbar
    const hasData = this.apiData?.data?.length > 0;
    this.$store.commit('species/pushSubjectsList', {
      label: "Taille de population", // Le nom qui s'affiche dans la navbar
      slug: 'population-size',       // Doit correspondre au routeur ou usage interne
      position: 5,                   // À adapter selon l'ordre souhaité
      status: hasData                // Active si les données sont présentes
    });
  });
  },
};
</script>

<style>
/* Tableau style */
.table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
  font-family: 'Arial', sans-serif;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.table th,
.table td {
  padding: 10px;
  text-align: left;
  border: 1px solid #f1f1f1;
  transition: background-color 0.3s ease;
}

.table th {
  background-color: #f8f8f8;
  color: #333;
  font-weight: bold;
}

.table td {
  background-color: #fff;
  color: #555;
}

.table-striped tbody tr:nth-child(odd) {
  background-color: #f9f9f9;
}

.table-hover tbody tr:hover {
  background-color: #f1f1f1;
}

.Tableau .bottom-margin-32 {
  margin-bottom: 20px;
}

.fw-bold {
  font-weight: bold;
}

.en-tete {
    text-anchor: middle;
    font-family: 'Poppins', sans-serif;
    font-style: normal;
    font-weight: 500;
    font-size: 13px;
    line-height: 13px;
    color: #000;
}

.corps{
    font-family: 'Poppins', sans-serif;
    font-style: normal;
    font-weight: 400;
    font-size: 12px;
    line-height: 13px;
    color: #000;
}
</style>