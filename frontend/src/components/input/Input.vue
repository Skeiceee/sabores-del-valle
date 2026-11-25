<script setup lang="ts">
import { ark } from "@ark-ui/vue";
import { type FieldInputProps, useFieldContext } from "@ark-ui/vue/field";
import { cn } from "cnfast";
import { computed, type HTMLAttributes } from "vue";
import { type InputVariantsProps, inputVariants } from "../input";

interface Props extends Omit<FieldInputProps, "size">, InputVariantsProps {
  class?: HTMLAttributes["class"];
}

const props = defineProps<Props>();
const modelValue = defineModel<string | number>({ default: "" });

const field = useFieldContext();

const delegatedProps = computed<Record<string, unknown>>(() => {
  const base = { ...(props as Record<string, unknown>) };
  delete base.class;
  delete base.size;
  return {
    ...(field?.value.getInputProps() ?? {}),
    ...base,
  };
});
</script>

<template>
  <ark.input
    v-bind="delegatedProps"
    :value="modelValue"
    :class="cn(inputVariants({ size: props.size }), props.class)"
    data-slot="field-input"
    @input="modelValue = ($event.target as HTMLInputElement).value"
  >
    <slot />
  </ark.input>
</template>
