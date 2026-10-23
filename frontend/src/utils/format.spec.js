import { describe, expect, it, vi } from 'vitest'
import { debounce, formatDate, statusLabel } from './format'

describe('statusLabel', () => {
  it('reads the AASM states back in plain words', () => {
    expect(statusLabel('in_progress')).toBe('In progress')
    expect(statusLabel('completed')).toBe('Done')
  })

  it('passes anything unknown straight through', () => {
    expect(statusLabel('whatever')).toBe('whatever')
  })
})

describe('formatDate', () => {
  it('reads a Rails date as a local one, not UTC', () => {
    expect(formatDate('2026-03-01')).toContain('Mar')
    expect(formatDate('2026-03-01')).toContain('1')
  })

  it('gives back nothing for nothing', () => {
    expect(formatDate(null)).toBe('')
  })
})

describe('debounce', () => {
  it('only runs once the calls stop', () => {
    vi.useFakeTimers()
    const fn = vi.fn()
    const debounced = debounce(fn, 200)

    debounced('a')
    debounced('b')
    vi.advanceTimersByTime(199)
    expect(fn).not.toHaveBeenCalled()

    vi.advanceTimersByTime(1)
    expect(fn).toHaveBeenCalledExactlyOnceWith('b')
    vi.useRealTimers()
  })
})
