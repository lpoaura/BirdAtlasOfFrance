<template>
  <div class="ContactFormDropdownListRelative">
    <div
      v-click-outside="closeSelect"
      class="ContactFormDropdownListWrapper"
      :class="selectIsOpen ? 'open' : ''"
      :style="{ 'z-index': zIndex }"
    >
      <div
        class="ContactFormDropdownSelectedOption"
        :class="[selectedItem ? '' : 'placeholder']"
        @click="openOrCloseSelect"
      >
        <span>{{ selectedItem ? selectedItem : defaultMessage }}</span>
        <img
          class="ContactFormDropdownListChevron"
          :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
        />
      </div>
      <div v-show="selectIsOpen" class="ContactFormDropdownResultsSplit"></div>
      <div v-show="selectIsOpen" class="ContactFormDropdownOptionsContent">
        <div class="ContactFormDropdownOptionsOverflow">
          <li
            v-for="(item, index) in itemsList"
            :key="index"
            class="ContactFormDropdownOption"
            @click="updateSelectedItem(item, index)"
          >
            {{ item }}
          </li>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    zIndex: {
      type: Number,
      required: true,
    },
    defaultMessage: {
      type: String,
      required: true,
    },
    itemsList: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
    selectedItem: null,
    selectIsOpen: false,
  }),
  methods: {
    openOrCloseSelect() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSelect() {
      this.selectIsOpen = false
    },
    updateSelectedItem(item, index) {
      this.$emit('selectedItem', [item, index])
      this.selectedItem = item
      this.selectIsOpen = false
    },
  },
}
</script>

<style scoped>
.ContactFormDropdownListRelative {
  position: relative;
  width: 626px;
  height: 32px;
  margin-bottom: 24px;
}

.ContactFormDropdownListWrapper {
  position: absolute;
  background: #fcfcfc;
  width: 626px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #262626;
}

.ContactFormDropdownListWrapper.open {
  border: 1px solid #eece25;
}

.ContactFormDropdownSelectedOption {
  width: 100%;
  height: 32px;
  padding: 0 12px;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
}

.ContactFormDropdownSelectedOption.placeholder {
  color: rgba(38, 38, 38, 0.6);
}

.ContactFormDropdownListChevron {
  width: 8px;
}

.ContactFormDropdownResultsSplit {
  width: 100%;
  height: 0;
  border: 0.5px solid rgba(38, 38, 38, 0.1);
}

.ContactFormDropdownOptionsContent {
  padding: 6px 0 6px 6px;
}

.ContactFormDropdownOptionsOverflow {
  max-height: 166px;
  overflow-y: auto;
}

.ContactFormDropdownOption {
  list-style: none;
  width: 100%;
  padding: 6px;
  cursor: pointer;
  border-radius: 4px;
}

.ContactFormDropdownOption:hover {
  background: rgba(238, 206, 37, 0.4);
  font-weight: bold;
}
</style>
