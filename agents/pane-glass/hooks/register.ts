import type { Register } from 'claude-code'

// The surface paints panes opaque by default, hiding the terminal's own transparency.
export const register: Register = on => {
  on('ui.open', ($, e, next) => next({ ...e, backgroundColor: e.backgroundColor ?? 'transparent' }))
}
