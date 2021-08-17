<template>
  <section class="ConfirmationSection">
    <div class="ConfirmationContent">
      <img class="ConfirmationPicture" src="/confirmation-of-receipt.svg" />
      <h3 class="ConfirmationTitle fw-600">
        Nous avons bien reçu votre demande
      </h3>
      <span class="ConfirmationSubtitle">
        Nous mettons tout en œuvre pour vous répondre au plus vite !
      </span>
      <nuxt-link to="/" class="PrimaryButton">
        Retour à la page d'accueil
      </nuxt-link>
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
  margin-bottom: 56px;
}

.ConfirmationTitle {
  margin-bottom: 16px;
}

.ConfirmationSubtitle {
  margin-bottom: 32px;
}
</style>
