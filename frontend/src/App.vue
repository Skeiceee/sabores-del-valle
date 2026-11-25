<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import {
  Boxes,
  ChefHat,
  ClipboardList,
  LayoutDashboard,
  Package,
  Store,
} from '@lucide/vue'

const route = useRoute()

const navegacion = [
  { to: '/', etiqueta: 'Panel', icono: LayoutDashboard },
  { to: '/productos', etiqueta: 'Productos', icono: Package },
  { to: '/lotes', etiqueta: 'Lotes y stock', icono: Boxes },
  { to: '/catalogo', etiqueta: 'Catálogo', icono: Store },
  { to: '/auditoria', etiqueta: 'Auditoría', icono: ClipboardList },
]

const titulo = computed(() => (route.meta.titulo as string) ?? 'Panel')
const descripcion = computed(() => (route.meta.descripcion as string) ?? '')
const hoy = new Intl.DateTimeFormat('es-CL', {
  weekday: 'long',
  day: 'numeric',
  month: 'long',
  year: 'numeric',
}).format(new Date())
</script>

<template>
  <div class="flex min-h-screen flex-col bg-muted/40 lg:flex-row">
    <aside
      class="z-30 shrink-0 border-b border-sidebar-border bg-sidebar lg:sticky lg:top-0 lg:flex lg:h-screen lg:w-64 lg:flex-col lg:border-r lg:border-b-0"
    >
      <div class="flex items-center gap-3 px-4 py-4 lg:px-5 lg:py-6">
        <div
          class="flex size-10 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-sm"
        >
          <ChefHat class="size-5" />
        </div>
        <div class="min-w-0">
          <p class="truncate text-sm font-semibold tracking-tight text-foreground">
            Sabores del Valle
          </p>
          <p class="text-xs text-muted-foreground">Administración</p>
        </div>
      </div>

      <nav class="flex gap-1 overflow-x-auto px-3 pb-3 lg:flex-col lg:px-3 lg:pb-0">
        <RouterLink
          v-for="item in navegacion"
          :key="item.to"
          :to="item.to"
          class="flex shrink-0 items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
          :class="
            route.path === item.to
              ? 'bg-primary text-primary-foreground shadow-sm'
              : 'text-muted-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'
          "
        >
          <component :is="item.icono" class="size-4" />
          {{ item.etiqueta }}
        </RouterLink>
      </nav>

      <div class="mt-auto hidden px-3 pb-4 lg:block">
        <div class="rounded-xl border border-sidebar-border bg-background p-3">
          <div class="flex items-center gap-2.5">
            <div
              class="flex size-8 items-center justify-center rounded-full bg-secondary text-xs font-semibold text-secondary-foreground"
            >
              AD
            </div>
            <div class="min-w-0">
              <p class="truncate text-xs font-semibold text-foreground">admin</p>
              <p class="text-[11px] text-muted-foreground">Sesión local</p>
            </div>
          </div>
          <p class="mt-2.5 text-[11px] leading-relaxed text-muted-foreground">
            Las acciones quedan registradas en la auditoría.
          </p>
        </div>
      </div>
    </aside>

    <div class="flex min-w-0 flex-1 flex-col">
      <header
        class="sticky top-0 z-20 border-b border-border bg-background/85 px-4 py-3 backdrop-blur md:px-8"
      >
        <div class="mx-auto flex max-w-[1400px] items-center justify-between gap-4">
          <div class="min-w-0">
            <h1 class="truncate text-lg font-semibold tracking-tight text-foreground md:text-xl">
              {{ titulo }}
            </h1>
            <p class="hidden truncate text-xs text-muted-foreground sm:block">
              {{ descripcion }}
            </p>
          </div>
          <p class="hidden shrink-0 text-xs capitalize text-muted-foreground md:block">
            {{ hoy }}
          </p>
        </div>
      </header>

      <main class="mx-auto w-full max-w-[1400px] flex-1 px-4 py-5 md:px-8 md:py-7">
        <RouterView />
      </main>

      <footer
        class="mx-auto w-full max-w-[1400px] px-4 pb-5 text-[11px] text-muted-foreground md:px-8"
      >
        HU-03 · Administración de productos · PostgreSQL + FastAPI + Vuzeno
      </footer>
    </div>
  </div>
</template>
