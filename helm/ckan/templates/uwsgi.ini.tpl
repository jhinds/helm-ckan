{{- define "uwsgi.ini" -}}
[uwsgi]

http            =  127.0.0.1:5000
http-socket         = :5000
uid             =  www-data
guid            =  www-data
wsgi-file       =  /etc/ckan/default/wsgi.py
virtualenv      =  /usr/lib/ckan/default
module          =  wsgi:application
master          =  true
pidfile         =  /tmp/%n.pid
harakiri        =  50
max-requests    =  5000
vacuum          =  true
callable        =  application
{{- end -}}