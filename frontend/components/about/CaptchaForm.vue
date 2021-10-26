<template>
  <div class="CaptchaContent">
    <span class="black02 fw-500 bottom-margin-8">Test de sécurité</span>
    <div class="CaptchaInputWrapper">
      <span class="CaptchaInstruction"
        >Veuillez recopier le code <b>{{ captchaRef }}</b> ci-après :</span
      >
      <input
        v-model="captchaUser"
        class="ContactFormInput CaptchaInput no-bottom-margin"
        type="text"
      />
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

.CaptchaInputWrapper {
  margin-bottom: 24px;
  display: flex;
  align-items: center;
}

.CaptchaInstruction {
  margin-right: 10px;
}

.CaptchaInput {
  width: 62px;
}
</style>
