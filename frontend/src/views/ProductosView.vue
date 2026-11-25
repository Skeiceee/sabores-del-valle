<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import {
  CircleCheck,
  Eye,
  EyeOff,
  LoaderCircle,
  Pencil,
  Plus,
  ScrollText,
  Search,
  TriangleExclamationPoint,
} from '@lucide/vue'
import { Badge } from '@/components/badge'
import { Button } from '@/components/button'
import { Card } from '@/components/card'
import { Dialog } from '@/components/dialog'
import { Input } from '@/components/input'
import { Table } from '@/components/table'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import ProductoFormDialog from '@/components/ProductoFormDialog.vue'
import { api } from '@/lib/api'
import { clp, fechaHora, numero } from '@/lib/format'
import type { Auditoria, Producto, TipoProducto } from '@/lib/types'

const productos = ref<Producto[]>([])
const tipos = ref<TipoProducto[]>([])
const cargando = ref(true)
const error = ref('')

const buscar = ref('')
const tipoFiltro = ref<number | ''>('')
const estadoFiltro = ref('todos')

const formOpen = ref(false)
const productoEditar = ref<Producto | null>(null)

const confirmOpen = ref(false)
const productoEstado = ref<Producto | null>(null)
const procesandoEstado = ref(false)

const historialOpen = ref(false)
const historialCargando = ref(false)
const historial = ref<Auditoria[]>([])
const productoHistorial = ref<Producto | null>(null)

const aviso = ref<{ tipo: 'ok' | 'error'; texto: string } | null>(null)
let temporizador: ReturnType<typeof setTimeout> | undefined
let debounce: ReturnType<typeof setTimeout> | undefined

const activos = computed(() => productos.value.filter((p) => p.activo).length)
const ocultos = computed(() => productos.value.filter((p) => !p.activo).length)
const mensajeOcultar = computed(
  () =>
    `El producto "${productoEstado.value?.nombre ?? ''}" dejará de aparecer en el catálogo público. No se elimina: su historial y sus lotes se conservan y puedes reactivarlo cuando quieras.`,
)

function mostrarAviso(tipo: 'ok' | 'error', texto: string) {
  aviso.value = { tipo, texto }
  if (temporizador) clearTimeout(temporizador)
  temporizador = setTimeout(() => (aviso.value = null), 4500)
}

async function cargar() {
  cargando.value = true
  error.value = ''
  try {
    productos.value = await api.productos({
      buscar: buscar.value,
      tipo_producto_id: tipoFiltro.value,
      estado: estadoFiltro.value,
    })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudieron cargar los productos.'
  } finally {
    cargando.value = false
  }
}

watch([buscar, tipoFiltro, estadoFiltro], () => {
  if (debounce) clearTimeout(debounce)
  debounce = setTimeout(cargar, 250)
})

function nuevo() {
  productoEditar.value = null
  formOpen.value = true
}

function editar(producto: Producto) {
  productoEditar.value = producto
  formOpen.value = true
}

function alGuardar(mensaje: string) {
  mostrarAviso('ok', mensaje)
  cargar()
}

function alternar(producto: Producto) {
  if (producto.activo) {
    productoEstado.value = producto
    confirmOpen.value = true
  } else {
    cambiarEstado(producto, true)
  }
}

async function cambiarEstado(producto: Producto, activo: boolean) {
  procesandoEstado.value = true
  try {
    await api.cambiarEstado(producto.id, activo)
    confirmOpen.value = false
    mostrarAviso(
      'ok',
      activo
        ? `"${producto.nombre}" vuelve a estar visible en el catálogo.`
        : `"${producto.nombre}" fue ocultado del catálogo. Su historial se conserva.`,
    )
    cargar()
  } catch (e) {
    mostrarAviso('error', e instanceof Error ? e.message : 'No se pudo cambiar el estado.')
  } finally {
    procesandoEstado.value = false
  }
}

function confirmarOcultar() {
  if (productoEstado.value) cambiarEstado(productoEstado.value, false)
}

async function verHistorial(producto: Producto) {
  productoHistorial.value = producto
  historial.value = []
  historialOpen.value = true
  historialCargando.value = true
  try {
    historial.value = await api.auditoriaProducto(producto.id)
  } catch (e) {
    mostrarAviso('error', e instanceof Error ? e.message : 'No se pudo cargar el historial.')
  } finally {
    historialCargando.value = false
  }
}

const variantesAccion: Record<string, 'success' | 'secondary' | 'warning' | 'default'> = {
  crear: 'success',
  editar: 'secondary',
  ocultar: 'warning',
  reactivar: 'default',
}

onMounted(async () => {
  try {
    tipos.value = await api.tipos()
  } catch {
    /* el listado de productos mostrará el error */
  }
  await cargar()
})
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-end justify-between gap-3">
      <div>
        <h2 class="text-base font-semibold text-foreground">Administración de productos</h2>
        <p class="text-sm text-muted-foreground">
          {{ productos.length }} resultado(s) · {{ activos }} activo(s) ·
          {{ ocultos }} oculto(s)
        </p>
      </div>
      <Button @click="nuevo">
        <Plus />
        Nuevo producto
      </Button>
    </div>

    <div
      v-if="aviso"
      class="flex items-start gap-2 rounded-xl border px-3 py-2.5 text-sm"
      :class="
        aviso.tipo === 'ok'
          ? 'border-emerald-500/30 bg-emerald-500/5 text-emerald-800'
          : 'border-destructive/30 bg-destructive/5 text-destructive'
      "
    >
      <CircleCheck v-if="aviso.tipo === 'ok'" class="mt-0.5 size-4 shrink-0" />
      <TriangleExclamationPoint v-else class="mt-0.5 size-4 shrink-0" />
      <span>{{ aviso.texto }}</span>
    </div>

    <Card.Root>
      <Card.Content class="flex flex-col gap-3 p-4 md:flex-row md:items-center">
        <div class="relative flex-1">
          <Search class="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            v-model="buscar"
            class="pl-9"
            placeholder="Buscar por nombre, SKU o descripción…"
            aria-label="Buscar productos"
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
          class="h-9 rounded-md border border-input bg-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 md:w-40"
          aria-label="Filtrar por estado"
        >
          <option value="todos">Todos</option>
          <option value="activos">Activos</option>
          <option value="ocultos">Ocultos</option>
        </select>
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
              <Table.Head>Categoría</Table.Head>
              <Table.Head>Formato</Table.Head>
              <Table.Head class="justify-end">Precio</Table.Head>
              <Table.Head class="justify-end">Stock neto</Table.Head>
              <Table.Head>Estado</Table.Head>
              <Table.Head class="justify-end">Acciones</Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            <template v-if="cargando">
              <Table.Row>
                <Table.Cell colspan="7" class="py-10 text-center text-muted-foreground">
                  <LoaderCircle class="mx-auto mb-2 size-5 animate-spin" />
                  Cargando productos…
                </Table.Cell>
              </Table.Row>
            </template>
            <template v-else-if="productos.length === 0">
              <Table.Row>
                <Table.Cell colspan="7" class="py-10 text-center text-muted-foreground">
                  No hay productos que coincidan con el filtro.
                </Table.Cell>
              </Table.Row>
            </template>
            <template v-else>
            <Table.Row
              v-for="producto in productos"
              :key="producto.id"
              :class="{ 'opacity-60': !producto.activo }"
            >
              <Table.Cell class="min-w-[220px]">
                <p class="font-medium text-foreground">{{ producto.nombre }}</p>
                <p class="font-mono text-[11px] text-muted-foreground">{{ producto.sku }}</p>
              </Table.Cell>
              <Table.Cell>
                <Badge variant="secondary">{{ producto.tipo_producto }}</Badge>
              </Table.Cell>
              <Table.Cell class="whitespace-nowrap text-muted-foreground">
                {{ producto.formato ?? '—' }}
              </Table.Cell>
              <Table.Cell class="text-right whitespace-nowrap tabular-nums">
                {{ clp(producto.precio_venta) }}
              </Table.Cell>
              <Table.Cell class="text-right whitespace-nowrap">
                <span
                  class="font-semibold tabular-nums"
                  :class="producto.stock_neto < 0 ? 'text-destructive' : ''"
                >
                  {{ numero(producto.stock_neto) }}
                </span>
                <span class="block text-[11px] text-muted-foreground">
                  {{ numero(producto.stock_disponible) }} disp ·
                  {{ numero(producto.stock_reservado) }} res
                </span>
              </Table.Cell>
              <Table.Cell>
                <Badge :variant="producto.activo ? 'success' : 'outline'">
                  {{ producto.activo ? 'Activo' : 'Oculto' }}
                </Badge>
              </Table.Cell>
              <Table.Cell>
                <div class="flex justify-end gap-1">
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    title="Editar producto"
                    aria-label="Editar producto"
                    @click="editar(producto)"
                  >
                    <Pencil />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    :title="producto.activo ? 'Ocultar del catálogo' : 'Reactivar en el catálogo'"
                    :aria-label="producto.activo ? 'Ocultar producto' : 'Reactivar producto'"
                    @click="alternar(producto)"
                  >
                    <EyeOff v-if="producto.activo" />
                    <Eye v-else />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    title="Ver historial de cambios"
                    aria-label="Ver historial de cambios"
                    @click="verHistorial(producto)"
                  >
                    <ScrollText />
                  </Button>
                </div>
              </Table.Cell>
            </Table.Row>
            </template>
          </Table.Body>
        </Table.Root>
      </Card.Content>
    </Card.Root>

    <ProductoFormDialog
      v-model:open="formOpen"
      :producto="productoEditar"
      :tipos="tipos"
      @guardado="alGuardar"
    />

    <ConfirmDialog
      v-model:open="confirmOpen"
      titulo="Ocultar producto"
      :mensaje="mensajeOcultar"
      confirmar="Ocultar producto"
      variante="destructive"
      :procesando="procesandoEstado"
      @confirmar="confirmarOcultar"
    />

    <Dialog.Root :open="historialOpen" @update:open="historialOpen = $event">
      <Dialog.Content class="w-[min(680px,calc(100vw-2rem))]">
        <Dialog.Header>
          <Dialog.Title>Historial de cambios</Dialog.Title>
          <Dialog.Description>
            {{ productoHistorial?.nombre }} · {{ productoHistorial?.sku }}
          </Dialog.Description>
        </Dialog.Header>
        <div class="max-h-[60vh] w-full overflow-y-auto">
          <div v-if="historialCargando" class="py-8 text-center text-sm text-muted-foreground">
            <LoaderCircle class="mx-auto mb-2 size-5 animate-spin" />
            Cargando historial…
          </div>
          <div v-else-if="historial.length === 0" class="py-8 text-center text-sm text-muted-foreground">
            Este producto todavía no tiene movimientos registrados.
          </div>
          <ul v-else class="space-y-2">
            <li
              v-for="registro in historial"
              :key="registro.id"
              class="rounded-lg border border-border bg-background p-3"
            >
              <div class="flex flex-wrap items-center gap-2">
                <Badge :variant="variantesAccion[registro.accion] ?? 'secondary'">
                  {{ registro.accion }}
                </Badge>
                <span class="text-xs text-muted-foreground">
                  {{ fechaHora(registro.fecha) }} · {{ registro.usuario }}
                </span>
              </div>
              <p class="mt-1.5 text-sm text-foreground">{{ registro.detalle }}</p>
            </li>
          </ul>
        </div>
        <Dialog.Footer>
          <Button variant="outline" @click="historialOpen = false">Cerrar</Button>
        </Dialog.Footer>
      </Dialog.Content>
    </Dialog.Root>
  </div>
</template>
