<!-- Créer un array pour les MenuItems -->
<template>
  <header>
    <div class="ODFLogo">
      <img src="/ODF-logo-white.svg" />
    </div>
    <menu>
      <div class="HomeMenuItem">Accueil</div>
      <div class="MenuItem">Espèces</div>
      <div class="MenuItem">Carte</div>
      <div class="MenuItem">Protocoles</div>
      <div class="MenuItem">À propos</div>
    </menu>
    <div class="NavPicto">
      <img class="Picto" src="/language-white.svg" />
      <img class="Picto" src="/support-white.svg" />
    </div>
  </header>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css?family=Poppins:300,400,700,900&display=swap');

header {
  /* background: #efefef; */
  position: absolute;
  z-index: 10;
  width: 100%;
  height: 80px;
  padding-left: 5%;
  padding-right: 5%;
  display: flex;
  align-items: center;
  justify-content: space-around;
}

.ODFLogo {
  flex: 1;
  height: 40px;
  display: flex;
}

menu {
  /* background: blue; */
  flex: 2;
  height: 53px;
  align-self: flex-end;
  display: flex;
  justify-content: space-between;
}

.MenuItem {
  /* background: green; */
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 300;
  font-size: 14px;
  line-height: 21px;
  color: #fcfcfc;
}

.HomeMenuItem {
  /* background: green; */
  height: 40px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 14px;
  line-height: 21px;
  color: #fcfcfc;
  border-bottom: 3px solid #fcfcfc;
}

.NavPicto {
  flex: 1;
  height: 24px;
  display: flex;
  justify-content: flex-end;
}

.Picto {
  margin-left: 8%;
}
</style>
