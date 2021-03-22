{{- define "uwsgi.ini" -}}
[uwsgi]
auto-procname       = true
buffer-size         = 32768
die-on-term         = true
disable-logging     = false
enable-threads      = true
harakiri            = 60 
http-socket         = :{{ .Values.image.ckan.port }}
log-4xx             = true
log-5xx             = true
log-master          = true
master              = true     
max-requests        = 1000                   
max-worker-lifetime = 3600
memory-report       = true
;module              = ckan.wsgi
module          =  wsgi:application
pidfile         =  /tmp/%n.pid
need-app            = true
reload-on-rss       = 2048
single-interpreter  = true
stats               = :8081
stats-http          = true
strict              = true                   
threads             = 2
thunder-lock        = true
umask               = 002
vacuum              = true
worker-reload-mercy = 60
workers             = 4

;wsgi-file       =  /etc/ckan/default/wsgi.py
;callable        =  application
{{- end -}}