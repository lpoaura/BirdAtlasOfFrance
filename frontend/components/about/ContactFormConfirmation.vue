<template>
  <section class="ConfirmationSection">
    <div class="ConfirmationContent">
      <img class="ConfirmationPicture" src="/confirmation-of-receipt.svg" />
      <h1 class="ConfirmationTitle">Nous avons bien reçu votre demande</h1>
      <span class="ConfirmationSubtitle"
        >Nous mettons tout en œuvre pour vous répondre au plus vite !</span
      >
      <nuxt-link to="/" class="PrimaryButton"
        >Retour à la page d'accueil</nuxt-link
      >
    </div>
  </section>
</template>

<style scoped>
.ConfirmationContent {
  margin: auto;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.ConfirmationPicture {
  width: 280px;
  margin-bottom: 30px;
}

.ConfirmationTitle {
  margin-bottom: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 24px;
  line-height: 36px;
  color: #262626;
}

.ConfirmationSubtitle {
  margin-bottom: 30px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #262626;
}
</style>
