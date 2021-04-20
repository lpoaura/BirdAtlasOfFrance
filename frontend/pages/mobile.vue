<template>
  <v-container fluid>
    <main>
      <img class="Logo" src="/ODF-logo-filled.svg" />
      <h1 class="Message">
        L'Atlas des Oiseaux de France n'est
        <b>pas encore disponible sur cette taille d'écran</b>, veuillez nous en
        excuser.
      </h1>
    </main>
  </v-container>
</template>

<style scoped>
main {
  padding: 16px 2%;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.Logo {
  height: 100px;
  margin-bottom: 16px;
}

.Message {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #262626;
  text-align: center;
}
</style>
