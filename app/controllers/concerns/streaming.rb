module Streaming
  def stream_csv(csv_enumerator, csv_filename)
    headers['Content-Type'] = 'text/csv; charset=utf-8'
    headers['Content-Disposition'] = %{attachment; filename="#{csv_filename}"}
    headers['X-Accel-Buffering'] = 'no'
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    self.response_body = csv_enumerator
  end
end
