{{- define "uwsgi.ini" -}}
; uwsgi configuration options.
; The full list of options can be found here:
;    https://uwsgi-docs.readthedocs.io/en/latest/Options.html
;
; uwsgi "best practices":
;    https://uwsgi-docs.readthedocs.io/en/latest/ThingsToKnow.html
; 
; more "best practices":
;    https://www.techatbloomberg.com/blog/configuring-uwsgi-production-deployment/
;
; auto-procname:                  Automatically set processes name to something meaningful
; buffer-size:                    The max size of a request allowed by uwsgi. 65535 is the max.  We should be relatively safe with this default since nginx sits in front of it.
; chdir:                          The path where the djano root directory resides. Where manage.py lives. 
; die-on-term:                    Setting to true means a SIGTERM kills the application instead of just brutally reloading it.
; disable-logging:                Disable request logging. This doesn't disable logs that are explictly set elsewhere in the config.
; enable-threads:                 Allows threads to exeute.
; harakiri:                       Seconds before forcefully killing a worker. Essentially a request timeout.
; http-socket:                    The port to bind to using HTTP.
; log-4xx:                        Logs all 4xx requests. 
; log-5xx:                        Logs all 5xx requests.
; log-master:                     Delegates logging to the master process.  This allows the app logs to show up in uwsgi logs.
; master:                         Master process will manage workers and enable other uwsgi features.
; max-requests:                   Restarts workers after the specified amount of requests.
; max-worker-lifetime:            Restarts workers after the specified amount of seconds.
; memory-report:                  Will give memory usage of each process in logs.
; module:                         The wsgi module to use which will be the wsgi file django created.
; need-app:                       Prevent uwsgi from starting if it can't find the application module.
; reload-on-rss                   Reolads a worker that's memory exceeds the specified amount of MB.
; single-interpreter:             Since we are not hosting multiple services in each worker process set to true and prevent potential compitability issues with some c extensions.
; stats:                          Enables and specifies which port uwsgi stats are available on to with debugging issues.
; stats-http:                     Enable to have stats available via HTTP.
; strict:                         If enabled tells uwsgi to not start if there are any issues with the config file options or format.
; threads:                        Number of threads for each worker
; thunder-lock:                   Useful if using multiple workers with multiple threads: https://uwsgi-docs.readthedocs.io/en/latest/articles/SerializingAccept.html.
; umask:                          Set umask for file permissions for uwsgi
; vacuum:                         Enabling tells uwsgi to clean up any temporary files or UNIX sockets it creates.
; worker-reload-mercy:            How long to wait for a worker to reload/shutdown before forcefully killing it.
; workers:                        The number for workers/processes to spawn. When the 'cheaper' option is set it is for autoscaling it the maximum amount for autoscaling.
[uwsgi]
auto-procname       = true
buffer-size         = 32768
die-on-term         = true
disable-logging     = false
callable            = application
chdir               = /etc/ckan/
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
module              = wsgi
pidfile            =  /tmp/%n.pid
need-app            = true
reload-on-rss       = 2048
single-interpreter  = true
stats               = :{{ add .Values.image.ckan.port 1 }}
stats-http          = true
strict              = true                   
threads             = 2
thunder-lock        = true
umask               = 002
vacuum              = true
worker-reload-mercy = 60
workers             = 4
{{- end -}}