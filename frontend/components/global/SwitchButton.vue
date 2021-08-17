<template>
  <label for="switch-button" :class="{ active: checked }" class="SwitchButton">
    <input
      id="switch-button"
      :checked="checked"
      type="checkbox"
      @change="$emit('change', $event.target.checked)"
    />
    <span class="Slider"></span>
  </label>
</template>

<script>
export default {
  model: {
    prop: 'checked',
    event: 'change',
  },
  props: {
    checked: Boolean,
  },
}
</script>

<style scoped>
.SwitchButton {
  margin-right: 16px;
  display: flex;
  align-items: center;
  user-select: none;
  cursor: pointer;
}

.SwitchButton input[type='checkbox'] {
  opacity: 0;
  position: absolute;
  width: 0;
  height: 0;
}

.SwitchButton .Slider {
  display: inline-block;
  width: 28px;
  height: 16px;
  background: #fcfcfc;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 88px;
  position: relative;
  transition: all 0.3s;
}

.SwitchButton .Slider::before {
  content: '';
  position: absolute;
  left: 1px;
  top: 1px;
  display: block;
  height: 12px;
  width: 12px;
  background: rgba(38, 38, 38, 0.2);
  border-radius: 50%;
  transform: translateX(0);
  transition: all 0.3s cubic-bezier(0.5, -0.6, 0.5, 1.6);
}

.active .Slider {
  background: #eece25;
  border: 1px solid #eece25;
}

.active .Slider::before {
  left: 13px;
  background: #fcfcfc;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.12);
  transform: translateX(40px - 18px);
}
</style>
