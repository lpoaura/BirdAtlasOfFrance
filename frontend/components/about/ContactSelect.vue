<template>
  <div class="SelectRelative">
    <div
      v-click-outside="closeSelect"
      class="SelectWrapper"
      :class="selectIsOpen ? 'open' : ''"
      :style="{ 'z-index': zIndex }"
    >
      <div
        class="SelectedItem"
        :class="[selectedItem ? '' : 'placeholder']"
        @click="openOrCloseSelect"
      >
        <span>{{ selectedItem ? selectedItem : defaultMessage }}</span>
        <img
          class="SelectChevron"
          :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
        />
      </div>
      <div v-show="selectIsOpen" class="ResultsSplit"></div>
      <div v-show="selectIsOpen" class="SelectItemsContent">
        <div class="SelectItemsOverflow">
          <li
            v-for="(item, index) in itemsList"
            :key="index"
            class="SelectItem"
            @click="updateSelectedItem(item)"
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
    updateSelectedItem(item) {
      this.$emit('selectedItem', item)
      this.selectedItem = item
      this.selectIsOpen = false
    },
  },
}
</script>

<style scoped>
.SelectRelative {
  position: relative;
  width: 626px;
  height: 32px;
  margin-bottom: 16px;
}

.SelectWrapper {
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
  color: rgba(38, 38, 38, 0.6);
}

.SelectWrapper.open {
  border: 1px solid #39765a;
}

.SelectedItem {
  width: 100%;
  height: 32px;
  padding: 0 2%;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
}

.SelectedItem.placeholder {
  color: rgba(38, 38, 38, 0.35);
}

.SelectChevron {
  width: 7px;
}

.ResultsSplit {
  width: 100%;
  height: 0;
  border: 0.5px solid rgba(38, 38, 38, 0.1);
}

.SelectItemsContent {
  padding: 1% 0 1% 1%;
}

.SelectItemsOverflow {
  max-height: 166px;
  overflow-y: auto;
}

.SelectItem {
  list-style: none;
  width: 100%;
  padding: 1%;
  cursor: pointer;
  border-radius: 4px;
}

.SelectItem:hover {
  background: rgba(57, 118, 90, 0.1);
  font-weight: bold;
  color: #39765a;
}
</style>
