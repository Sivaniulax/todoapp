// Shows an error string, plus field-level validation errors from Rails
// (e.g. { email: ["has already been taken"] }).
export default function ErrorMessage({ error, details, onDismiss }) {
  if (!error) return null
  const fieldErrors = details ? Object.entries(details) : []

  return (
    <div className="alert alert-error" role="alert">
      <div>
        <strong>{error}</strong>
        {fieldErrors.length > 0 && (
          <ul>
            {fieldErrors.map(([field, messages]) => (
              <li key={field}>
                {field.replaceAll('_', ' ')} {[].concat(messages).join(', ')}
              </li>
            ))}
          </ul>
        )}
      </div>
      {onDismiss && (
        <button type="button" className="btn btn-ghost" onClick={onDismiss} aria-label="Dismiss error">
          ×
        </button>
      )}
    </div>
  )
}
