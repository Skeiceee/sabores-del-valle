const dinero = new Intl.NumberFormat('es-CL', {
  style: 'currency',
  currency: 'CLP',
  maximumFractionDigits: 0,
})

const entero = new Intl.NumberFormat('es-CL')

export function clp(valor?: number | null): string {
  if (valor === null || valor === undefined) return '—'
  return dinero.format(valor)
}

export function numero(valor?: number | null): string {
  return entero.format(valor ?? 0)
}

function aFecha(valor: string): Date {
  return new Date(valor.length === 10 ? `${valor}T12:00:00` : valor)
}

export function fecha(valor?: string | null): string {
  if (!valor) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(aFecha(valor))
}

export function fechaHora(valor?: string | null): string {
  if (!valor) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(aFecha(valor))
}
