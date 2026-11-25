<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  ArrowUpRight,
  Boxes,
  CalendarClock,
  CircleCheck,
  Package,
  TrendingUp,
  TriangleExclamationPoint,
} from '@lucide/vue'
import { Badge } from '@/components/badge'
import { Button } from '@/components/button'
import { Card } from '@/components/card'
import { Table } from '@/components/table'
import StatCard from '@/components/StatCard.vue'
import { api } from '@/lib/api'
import { clp, fecha, numero } from '@/lib/format'
import type { Dashboard } from '@/lib/types'

const datos = ref<Dashboard | null>(null)
const cargando = ref(true)
const error = ref('')

const maximoTipo = computed(() => {
  const valores = datos.value?.por_tipo.map((t) => t.stock_neto) ?? [1]
  return Math.max(...valores, 1)
})

async function cargar() {
  cargando.value = true
  error.value = ''
  try {
    datos.value = await api.dashboard()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudo cargar el panel'
  } finally {
    cargando.value = false
  }
}

function tonoVencimiento(dias: number) {
  if (dias < 0) return 'destructive' as const
  if (dias <= 30) return 'warning' as const
  return 'secondary' as const
}

function textoVencimiento(dias: number) {
  if (dias < 0) return `Vencido hace ${Math.abs(dias)} d`
  if (dias === 0) return 'Vence hoy'
  return `En ${dias} d`
}

onMounted(cargar)
</script>

<template>
  <div class="space-y-5">
    <div v-if="error" class="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-destructive/30 bg-destructive/5 px-4 py-3">
      <p class="text-sm text-destructive">{{ error }}</p>
      <Button variant="outline" size="sm" @click="cargar">Reintentar</Button>
    </div>

    <div v-if="cargando" class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <div v-for="i in 4" :key="i" class="h-[104px] animate-pulse rounded-xl border bg-background" />
    </div>

    <template v-else-if="datos">
      <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          etiqueta="Productos activos"
          :valor="numero(datos.productos_activos)"
          :detalle="`${numero(datos.productos_ocultos)} oculto(s) de ${numero(datos.productos_total)}`"
          :icono="Package"
          tono="primario"
        />
        <StatCard
          etiqueta="Stock neto"
          :valor="numero(datos.stock_neto)"
          :detalle="`${numero(datos.stock_disponible)} disp. · ${numero(datos.stock_reservado)} reservado`"
          :icono="Boxes"
          tono="verde"
        />
        <StatCard
          etiqueta="Lotes registrados"
          :valor="numero(datos.lotes_total)"
          :detalle="`${numero(datos.lotes_vencidos)} vencido(s)`"
          :icono="TrendingUp"
          tono="neutro"
        />
        <StatCard
          etiqueta="Por vencer (30 días)"
          :valor="numero(datos.lotes_por_vencer)"
          :detalle="`Valor del stock: ${clp(datos.valor_stock)}`"
          :icono="CalendarClock"
          tono="ambar"
        />
      </div>

      <div class="grid gap-4 lg:grid-cols-3">
        <Card.Root class="lg:col-span-2">
          <Card.Header>
            <div class="flex items-center justify-between gap-2">
              <Card.Title class="text-base">Stock neto por categoría</Card.Title>
              <Badge variant="secondary">{{ datos.por_tipo.length }} categorías</Badge>
            </div>
            <Card.Description>Unidades disponibles menos reservadas.</Card.Description>
          </Card.Header>
          <Card.Content class="space-y-3.5 pt-1">
            <div v-for="tipo in datos.por_tipo" :key="tipo.tipo_producto">
              <div class="mb-1 flex items-baseline justify-between gap-2 text-sm">
                <span class="truncate font-medium text-foreground">{{ tipo.tipo_producto }}</span>
                <span class="shrink-0 tabular-nums text-muted-foreground">
                  {{ numero(tipo.stock_neto) }} u. · {{ tipo.productos }} prod.
                </span>
              </div>
              <div class="h-2 overflow-hidden rounded-full bg-secondary">
                <div
                  class="h-full rounded-full bg-primary/80 transition-all"
                  :style="{ width: `${Math.max((tipo.stock_neto / maximoTipo) * 100, tipo.stock_neto > 0 ? 4 : 0)}%` }"
                />
              </div>
            </div>
          </Card.Content>
        </Card.Root>

        <Card.Root>
          <Card.Header>
            <Card.Title class="text-base">Alertas de stock</Card.Title>
            <Card.Description>Datos que conviene revisar.</Card.Description>
          </Card.Header>
          <Card.Content class="pt-1">
            <div v-if="datos.alertas.length === 0" class="flex items-start gap-2 rounded-lg bg-emerald-500/10 p-3 text-sm text-emerald-800">
              <CircleCheck class="mt-0.5 size-4 shrink-0" />
              <p>Sin alertas: stock y vencimientos consistentes.</p>
            </div>
            <ul v-else class="space-y-2">
              <li
                v-for="alerta in datos.alertas"
                :key="alerta.tipo"
                class="flex items-start gap-2 rounded-lg bg-amber-500/10 p-3 text-sm text-amber-900"
              >
                <TriangleExclamationPoint class="mt-0.5 size-4 shrink-0" />
                <span>{{ alerta.mensaje }}</span>
              </li>
            </ul>
            <RouterLink
              to="/lotes"
              class="mt-3 inline-flex items-center gap-1 text-xs font-medium text-primary hover:underline"
            >
              Revisar lotes
              <ArrowUpRight class="size-3.5" />
            </RouterLink>
          </Card.Content>
        </Card.Root>
      </div>

      <Card.Root>
        <Card.Header>
          <div class="flex flex-wrap items-center justify-between gap-2">
            <div>
              <Card.Title class="text-base">Próximos vencimientos</Card.Title>
              <Card.Description>Lotes que vencen en los próximos 60 días.</Card.Description>
            </div>
            <Button variant="outline" size="sm" as-child>
              <RouterLink to="/lotes">Ver todos los lotes</RouterLink>
            </Button>
          </div>
        </Card.Header>
        <Card.Content class="px-0 pt-1">
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Producto</Table.Head>
                <Table.Head>Lote</Table.Head>
                <Table.Head>Vence</Table.Head>
                <Table.Head class="justify-end">Stock neto</Table.Head>
                <Table.Head>Estado</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              <Table.Row v-for="item in datos.proximos_vencimientos" :key="item.lote">
                <Table.Cell class="max-w-[260px] truncate font-medium">{{ item.producto }}</Table.Cell>
                <Table.Cell class="font-mono text-xs text-muted-foreground">{{ item.lote }}</Table.Cell>
                <Table.Cell class="whitespace-nowrap">{{ fecha(item.fecha_vencimiento) }}</Table.Cell>
                <Table.Cell class="text-right tabular-nums">{{ numero(item.stock_neto) }}</Table.Cell>
                <Table.Cell>
                  <Badge :variant="tonoVencimiento(item.dias_restantes)">
                    {{ textoVencimiento(item.dias_restantes) }}
                  </Badge>
                </Table.Cell>
              </Table.Row>
              <Table.Row v-if="datos.proximos_vencimientos.length === 0">
                <Table.Cell colspan="5" class="py-8 text-center text-muted-foreground">
                  No hay vencimientos en los próximos 60 días.
                </Table.Cell>
              </Table.Row>
            </Table.Body>
          </Table.Root>
        </Card.Content>
      </Card.Root>
    </template>
  </div>
</template>
