<template>
  <section class="Section">
    <img class="ConfirmationPicture" src="/confirmation-of-receipt.svg" />
    <h3 class="fw-600 text-center bottom-margin-16">
      Nous avons bien reçu votre demande
    </h3>
    <span class="text-center bottom-margin-32">
      Nous mettons tout en œuvre pour vous répondre au plus vite !
    </span>
    <nuxt-link to="/" class="PrimaryButton">
      Retour à la page d'accueil
    </nuxt-link>
  </section>
</template>

<style scoped>
.Section {
  align-items: center;
}

.ConfirmationPicture {
  width: 280px;
  max-width: 100%;
  margin-bottom: 56px;
}
</style>
