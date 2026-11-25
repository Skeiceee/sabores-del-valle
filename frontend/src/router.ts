import { createRouter, createWebHistory } from 'vue-router'

import PanelView from './views/PanelView.vue'
import ProductosView from './views/ProductosView.vue'
import LotesView from './views/LotesView.vue'
import CatalogoView from './views/CatalogoView.vue'
import AuditoriaView from './views/AuditoriaView.vue'

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'panel',
      component: PanelView,
      meta: {
        titulo: 'Panel de stock',
        descripcion: 'Resumen de productos, lotes y vencimientos.',
      },
    },
    {
      path: '/productos',
      name: 'productos',
      component: ProductosView,
      meta: {
        titulo: 'Productos',
        descripcion: 'Crea, edita y oculta productos del catálogo.',
      },
    },
    {
      path: '/lotes',
      name: 'lotes',
      component: LotesView,
      meta: {
        titulo: 'Lotes y stock',
        descripcion: 'Stock disponible, reservado y vencimientos por lote.',
      },
    },
    {
      path: '/catalogo',
      name: 'catalogo',
      component: CatalogoView,
      meta: {
        titulo: 'Catálogo público',
        descripcion: 'Vista previa de los productos visibles para clientes.',
      },
    },
    {
      path: '/auditoria',
      name: 'auditoria',
      component: AuditoriaView,
      meta: {
        titulo: 'Auditoría',
        descripcion: 'Quién, cuándo y qué acción se ejecutó sobre cada producto.',
      },
    },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
  scrollBehavior: () => ({ top: 0 }),
})
