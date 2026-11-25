<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { ClipboardList, LoaderCircle } from '@lucide/vue'
import { Badge } from '@/components/badge'
import { Button } from '@/components/button'
import { Card } from '@/components/card'
import { Table } from '@/components/table'
import { api } from '@/lib/api'
import { fechaHora } from '@/lib/format'
import type { Auditoria } from '@/lib/types'

const registros = ref<Auditoria[]>([])
const cargando = ref(true)
const error = ref('')
const filtro = ref('todas')

const variantes: Record<string, 'success' | 'secondary' | 'warning' | 'default'> = {
  crear: 'success',
  editar: 'secondary',
  ocultar: 'warning',
  reactivar: 'default',
}

const filtrados = computed(() =>
  filtro.value === 'todas'
    ? registros.value
    : registros.value.filter((r) => r.accion === filtro.value),
)

async function cargar() {
  cargando.value = true
  error.value = ''
  try {
    registros.value = await api.auditoria(200)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudo cargar la auditoría.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-end justify-between gap-3">
      <div>
        <h2 class="flex items-center gap-2 text-base font-semibold text-foreground">
          <ClipboardList class="size-4 text-primary" />
          Registro de auditoría
        </h2>
        <p class="text-sm text-muted-foreground">
          Cada creación, edición, ocultamiento o reactivación guarda usuario, fecha y detalle.
        </p>
      </div>
      <div class="flex items-center gap-2">
        <select
          v-model="filtro"
          class="h-9 rounded-md border border-input bg-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50"
          aria-label="Filtrar por acción"
        >
          <option value="todas">Todas las acciones</option>
          <option value="crear">Crear</option>
          <option value="editar">Editar</option>
          <option value="ocultar">Ocultar</option>
          <option value="reactivar">Reactivar</option>
        </select>
        <Button variant="outline" :disabled="cargando" @click="cargar">Actualizar</Button>
      </div>
    </div>

    <div v-if="error" class="rounded-xl border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">
      {{ error }}
    </div>

    <Card.Root>
      <Card.Content class="px-0 py-2">
        <Table.Root>
          <Table.Header>
            <Table.Row>
              <Table.Head>Fecha y hora</Table.Head>
              <Table.Head>Producto</Table.Head>
              <Table.Head>Acción</Table.Head>
              <Table.Head>Usuario</Table.Head>
              <Table.Head>Detalle</Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            <template v-if="cargando">
              <Table.Row>
                <Table.Cell colspan="5" class="py-10 text-center text-muted-foreground">
                  <LoaderCircle class="mx-auto mb-2 size-5 animate-spin" />
                  Cargando auditoría…
                </Table.Cell>
              </Table.Row>
            </template>
            <template v-else-if="filtrados.length === 0">
              <Table.Row>
                <Table.Cell colspan="5" class="py-10 text-center text-muted-foreground">
                  Todavía no hay movimientos registrados.
                </Table.Cell>
              </Table.Row>
            </template>
            <template v-else>
              <Table.Row v-for="registro in filtrados" :key="registro.id">
                <Table.Cell class="whitespace-nowrap text-muted-foreground">
                  {{ fechaHora(registro.fecha) }}
                </Table.Cell>
                <Table.Cell class="min-w-[200px]">
                  <p class="font-medium text-foreground">{{ registro.producto }}</p>
                  <p class="font-mono text-[11px] text-muted-foreground">{{ registro.sku }}</p>
                </Table.Cell>
                <Table.Cell>
                  <Badge :variant="variantes[registro.accion] ?? 'secondary'">
                    {{ registro.accion }}
                  </Badge>
                </Table.Cell>
                <Table.Cell class="text-muted-foreground">{{ registro.usuario }}</Table.Cell>
                <Table.Cell class="max-w-[420px] text-sm text-muted-foreground">
                  {{ registro.detalle ?? '—' }}
                </Table.Cell>
              </Table.Row>
            </template>
          </Table.Body>
        </Table.Root>
      </Card.Content>
    </Card.Root>
  </div>
</template>
