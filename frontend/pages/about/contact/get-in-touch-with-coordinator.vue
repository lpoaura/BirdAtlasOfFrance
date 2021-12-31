<template>
  <v-container fluid>
    <main class="TopSection breadcrumb">
      <breadcrumb />
      <header>
        <h3 v-show="!validForm" class="fw-600 text-center">
          Je souhaite contacter un référent local
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
        <span class="black02 fw-500 bottom-margin-8">
          Qui souhaitez-vous contacter ?
        </span>
        <menu class="SelectorMenu">
          <div
            v-for="(item, index) in coordinatorsList"
            :key="index"
            class="SelectorItem"
            :class="item === selectedCoordinator ? 'selected' : ''"
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
        <span v-show="alerts.noSelectedDepartment" class="ContactFormAlert">
          Veuillez sélectionner un département
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <div
          v-show="selectedCoordinator === 'Mon référent local'"
          class="GridFeatureContent"
        >
          <div class="GridFeatureLabel">
            <switch-button v-model="gridFeatureIsKnow"></switch-button>
            <span class="black02 fw-500">
              Je connais le numéro de la maille à prospecter
            </span>
          </div>
          <input
            v-show="gridFeatureIsKnow"
            v-model="gridFeature"
            class="ContactFormInput GridFeatureInput"
            type="text"
            placeholder="E080N638"
          />
        </div>
        <span v-show="alerts.noGridFeature" class="ContactFormAlert">
          Veuillez renseigner un numéro de maille ou décochez l'option
          correspondante
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span
          v-show="selectedCoordinator"
          class="black02 fw-500 bottom-margin-8"
        >
          Message
        </span>
        <textarea
          v-show="selectedCoordinator"
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
          v-show="selectedCoordinator"
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
    selectedCoordinator: null,
    selectedDepartment: null,
    gridFeatureIsKnow: false,
    gridFeature: '',
    userMessage: '',
    captchaRef: '',
    captchaUser: '',
    alerts: {
      noUserName: false,
      noUserMail: false,
      wrongUserMail: false,
      noSelectedDepartment: false,
      noGridFeature: false,
      noUserMessage: false,
      wrongCaptchaUser: false,
      sendingFail: false,
    },
    coordinatorsList: ['Le coordinateur national', 'Mon référent local'],
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
      } else if (this.gridFeatureIsKnow && !this.gridFeature) {
        this.alerts.noGridFeature = true
      } else if (!this.userMessage) {
        this.alerts.noUserMessage = true
      } else if (this.captchaUser !== this.captchaRef) {
        this.alerts.wrongCaptchaUser = true
      } else {
        // this.validForm = true
        this.disabledButton = true
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

.GridFeatureContent {
  margin-bottom: 16px;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}

.GridFeatureLabel {
  margin: 0 12px 8px 0;
  display: flex;
  align-items: center;
}

.GridFeatureInput {
  width: 140px;
  margin-bottom: 8px;
}
</style>
