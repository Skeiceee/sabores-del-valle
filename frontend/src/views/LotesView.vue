<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { Boxes, CalendarClock, CircleExclamationPoint, LoaderCircle, Search } from '@lucide/vue'
import { Badge } from '@/components/badge'
import { Button } from '@/components/button'
import { Card } from '@/components/card'
import { Input } from '@/components/input'
import { Table } from '@/components/table'
import StatCard from '@/components/StatCard.vue'
import { api } from '@/lib/api'
import { fecha, numero } from '@/lib/format'
import type { Lote, TipoProducto } from '@/lib/types'

const lotes = ref<Lote[]>([])
const tipos = ref<TipoProducto[]>([])
const cargando = ref(true)
const error = ref('')

const buscar = ref('')
const estadoFiltro = ref('todos')
const tipoFiltro = ref<number | ''>('')

let debounce: ReturnType<typeof setTimeout> | undefined

const totalNeto = computed(() => lotes.value.reduce((suma, lote) => suma + lote.stock_neto, 0))
const vencidos = computed(() => lotes.value.filter((l) => l.estado_vencimiento === 'vencido').length)
const porVencer = computed(() => lotes.value.filter((l) => l.estado_vencimiento === 'por_vencer').length)

async function cargar() {
  cargando.value = true
  error.value = ''
  try {
    lotes.value = await api.lotes({
      buscar: buscar.value,
      estado: estadoFiltro.value,
      tipo_producto_id: tipoFiltro.value,
    })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudieron cargar los lotes.'
  } finally {
    cargando.value = false
  }
}

watch([buscar, estadoFiltro, tipoFiltro], () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(cargar, 250)
})

const etiquetasEstado: Record<string, string> = {
  vigente: 'Vigente',
  por_vencer: 'Por vencer',
  vencido: 'Vencido',
  sin_fecha: 'Sin fecha',
}

const variantesEstado: Record<string, 'success' | 'warning' | 'destructive' | 'secondary'> = {
  vigente: 'success',
  por_vencer: 'warning',
  vencido: 'destructive',
  sin_fecha: 'secondary',
}

onMounted(async () => {
  try {
    tipos.value = await api.tipos()
  } catch {
    /* el error se muestra al cargar lotes */
  }
  await cargar()
})
</script>

<template>
  <div class="space-y-4">
    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard
        etiqueta="Lotes en la vista"
        :valor="numero(lotes.length)"
        detalle="Según los filtros aplicados"
        :icono="Boxes"
        tono="neutro"
      />
      <StatCard
        etiqueta="Stock neto"
        :valor="numero(totalNeto)"
        detalle="Disponible menos reservado"
        :icono="Boxes"
        tono="verde"
      />
      <StatCard
        etiqueta="Por vencer"
        :valor="numero(porVencer)"
        detalle="En los próximos 30 días"
        :icono="CalendarClock"
        tono="ambar"
      />
      <StatCard
        etiqueta="Vencidos"
        :valor="numero(vencidos)"
        detalle="Revisar antes de vender"
        :icono="CircleExclamationPoint"
        tono="rojo"
      />
    </div>

    <Card.Root>
      <Card.Content class="flex flex-col gap-3 p-4 md:flex-row md:items-center">
        <div class="relative flex-1">
          <Search class="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            v-model="buscar"
            class="pl-9"
            placeholder="Buscar por producto, SKU o código de lote…"
            aria-label="Buscar lotes"
          />
        </div>
        <select
          v-model="tipoFiltro"
          class="h-9 rounded-md border border-input bg-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 md:w-52"
          aria-label="Filtrar por categoría"
        >
          <option value="">Todas las categorías</option>
          <option v-for="tipo in tipos" :key="tipo.id" :value="tipo.id">
            {{ tipo.nombre }}
          </option>
        </select>
        <select
          v-model="estadoFiltro"
          class="h-9 rounded-md border border-input bg-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 md:w-44"
          aria-label="Filtrar por vencimiento"
        >
          <option value="todos">Todos los estados</option>
          <option value="vigente">Vigentes</option>
          <option value="por_vencer">Por vencer (30 d)</option>
          <option value="vencido">Vencidos</option>
          <option value="sin_stock">Sin stock neto</option>
        </select>
        <Button variant="outline" :disabled="cargando" @click="cargar">Actualizar</Button>
      </Card.Content>
    </Card.Root>

    <div v-if="error" class="rounded-xl border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">
      {{ error }}
    </div>

    <Card.Root>
      <Card.Content class="px-0 py-2">
        <Table.Root>
          <Table.Header>
            <Table.Row>
              <Table.Head>Producto</Table.Head>
              <Table.Head>Lote</Table.Head>
              <Table.Head>Elaboración</Table.Head>
              <Table.Head>Vencimiento</Table.Head>
              <Table.Head class="justify-end">Disponible</Table.Head>
              <Table.Head class="justify-end">Reservado</Table.Head>
              <Table.Head class="justify-end">Neto</Table.Head>
              <Table.Head>Estado</Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            <template v-if="cargando">
              <Table.Row>
                <Table.Cell colspan="8" class="py-10 text-center text-muted-foreground">
                  <LoaderCircle class="mx-auto mb-2 size-5 animate-spin" />
                  Cargando lotes…
                </Table.Cell>
              </Table.Row>
            </template>
            <template v-else-if="lotes.length === 0">
              <Table.Row>
                <Table.Cell colspan="8" class="py-10 text-center text-muted-foreground">
                  No hay lotes que coincidan con el filtro.
                </Table.Cell>
              </Table.Row>
            </template>
            <template v-else>
              <Table.Row v-for="lote in lotes" :key="lote.id">
                <Table.Cell class="min-w-[220px]">
                  <p class="font-medium text-foreground">{{ lote.producto }}</p>
                  <p class="text-[11px] text-muted-foreground">
                    {{ lote.sku }} · {{ lote.tipo_producto }}
                  </p>
                </Table.Cell>
                <Table.Cell class="font-mono text-xs whitespace-nowrap text-muted-foreground">
                  {{ lote.codigo }}
                </Table.Cell>
                <Table.Cell class="whitespace-nowrap text-muted-foreground">
                  {{ fecha(lote.fecha_elaboracion) }}
                </Table.Cell>
                <Table.Cell class="whitespace-nowrap">
                  {{ fecha(lote.fecha_vencimiento) }}
                </Table.Cell>
                <Table.Cell class="text-right tabular-nums">
                  {{ numero(lote.stock_disponible) }}
                </Table.Cell>
                <Table.Cell class="text-right tabular-nums text-muted-foreground">
                  {{ numero(lote.stock_reservado) }}
                </Table.Cell>
                <Table.Cell class="text-right font-semibold tabular-nums">
                  <span :class="lote.stock_neto < 0 ? 'text-destructive' : ''">
                    {{ numero(lote.stock_neto) }}
                  </span>
                </Table.Cell>
                <Table.Cell>
                  <Badge :variant="variantesEstado[lote.estado_vencimiento]">
                    {{ etiquetasEstado[lote.estado_vencimiento] }}
                  </Badge>
                </Table.Cell>
              </Table.Row>
            </template>
          </Table.Body>
        </Table.Root>
      </Card.Content>
    </Card.Root>

    <p class="text-xs text-muted-foreground">
      El stock neto se calcula como <span class="font-medium">stock disponible − stock reservado</span>.
      Los lotes vencidos y las reservas mayores al disponible se muestran tal como están en la base,
      para poder corregirlos.
    </p>
  </div>
</template>
