<template>
  <section class="KeyDataSection">
    <div class="KeyDataTitle">L'Atlas en quelques chiffres...</div>
    <div class="KeyDataContent">
      <div class="KeyDataCard">
        <div class="KeyDataBlock">
          <img class="KeyDataBlockIcon" src="/species-number.svg" />
          <div class="KeyDataBlockContent">
            <div class="KeyDataBlockData">???</div>
            <div class="KeyDataBlockText" style="text-align: center">
              espèces recensées<br />sur la période 2019 - 2023
            </div>
          </div>
        </div>
        <div class="KeyDataBlock">
          <div class="KeyDataBlockDetails">
            <img
              class="KeyDataBlockDetailsIcon"
              src="/breeding-species-number.svg"
            />
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockDetailsData">???</div>
              <div class="KeyDataBlockText">espèces nicheuses</div>
            </div>
          </div>
          <div class="KeyDataBlockDetails">
            <img
              class="KeyDataBlockDetailsIcon"
              src="/winter-species-number.svg"
            />
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockDetailsData">???</div>
              <div class="KeyDataBlockText">espèces hivernantes</div>
            </div>
          </div>
        </div>
      </div>
      <div class="KeyDataCard">
        <div class="KeyDataBlock">
          <div class="KeyDataBlockIcon" style="color: red">
            Graphe à venir...
          </div>
          <div class="KeyDataBlockContent">
            <div class="KeyDataBlockData">???</div>
            <div class="KeyDataBlockText" style="text-align: center">
              heures de prospection<br />sur la période 2019 - 2023
            </div>
          </div>
        </div>
        <div class="KeyDataBlock">
          <div class="KeyDataBlockDetails">
            <div
              class="KeyDataBlockDetailsDot"
              style="background-color: #2a9d8f"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockText" style="font-weight: 500">
                Période de reproduction
              </div>
              <div class="KeyDataBlockText">??% | ???? heures</div>
            </div>
          </div>
          <div class="KeyDataBlockDetails">
            <div
              class="KeyDataBlockDetailsDot"
              style="background-color: #264653"
            ></div>
            <div class="KeyDataBlockDetailsContent">
              <div class="KeyDataBlockText" style="font-weight: 500">
                Période d'hivernage
              </div>
              <div class="KeyDataBlockText">??% | ???? heures</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.KeyDataSection {
  width: 100%;

  /* À MODIFIER LORSQU'IL Y AURA LES AUTRES BLOCS */
  height: 470px;

  /* À modifier en : padding: 3.5% 5%; */
  padding: 0 5% 3.5% 5%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.KeyDataTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
}

.KeyDataContent {
  display: flex;
  justify-content: space-between;
}

.KeyDataCard {
  background: rgba(57, 118, 90, 0.1);
  width: 49%;
  height: 354px;
  border-radius: 12px;

  /* padding: 1.8% 2.5%; */
  padding: 1.6vw 1.6vw;
  display: flex;
  justify-content: space-between;
}

.KeyDataBlock {
  width: 49%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
}

.KeyDataBlockIcon {
  height: 188px;
}

.KeyDataBlockContent {
  height: 92px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.KeyDataBlockData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 32px;
  line-height: 48px;
}

.KeyDataBlockText {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
}

.KeyDataBlockDetails {
  background: rgba(57, 118, 90, 0.1);
  width: 100%;
  height: 47%;
  border-radius: 8px;
  padding-left: 10%;
  padding-right: 2%;
  display: flex;
  align-items: center;
}

.KeyDataBlockDetailsIcon {
  height: 52px;
  margin-right: 8%;
}

.KeyDataBlockDetailsDot {
  min-width: 12px;
  max-width: 12px;
  min-height: 12px;
  max-height: 12px;
  border-radius: 50%;
  margin-right: 8%;
}

.KeyDataBlockDetailsContent {
  display: flex;
  flex-direction: column;
}

.KeyDataBlockDetailsData {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: bold;
  font-size: 24px;
  line-height: 36px;
}
</style>
