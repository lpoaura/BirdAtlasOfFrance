<template>
  <v-container fluid>
    <header class="ContactFormHeader">
      <breadcrumb class="bottom-margin-40" />
      <h3 v-show="!validForm" class="fw-600 text-center">
        Je souhaite contacter un référent local
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
        <span class="black02 fw-500 bottom-margin-8"
          >Qui souhaitez-vous contacter ?</span
        >
        <menu class="SelectorMenu">
          <div
            v-for="(item, index) in coordinatorsList"
            :key="index"
            class="SelectorItem"
            :class="[item === selectedCoordinator ? 'selected' : '']"
            @click="updateSelectedCoordinator(item)"
          >
            {{ item }}
          </div>
        </menu>
        <span
          v-show="selectedCoordinator"
          class="black02 fw-500 bottom-margin-8"
        >
          Département
        </span>
        <contact-form-dropdown-list
          v-show="selectedCoordinator"
          :z-index="4"
          default-message="Département"
          :items-list="$departmentsList"
          @selectedItem="updateSelectedDepartment"
        />
        <div
          v-show="selectedCoordinator === 'Mon référent local'"
          class="GridFeatureContent"
        >
          <switch-button v-model="gridFeatureIsKnow"></switch-button>
          <span class="black02 fw-500">
            Je connais le numéro de la maille à prospecter
          </span>
          <input
            v-show="gridFeatureIsKnow"
            v-model="gridFeature"
            class="ContactFormInput GridFeatureInput no-bottom-margin"
            type="text"
            placeholder="E080N638"
          />
        </div>
        <span
          v-show="selectedCoordinator"
          class="black02 fw-500 bottom-margin-8"
          >Message</span
        >
        <textarea
          v-show="selectedCoordinator"
          v-model="userMessage"
          placeholder="Bonjour..."
          class="ContactFormTextarea"
        />
        <captcha-form
          v-show="selectedCoordinator"
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
          v-show="selectedCoordinator"
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
import SwitchButton from '~/components/global/SwitchButton.vue'
import CaptchaForm from '~/components/about/CaptchaForm.vue'
import ContactFormConfirmation from '~/components/about/ContactFormConfirmation.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
    'contact-form-dropdown-list': ContactFormDropdownList,
    'switch-button': SwitchButton,
    'captcha-form': CaptchaForm,
    'contact-form-confirmation': ContactFormConfirmation,
  },
  data: () => ({
    userName: '',
    userMail: '',
    selectedCoordinator: null,
    selectedDepartment: null,
    gridFeatureIsKnow: false,
    gridFeature: '',
    userMessage: '',
    captchaRef: '',
    captchaUser: '',
    coordinatorsList: ['Le coordinateur national', 'Mon référent local'],
    alertMessage: null,
    validForm: false,
    disabledButton: false,
  }),
  mounted() {
    this.captchaRef = this.$generateCaptcha()
  },
  methods: {
    updateSelectedCoordinator(coordinator) {
      this.selectedCoordinator = coordinator
      // console.log(this.selectedCoordinator)
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
      if (this.gridFeatureIsKnow && !this.gridFeature) {
        this.alertMessage =
          "Veuillez renseigner un numéro de maille ou décochez l'option correspondante"
      }
      if (!this.selectedDepartment) {
        this.alertMessage = 'Veuillez sélectionner un département'
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
        (!this.gridFeatureIsKnow ||
          (this.gridFeatureIsKnow && this.gridFeature)) &&
        this.selectedDepartment &&
        this.userMessage &&
        this.captchaUser === this.captchaRef
      ) {
        // this.validForm = true
        this.disabledButton = true
        this.alertMessage = null
        let messageIntroduction = `Nom : ${this.userName} \nEmail : ${this.userMail} \nDépartement : ${this.selectedDepartment} \nSouhaite contacter : ${this.selectedCoordinator}`
        messageIntroduction += this.gridFeature
          ? `\nNuméro de maille : ${this.gridFeature} \n\nMessage : \n`
          : '\n\nMessage : \n'
        this.$mail
          .send({
            config: 'oiseauxdefrance',
            subject: '[Atlas ODF] Je souhaite contacter un référent local',
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

.GridFeatureContent {
  height: 32px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.GridFeatureInput {
  width: 140px;
  margin-left: 12px;
}
</style>
