<template>
  <div class="CaptchaContent">
    <label for="captcha">Test de sécurité</label>
    <div class="CaptchaInputsWrapper">
      <span class="CaptchaInstruction"
        >Veuillez recopier le code <b>{{ captchaRef }}</b> ci-après :</span
      >
      <input
        id="captcha"
        v-model="captchaUser"
        class="CaptchaInput"
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

label {
  margin-bottom: 8px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

.CaptchaInputsWrapper {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.CaptchaInstruction {
  margin-right: 10px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

input {
  width: 626px;
  height: 32px;
  margin-bottom: 16px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  outline: none;
  padding-left: 2%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: rgba(38, 38, 38, 0.6);
}

input:focus {
  border: 1px solid #39765a;
}

.CaptchaInput {
  width: 62px;
  margin-right: 30px;
  margin-bottom: 0;
}
</style>
