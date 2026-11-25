<script setup lang="ts">
import { Button } from '@/components/button'
import { Dialog } from '@/components/dialog'

withDefaults(
  defineProps<{
    open: boolean
    titulo: string
    mensaje: string
    confirmar?: string
    variante?: 'default' | 'destructive'
    procesando?: boolean
  }>(),
  {
    confirmar: 'Confirmar',
    variante: 'default',
    procesando: false,
  },
)

const emit = defineEmits<{
  'update:open': [boolean]
  confirmar: []
}>()
</script>

<template>
  <Dialog.Root :open="open" @update:open="emit('update:open', $event)">
    <Dialog.Content class="w-[min(460px,calc(100vw-2rem))]">
      <Dialog.Header>
        <Dialog.Title>{{ titulo }}</Dialog.Title>
        <Dialog.Description>{{ mensaje }}</Dialog.Description>
      </Dialog.Header>
      <Dialog.Footer>
        <Button variant="outline" :disabled="procesando" @click="emit('update:open', false)">
          Cancelar
        </Button>
        <Button :variant="variante" :disabled="procesando" @click="emit('confirmar')">
          {{ confirmar }}
        </Button>
      </Dialog.Footer>
    </Dialog.Content>
  </Dialog.Root>
</template>
