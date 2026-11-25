<script setup lang="ts">
import { computed } from 'vue'
import type { Component } from 'vue'
import { Card } from '@/components/card'

const props = defineProps<{
  etiqueta: string
  valor: string
  detalle?: string
  icono: Component
  tono?: 'primario' | 'verde' | 'ambar' | 'rojo' | 'neutro'
}>()

const tonos = computed(
  () =>
    ({
      primario: 'bg-primary/10 text-primary',
      verde: 'bg-emerald-500/10 text-emerald-700',
      ambar: 'bg-amber-500/10 text-amber-700',
      rojo: 'bg-red-500/10 text-red-700',
      neutro: 'bg-secondary text-secondary-foreground',
    })[props.tono ?? 'primario'],
)
</script>

<template>
  <Card.Root>
    <Card.Content class="flex items-start justify-between gap-3 p-4">
      <div class="min-w-0">
        <p class="text-xs font-medium tracking-wide text-muted-foreground uppercase">
          {{ etiqueta }}
        </p>
        <p class="mt-1 text-2xl font-semibold tracking-tight text-foreground">
          {{ valor }}
        </p>
        <p v-if="detalle" class="mt-0.5 text-xs text-muted-foreground">{{ detalle }}</p>
      </div>
      <div :class="['flex size-9 shrink-0 items-center justify-center rounded-lg', tonos]">
        <component :is="icono" class="size-4.5" />
      </div>
    </Card.Content>
  </Card.Root>
</template>
