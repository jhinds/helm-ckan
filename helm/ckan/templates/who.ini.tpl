{{- define "who.ini" -}}
[plugin:auth_tkt]
use = ckan.lib.repoze_plugins.auth_tkt:make_plugin
# If no secret key is defined here, beaker.session.secret will be used
#secret = somesecret

[plugin:friendlyform]
use = ckan.lib.repoze_plugins.friendly_form:FriendlyFormPlugin
login_form_url= /user/login
login_handler_path = /login_generic
logout_handler_path = /user/logout
rememberer_name = auth_tkt
post_login_url = /user/logged_in
post_logout_url = /user/logged_out
charset = utf-8

[general]
request_classifier = repoze.who.classifiers:default_request_classifier
challenge_decider = repoze.who.classifiers:default_challenge_decider

[identifiers]
plugins =
    friendlyform;browser
    auth_tkt

[authenticators]
plugins =
    auth_tkt
    ckan.lib.authenticator:UsernamePasswordAuthenticator

[challengers]
plugins =
    friendlyform;browser

{{- end -}}
