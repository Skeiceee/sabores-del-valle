<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { Search, Store } from '@lucide/vue'
import { Badge } from '@/components/badge'
import { Card } from '@/components/card'
import { Input } from '@/components/input'
import { api } from '@/lib/api'
import { clp, fecha, numero } from '@/lib/format'
import type { Producto, TipoProducto } from '@/lib/types'

const productos = ref<Producto[]>([])
const tipos = ref<TipoProducto[]>([])
const cargando = ref(true)
const error = ref('')

const buscar = ref('')
const tipoFiltro = ref<number | ''>('')

let debounce: ReturnType<typeof setTimeout> | undefined

async function cargar() {
  cargando.value = true
  error.value = ''
  try {
    productos.value = await api.catalogo({
      buscar: buscar.value,
      tipo_producto_id: tipoFiltro.value,
    })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudo cargar el catálogo.'
  } finally {
    cargando.value = false
  }
}

watch([buscar, tipoFiltro], () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(cargar, 250)
})

onMounted(async () => {
  try {
    tipos.value = await api.tipos()
  } catch {
    /* el error se muestra al cargar el catálogo */
  }
  await cargar()
})
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div>
        <h2 class="flex items-center gap-2 text-base font-semibold text-foreground">
          <Store class="size-4 text-primary" />
          Vista previa del catálogo público
        </h2>
        <p class="text-sm text-muted-foreground">
          Solo aparecen productos activos. Cualquier edición u ocultamiento se refleja al instante.
        </p>
      </div>
      <Badge variant="secondary">{{ productos.length }} producto(s) visibles</Badge>
    </div>

    <Card.Root>
      <Card.Content class="flex flex-col gap-3 p-4 md:flex-row md:items-center">
        <div class="relative flex-1">
          <Search class="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            v-model="buscar"
            class="pl-9"
            placeholder="Buscar en el catálogo…"
            aria-label="Buscar en el catálogo"
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
      </Card.Content>
    </Card.Root>

    <div v-if="error" class="rounded-xl border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">
      {{ error }}
    </div>

    <div v-if="cargando" class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      <div v-for="i in 6" :key="i" class="h-52 animate-pulse rounded-xl border bg-background" />
    </div>

    <div v-else-if="productos.length === 0" class="rounded-xl border border-dashed bg-background px-6 py-12 text-center text-sm text-muted-foreground">
      No hay productos visibles con esos filtros.
    </div>

    <div v-else class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      <Card.Root v-for="producto in productos" :key="producto.id" class="flex flex-col">
        <Card.Header class="gap-2">
          <div class="flex items-center justify-between gap-2">
            <Badge variant="secondary">{{ producto.tipo_producto }}</Badge>
            <span class="text-sm font-semibold text-primary">
              {{ clp(producto.precio_venta) }}
            </span>
          </div>
          <Card.Title class="text-base leading-snug">{{ producto.nombre }}</Card.Title>
          <Card.Description class="text-xs">
            {{ producto.formato ?? 'Formato por definir' }} · {{ producto.sku }}
          </Card.Description>
        </Card.Header>
        <Card.Content class="flex flex-1 flex-col gap-3 pt-1">
          <p class="text-sm text-muted-foreground">
            {{ producto.descripcion ?? 'Sin descripción comercial todavía.' }}
          </p>
          <div class="space-y-1.5 text-xs">
            <p v-if="producto.ingredientes">
              <span class="font-medium text-foreground">Ingredientes:</span>
              <span class="text-muted-foreground"> {{ producto.ingredientes }}</span>
            </p>
            <p v-if="producto.alergenos">
              <span class="font-medium text-foreground">Alérgenos:</span>
              <span class="text-muted-foreground"> {{ producto.alergenos }}</span>
            </p>
          </div>
        </Card.Content>
        <Card.Footer class="mt-auto flex flex-wrap items-center justify-between gap-2 border-t border-border pt-3">
          <Badge :variant="producto.stock_neto > 0 ? 'success' : 'destructive'">
            {{ producto.stock_neto > 0 ? `${numero(producto.stock_neto)} disponibles` : 'Agotado' }}
          </Badge>
          <span class="text-[11px] text-muted-foreground">
            {{ producto.lotes }} lote(s) ·
            {{ producto.proximo_vencimiento ? `vence ${fecha(producto.proximo_vencimiento)}` : 'sin vencimiento' }}
          </span>
        </Card.Footer>
      </Card.Root>
    </div>
  </div>
</template>
