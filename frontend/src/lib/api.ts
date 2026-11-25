import type {
  Auditoria,
  Dashboard,
  Lote,
  Producto,
  ProductoPayload,
  TipoProducto,
} from './types'

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`/api${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      'X-Usuario': 'admin',
      ...(init?.headers ?? {}),
    },
  })

  if (!res.ok) {
    let mensaje = `Error ${res.status}`
    try {
      const data = await res.json()
      if (data?.detail) {
        mensaje =
          typeof data.detail === 'string' ? data.detail : 'Revisa los datos ingresados.'
      }
    } catch {
      /* respuesta sin cuerpo */
    }
    throw new Error(mensaje)
  }

  return (await res.json()) as T
}

function qs(params: Record<string, string | number | undefined | null>): string {
  const search = new URLSearchParams()
  for (const [clave, valor] of Object.entries(params)) {
    if (valor !== undefined && valor !== null && valor !== '') {
      search.set(clave, String(valor))
    }
  }
  const texto = search.toString()
  return texto ? `?${texto}` : ''
}

export const api = {
  dashboard: () => request<Dashboard>('/dashboard'),

  tipos: () => request<TipoProducto[]>('/tipos'),

  productos: (filtros: {
    buscar?: string
    tipo_producto_id?: number | ''
    estado?: string
  }) => request<Producto[]>(`/productos${qs(filtros)}`),

  producto: (id: number) => request<Producto>(`/productos/${id}`),

  crearProducto: (datos: ProductoPayload) =>
    request<Producto>('/productos', { method: 'POST', body: JSON.stringify(datos) }),

  editarProducto: (id: number, datos: ProductoPayload) =>
    request<Producto>(`/productos/${id}`, { method: 'PUT', body: JSON.stringify(datos) }),

  cambiarEstado: (id: number, activo: boolean) =>
    request<Producto>(`/productos/${id}/estado`, {
      method: 'PATCH',
      body: JSON.stringify({ activo }),
    }),

  auditoriaProducto: (id: number) =>
    request<Auditoria[]>(`/productos/${id}/auditoria`),

  auditoria: (limite = 150) => request<Auditoria[]>(`/auditoria?limite=${limite}`),

  lotes: (filtros: {
    buscar?: string
    estado?: string
    tipo_producto_id?: number | ''
  }) => request<Lote[]>(`/lotes${qs(filtros)}`),

  catalogo: (filtros: { buscar?: string; tipo_producto_id?: number | '' }) =>
    request<Producto[]>(`/catalogo${qs(filtros)}`),
}
