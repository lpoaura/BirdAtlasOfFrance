<template>
  <v-container fluid>
    <main class="TopSection breadcrumb">
      <breadcrumb />
      <header>
        <h3 v-show="!validForm" class="fw-600 text-center">
          Je souhaite avoir des renseignements sur le projet ODF
        </h3>
      </header>
    </main>
    <section v-show="!validForm" class="Section">
      <div class="ContactFormContent">
        <span class="black02 fw-500 bottom-margin-8">Nom</span>
        <input
          v-model="userName"
          type="text"
          placeholder="Henri Martin"
          class="ContactFormInput"
        />
        <span v-show="alerts.noUserName" class="ContactFormAlert">
          Veuillez renseigner votre nom
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span class="black02 fw-500 bottom-margin-8">Adresse email</span>
        <input
          v-model="userMail"
          type="email"
          placeholder="henri.martin@monmail.fr"
          class="ContactFormInput"
        />
        <span v-show="alerts.noUserMail" class="ContactFormAlert">
          Veuillez renseigner votre adresse email
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span v-show="alerts.wrongUserMail" class="ContactFormAlert">
          Veuillez renseigner une adresse email valide
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span class="black02 fw-500 bottom-margin-8">Département</span>
        <contact-form-dropdown-list
          :z-index="4"
          default-message="Département"
          :items-list="$departmentsList"
          @selectedItem="updateSelectedDepartment"
        />
        <span v-show="alerts.noSelectedDepartment" class="ContactFormAlert">
          Veuillez sélectionner un département
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span class="black02 fw-500 bottom-margin-8">Message</span>
        <textarea
          v-model="userMessage"
          placeholder="Bonjour..."
          class="ContactFormTextarea"
        />
        <span v-show="alerts.noUserMessage" class="ContactFormAlert">
          Veuillez écrire un message
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <captcha-form
          :captcha-ref="captchaRef"
          @captchaUser="updateCaptchaUser"
        />
        <span v-show="alerts.wrongCaptchaUser" class="ContactFormAlert">
          Le code de sécurité que vous avez renseigné n'est pas bon
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span v-show="alerts.sendingFail" class="ContactFormAlert">
          L'envoi du mail a échoué...
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <button
          :disabled="disabledButton"
          class="PrimaryButton"
          @click="validateForm"
        >
          Envoyer
        </button>
      </div>
    </section>
    <contact-form-confirmation v-show="validForm" />
  </v-container>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'
import ContactFormDropdownList from '~/components/about/ContactFormDropdownList.vue'
import CaptchaForm from '~/components/about/CaptchaForm.vue'
import ContactFormConfirmation from '~/components/about/ContactFormConfirmation.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
    'contact-form-dropdown-list': ContactFormDropdownList,
    'captcha-form': CaptchaForm,
    'contact-form-confirmation': ContactFormConfirmation,
  },
  data: () => ({
    userName: '',
    userMail: '',
    selectedDepartment: null,
    userMessage: '',
    captchaRef: '',
    captchaUser: '',
    alerts: {
      noUserName: false,
      noUserMail: false,
      wrongUserMail: false,
      noSelectedDepartment: false,
      noUserMessage: false,
      wrongCaptchaUser: false,
      sendingFail: false,
    },
    validForm: false,
    disabledButton: false,
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  mounted() {
    this.captchaRef = this.$generateCaptcha()
  },
  methods: {
    updateSelectedDepartment(department) {
      this.selectedDepartment = department[0]
      // console.log(this.selectedDepartment)
    },
    updateCaptchaUser(captcha) {
      this.captchaUser = captcha
    },
    validateForm() {
      for (const i in this.alerts) {
        this.alerts[i] = false
      }
      if (!this.userName) {
        this.alerts.noUserName = true
      } else if (!this.userMail) {
        this.alerts.noUserMail = true
      } else if (!this.$checkEmail(this.userMail)) {
        this.alerts.wrongUserMail = true
      } else if (!this.selectedDepartment) {
        this.alerts.noSelectedDepartment = true
      } else if (!this.userMessage) {
        this.alerts.noUserMessage = true
      } else if (this.captchaUser !== this.captchaRef) {
        this.alerts.wrongCaptchaUser = true
      } else {
        // this.validForm = true
        this.disabledButton = true
        const messageIntroduction = `Nom : ${this.userName} \nEmail : ${this.userMail} \nDépartement : ${this.selectedDepartment} \n\nMessage : \n`
        this.$mail
          .send({
            config: 'oiseauxdefrance',
            subject:
              '[Atlas ODF] Je souhaite avoir des renseignements sur le projet ODF',
            text: messageIntroduction + this.userMessage,
          })
          .then((response) => {
            // console.log(response)
            this.validForm = true
          })
          .catch((error) => {
            this.alerts.sendingFail = true
            this.disabledButton = false
            if (error.response) {
              console.log(error.response.data)
            }
          })
      }
    },
    deleteAlert() {
      for (const i in this.alerts) {
        this.alerts[i] = false
      }
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}

.TopSection {
  padding: 16px 5% 0;
}
</style>
