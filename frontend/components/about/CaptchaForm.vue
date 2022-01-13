<template>
  <div class="CaptchaContent">
    <span class="black02 fw-500 bottom-margin-8">Test de sécurité</span>
    <div class="CaptchaInputWrapper bottom-margin-24">
      <span>
        Veuillez recopier le code <b>{{ captchaRef }}</b> ci-après :&nbsp;
        <input
          v-model="captchaUser"
          class="ContactFormInput CaptchaInput no-bottom-margin"
          type="text"
        />
      </span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    captchaRef: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    captchaUser: '',
  }),
  watch: {
    captchaUser(newVal) {
      this.$emit('captchaUser', newVal)
    },
  },
}
</script>

<style scoped>
.CaptchaContent {
  display: flex;
  flex-direction: column;
}

.CaptchaInput {
  width: 62px;
}
</style>
