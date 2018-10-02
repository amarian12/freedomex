app.config ['ngDialogProvider', (ngDialogProvider) ->
  ngDialogProvider.setDefaults
    closeByDocument: false
    closeByEscape: true
    trapFocus: true
    cache: false
]
