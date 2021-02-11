<template>
  <header>
    <p style="align-self: center; margin: 0">Test</p>
    <menu>
      <menu-item> Accueil </menu-item>
      <menu-item>Atlas</menu-item>
      <menu-item>Prospection</menu-item>
      <menu-item>Protocoles</menu-item>
    </menu>
    <p style="align-self: center; margin: 0">Test</p>
  </header>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css?family=Poppins:400,700,900&display=swap');

header {
  background: #efefef;
  position: absolute;
  width: 100%;
  height: 80px;
  left: 0;
  top: 0;
  display: flex;
  justify-content: space-around;
}

menu {
  background: blue;
  width: 490px;
  height: 53px;
  align-self: end;
  display: flex;
  justify-content: space-between;
}

menu-item {
  background: green;
  position: static;
  height: 42px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 14px;
  line-height: 21px;
  color: #fcfcfc;
  border-bottom: 3px solid #fcfcfc;
}
</style>
