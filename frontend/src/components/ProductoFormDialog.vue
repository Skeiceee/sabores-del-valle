<script setup lang="ts">
import { reactive, ref, watch } from 'vue'
import { LoaderCircle, Save } from '@lucide/vue'
import { Button } from '@/components/button'
import { Dialog } from '@/components/dialog'
import { Input } from '@/components/input'
import { Textarea } from '@/components/textarea'
import { api } from '@/lib/api'
import type { Producto, ProductoPayload, TipoProducto } from '@/lib/types'

const props = defineProps<{
  open: boolean
  producto: Producto | null
  tipos: TipoProducto[]
}>()

const emit = defineEmits<{
  'update:open': [boolean]
  guardado: [string]
}>()

const form = reactive({
  sku: '',
  nombre: '',
  tipo_producto_id: 0,
  formato: '',
  precio: '',
  descripcion: '',
  ingredientes: '',
  alergenos: '',
})

const errores = reactive<Record<string, string>>({})
const guardando = ref(false)
const errorGeneral = ref('')

function limpiar() {
  form.sku = props.producto?.sku ?? ''
  form.nombre = props.producto?.nombre ?? ''
  form.tipo_producto_id =
    props.producto?.tipo_producto_id ?? props.tipos[0]?.id ?? 0
  form.formato = props.producto?.formato ?? ''
  form.precio =
    props.producto?.precio_venta !== null && props.producto?.precio_venta !== undefined
      ? String(props.producto.precio_venta)
      : ''
  form.descripcion = props.producto?.descripcion ?? ''
  form.ingredientes = props.producto?.ingredientes ?? ''
  form.alergenos = props.producto?.alergenos ?? ''
  Object.keys(errores).forEach((clave) => delete errores[clave])
  errorGeneral.value = ''
}

watch(
  () => props.open,
  (abierto) => {
    if (abierto) limpiar()
  },
)

watch(
  () => props.producto,
  () => {
    if (props.open) limpiar()
  },
)

function validar(): boolean {
  Object.keys(errores).forEach((clave) => delete errores[clave])
  if (!form.sku.trim()) errores.sku = 'El SKU es obligatorio.'
  else if (form.sku.trim().length > 30) errores.sku = 'Máximo 30 caracteres.'
  if (!form.nombre.trim()) errores.nombre = 'El nombre es obligatorio.'
  if (!form.tipo_producto_id) errores.tipo_producto_id = 'Selecciona una categoría.'
  if (form.precio.trim() !== '') {
    const precio = Number(form.precio)
    if (Number.isNaN(precio) || precio < 0) {
      errores.precio = 'El precio debe ser un número mayor o igual a 0.'
    }
  }
  return Object.keys(errores).length === 0
}

async function guardar() {
  if (!validar() || guardando.value) return

  const payload: ProductoPayload = {
    sku: form.sku.trim(),
    nombre: form.nombre.trim(),
    tipo_producto_id: Number(form.tipo_producto_id),
    formato: form.formato.trim() || null,
    precio_venta: form.precio.trim() === '' ? null : Number(form.precio),
    descripcion: form.descripcion.trim() || null,
    ingredientes: form.ingredientes.trim() || null,
    alergenos: form.alergenos.trim() || null,
  }

  guardando.value = true
  errorGeneral.value = ''
  try {
    if (props.producto) {
      await api.editarProducto(props.producto.id, payload)
      emit('guardado', `Producto "${payload.nombre}" actualizado.`)
    } else {
      await api.crearProducto(payload)
      emit('guardado', `Producto "${payload.nombre}" creado.`)
    }
    emit('update:open', false)
  } catch (e) {
    errorGeneral.value = e instanceof Error ? e.message : 'No se pudo guardar el producto.'
  } finally {
    guardando.value = false
  }
}
</script>

<template>
  <Dialog.Root :open="open" @update:open="emit('update:open', $event)">
    <Dialog.Content class="w-[min(760px,calc(100vw-2rem))]">
      <Dialog.Header>
        <Dialog.Title>
          {{ producto ? 'Editar producto' : 'Nuevo producto' }}
        </Dialog.Title>
        <Dialog.Description>
          {{
            producto
              ? 'Los cambios se reflejan de inmediato en el catálogo público.'
              : 'Completa los datos comerciales y la información descriptiva.'
          }}
        </Dialog.Description>
      </Dialog.Header>

      <form class="flex w-full flex-col gap-4" @submit.prevent="guardar">
        <div
          v-if="errorGeneral"
          class="rounded-lg border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive"
        >
          {{ errorGeneral }}
        </div>

        <div class="grid gap-4 sm:grid-cols-2">
          <div class="space-y-1.5">
            <label for="sku" class="text-sm font-medium">SKU</label>
            <Input id="sku" v-model="form.sku" placeholder="SDV-1025" />
            <p v-if="errores.sku" class="text-xs text-destructive">{{ errores.sku }}</p>
          </div>

          <div class="space-y-1.5">
            <label for="tipo" class="text-sm font-medium">Categoría</label>
            <select
              id="tipo"
              v-model.number="form.tipo_producto_id"
              class="h-9 w-full rounded-md border border-input bg-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50"
            >
              <option :value="0" disabled>Selecciona una categoría</option>
              <option v-for="tipo in tipos" :key="tipo.id" :value="tipo.id">
                {{ tipo.nombre }}
              </option>
            </select>
            <p v-if="errores.tipo_producto_id" class="text-xs text-destructive">
              {{ errores.tipo_producto_id }}
            </p>
          </div>

          <div class="space-y-1.5 sm:col-span-2">
            <label for="nombre" class="text-sm font-medium">Nombre del producto</label>
            <Input id="nombre" v-model="form.nombre" placeholder="Mermelada de Murta" />
            <p v-if="errores.nombre" class="text-xs text-destructive">{{ errores.nombre }}</p>
          </div>

          <div class="space-y-1.5">
            <label for="formato" class="text-sm font-medium">Formato</label>
            <Input id="formato" v-model="form.formato" placeholder="Frasco 250 g" />
          </div>

          <div class="space-y-1.5">
            <label for="precio" class="text-sm font-medium">Precio de venta (CLP)</label>
            <Input
              id="precio"
              v-model="form.precio"
              type="number"
              min="0"
              step="1"
              placeholder="3500"
            />
            <p v-if="errores.precio" class="text-xs text-destructive">{{ errores.precio }}</p>
          </div>

          <div class="space-y-1.5 sm:col-span-2">
            <label for="descripcion" class="text-sm font-medium">Descripción</label>
            <Textarea
              id="descripcion"
              v-model="form.descripcion"
              placeholder="Información descriptiva que verá el cliente."
            />
          </div>

          <div class="space-y-1.5">
            <label for="ingredientes" class="text-sm font-medium">Ingredientes</label>
            <Textarea
              id="ingredientes"
              v-model="form.ingredientes"
              placeholder="Frutas, azúcar, pectina…"
            />
          </div>

          <div class="space-y-1.5">
            <label for="alergenos" class="text-sm font-medium">Alérgenos</label>
            <Textarea
              id="alergenos"
              v-model="form.alergenos"
              placeholder="Puede contener frutos secos…"
            />
          </div>
        </div>

        <Dialog.Footer class="mt-1">
          <Button
            type="button"
            variant="outline"
            :disabled="guardando"
            @click="emit('update:open', false)"
          >
            Cancelar
          </Button>
          <Button type="submit" :disabled="guardando">
            <LoaderCircle v-if="guardando" class="animate-spin" />
            <Save v-else />
            {{ producto ? 'Guardar cambios' : 'Crear producto' }}
          </Button>
        </Dialog.Footer>
      </form>
    </Dialog.Content>
  </Dialog.Root>
</template>
