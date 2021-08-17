<template>
  <v-container fluid>
    <header class="ContactFormHeader">
      <breadcrumb class="bottom-margin-40" />
      <h3 v-show="!validForm" class="fw-600 text-center">
        J'ai une question sur les méthodes de prospection
      </h3>
    </header>
    <section v-show="!validForm" class="ContactFormSection">
      <div class="ContactFormContent">
        <span class="black02 fw-500 bottom-margin-8">Nom</span>
        <input
          v-model="userName"
          type="text"
          placeholder="Henri Martin"
          class="ContactFormInput"
        />
        <span class="black02 fw-500 bottom-margin-8">Adresse email</span>
        <input
          v-model="userMail"
          type="email"
          placeholder="henri.martin@monmail.fr"
          class="ContactFormInput"
        />
        <span class="black02 fw-500 bottom-margin-8">
          Méthode de prospection
        </span>
        <contact-form-dropdown-list
          :z-index="5"
          default-message="EPOC, SHOC..."
          :items-list="protocolsList"
          @selectedItem="updateSelectedProtocol"
        />
        <span class="black02 fw-500 bottom-margin-8">Département</span>
        <contact-form-dropdown-list
          :z-index="4"
          default-message="Département"
          :items-list="$departmentsList"
          @selectedItem="updateSelectedDepartment"
        />
        <span class="black02 fw-500 bottom-margin-8">Message</span>
        <textarea
          v-model="userMessage"
          placeholder="Bonjour..."
          class="ContactFormTextarea"
        />
        <captcha-form
          :captcha-ref="captchaRef"
          @captchaUser="updateCaptchaUser"
        />
        <div v-if="alertMessage" class="ContactFormAlert">
          <span class="ContactFormAlertMessage">
            {{ alertMessage }}
          </span>
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlertMessage"
          ></i>
        </div>
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
    selectedProtocol: null,
    selectedDepartment: null,
    userMessage: '',
    captchaRef: '',
    captchaUser: '',
    protocolsList: [
      'EPOC ODF',
      'EPOC',
      'STOC',
      'SHOC',
      'Observatoire Rapaces',
      'LIMAT',
      'Wetlands',
      'Listes complètes et données ponctuelles',
    ],
    emailConfigs: [
      'oiseauxdefrance',
      'oiseauxdefrance',
      'stoc',
      'shoc',
      'rapaces',
      'oiseauxdefrance',
      'wetlands',
      'oiseauxdefrance',
    ],
    emailConfig: '',
    alertMessage: null,
    validForm: false,
    disabledButton: false,
  }),
  mounted() {
    this.captchaRef = this.$generateCaptcha()
  },
  methods: {
    updateSelectedProtocol(protocol) {
      this.selectedProtocol = protocol[0]
      // console.log(this.selectedProtocol)
      this.emailConfig = this.emailConfigs[protocol[1]]
      // console.log(this.emailConfig)
    },
    updateSelectedDepartment(department) {
      this.selectedDepartment = department[0]
      // console.log(this.selectedDepartment)
    },
    updateCaptchaUser(captcha) {
      this.captchaUser = captcha
    },
    validateForm() {
      if (this.captchaUser !== this.captchaRef) {
        this.alertMessage =
          "Le code de sécurité que vous avez renseigné n'est pas bon"
      }
      if (!this.userMessage) {
        this.alertMessage = 'Veuillez écrire un message'
      }
      if (!this.selectedDepartment) {
        this.alertMessage = 'Veuillez sélectionner un département'
      }
      if (!this.selectedProtocol) {
        this.alertMessage = 'Veuillez sélectionner une méthode de prospection'
      }
      if (!this.$checkEmail(this.userMail)) {
        this.alertMessage = 'Veuillez renseigner une adresse email valide'
      }
      if (!this.userMail) {
        this.alertMessage = 'Veuillez renseigner votre adresse email'
      }
      if (!this.userName) {
        this.alertMessage = 'Veuillez renseigner votre nom'
      }
      if (
        this.userName &&
        this.$checkEmail(this.userMail) &&
        this.selectedProtocol &&
        this.selectedDepartment &&
        this.userMessage &&
        this.captchaUser === this.captchaRef
      ) {
        // this.validForm = true
        this.disabledButton = true
        this.alertMessage = null
        const messageIntroduction = `Nom : ${this.userName} \nEmail : ${this.userMail} \nDépartement : ${this.selectedDepartment} \n\nMessage : \n`
        this.$mail
          .send({
            config: this.emailConfig,
            subject: `[Atlas ODF] J'ai une question sur les méthodes de prospection (${this.selectedProtocol})`,
            text: messageIntroduction + this.userMessage,
          })
          .then((response) => {
            // console.log(response)
            this.validForm = true
          })
          .catch((error) => {
            this.alertMessage = "L'envoi du mail a échoué..."
            this.disabledButton = false
            if (error.response) {
              console.log(error.response.data)
            }
          })
      }
    },
    deleteAlertMessage() {
      this.alertMessage = null
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}
</style>
