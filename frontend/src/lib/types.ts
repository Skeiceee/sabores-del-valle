export interface TipoProducto {
  id: number
  nombre: string
}

export interface Producto {
  id: number
  sku: string
  tipo_producto_id: number
  tipo_producto: string
  nombre: string
  formato: string | null
  precio_venta: number | null
  descripcion: string | null
  ingredientes: string | null
  alergenos: string | null
  activo: boolean
  created_at: string
  updated_at: string
  lotes: number
  stock_disponible: number
  stock_reservado: number
  stock_neto: number
  proximo_vencimiento: string | null
}

export interface ProductoPayload {
  sku: string
  tipo_producto_id: number
  nombre: string
  formato: string | null
  precio_venta: number | null
  descripcion: string | null
  ingredientes: string | null
  alergenos: string | null
}

export interface Lote {
  id: number
  codigo: string
  producto_id: number
  sku: string
  producto: string
  tipo_producto: string
  fecha_elaboracion: string | null
  fecha_vencimiento: string | null
  stock_disponible: number
  stock_reservado: number
  stock_neto: number
  estado_vencimiento: 'vigente' | 'por_vencer' | 'vencido' | 'sin_fecha'
}

export interface Auditoria {
  id: number
  producto_id: number
  sku: string
  producto: string
  accion: 'crear' | 'editar' | 'ocultar' | 'reactivar'
  usuario: string
  detalle: string | null
  fecha: string
}

export interface TipoStock {
  tipo_producto: string
  productos: number
  stock_neto: number
}

export interface Vencimiento {
  lote: string
  producto: string
  fecha_vencimiento: string
  dias_restantes: number
  stock_neto: number
}

export interface Alerta {
  tipo: string
  mensaje: string
}

export interface Dashboard {
  productos_total: number
  productos_activos: number
  productos_ocultos: number
  lotes_total: number
  stock_disponible: number
  stock_reservado: number
  stock_neto: number
  lotes_por_vencer: number
  lotes_vencidos: number
  valor_stock: number
  por_tipo: TipoStock[]
  proximos_vencimientos: Vencimiento[]
  alertas: Alerta[]
}
